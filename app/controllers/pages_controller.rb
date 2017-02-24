class PagesController < ApplicationController
  def index

    # How to share a single page web app behind a strong auth system? Proxying all files is slow and resource intensive.
    # There is probably a better way of doing this, but the following works for now.

    # On S3 there is a single page Angular app index.html page with embedded data, it is 'authenticated-read' access.
    # - Proxy it into this controller.
    # The rest of the JS/CSS/util-images are in same bucket with 'public-read' access.
    # - Inject meta base tag for them into the index proxy file.
    # The page data has several private image/video assets that point to another 'authenticated-read' bucket.
    # - Create expiring signed URLs for them.
    # Inject javascript to redirect to /logout on timeout that matches when content expires
    # Inject logout button into header nav on right, and GA vars

    # Content should expire slightly after session expires to prevent a race condition on the reload
    @expires_after_seconds = ApplicationController::SESSION_EXPIRES_AFTER_SECONDS + 5

    begin
      # Get private static index.html page.
      resp = Aws::S3::Client.new.get_object(
          bucket: ENV['CONTENT_S3_INDEX_PAGE_BUCKET'],
          key: ENV['CONTENT_S3_INDEX_PAGE_KEY']
      )
      out = resp.body.string
      out = ActiveSupport::Gzip.decompress out if resp.content_encoding == 'gzip'

      # Inject 'base' meta tag so js/css/util-images load from the public S3 bucket,
      # and force reload on timeout so pre-signed urls don't expire while in a session.
      out.sub!("<head>", "<head>#{html_head_inject}")

      # Replace private S3 img/video asset urls with expiring presigned S3 urls.
      reg = /(\/\/#{ENV['CONTENT_S3_ASSETS_REGEXP_BUCKET_PATH']})\
              (#{ENV['CONTENT_S3_ASSETS_KEY_PREFIX']}\/[^"']+)/ix
      out.gsub!(reg) do
        key = Regexp.last_match[2]
        url = Aws::S3::Presigner.new.presigned_url(
            :get_object,
            bucket: ENV['CONTENT_S3_ASSETS_BUCKET'],
            key: key,
            expires_in: @expires_after_seconds
        )
        url
      end

      if ENV['GOOGLE_ANALYTICS_UA'].present?
        # Inject Google Analytics ID & userId
        out.sub! /(ga\('create',).*\);/,
                 "ga('create', '#{ENV['GOOGLE_ANALYTICS_UA']}', '#{ENV['GOOGLE_ANALYTICS_PRODUCTION_HOSTNAME']}');"
        out.sub! /\/\/ ga\('set', 'userId', '\#\{USER_ID\}'\);/,
                 "ga('set', 'userId', '#{@current_user.username}');"
      end

      # Inject 'Log Out, Name'
      out.gsub! '<!--#{AUTH_LOG_OUT}-->', html_log_out

      # Render processed index page back to browser
      render body: out, content_type: 'text/html'

    rescue Aws::S3::Errors::ServiceError => e
      render text: %(
S3 error occurred. Are environment AWS credentials set?<p/>
Try reloading the browser, or contact administrator.
#{e.class}: #{e.message}
)
    end
  end

  private

  def html_head_inject
    # 1) Add a base href so relativel references load from public S3
    # 2) On timeout, reload page to enforce server side session hasn't expired, and to
    #   re-issue S3 expiring pre-signed urls. Reloads with no cache, and preserves url fragments.
    %(
<!-- BEGIN AUTHENTICATION SITE HEADER INJECTION -->
<base href='#{ENV['CONTENT_S3_INDEX_PAGE_BASE']}'>
<script>
  setTimeout(function () { window.location.reload(true);}, #{@expires_after_seconds * 1000});
</script>
<!-- END -->
    )
  end

  def html_log_out
    %(
<ul class='nav navbar-nav navbar-right'>
  <li><a href='#{logout_url}' target='_self' id='log-out'>Log Out, #{@current_user.first_name}</a></li>
</ul>
    )
  end
end
