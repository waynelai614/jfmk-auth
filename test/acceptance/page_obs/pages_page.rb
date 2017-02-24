require "acceptance/page_obs/base_page"

class PagesPage < Pages::Base
  def has_proxy_content?
    unless page.has_no_content?("Aws::Errors") && page.has_no_content?("Aws::S3::Errors")
      raise "Expected to find no AWS errors, but found: \n\n #{page.text}"
    end
    unless page.has_css?('nav.navbar', text: 'Site Title Work About Blog')
      raise "Expected to find proxy content navbar, but found: \n\n #{page.text}"
    end
    true
  end

  def has_work_thumb_presigned_image?(idx)
    img_src = page.find(".work-thumb-item:nth-of-type(#{idx + 1}) img")[:src]
    matched = presigned_url_format?(:jpg).match img_src
    unless matched
      raise "Expected to find thumb image with presigned S3 formatted URL, but found: #{img_src}"
    end
    has_loaded_image? img_src, page
  end

  def has_work_detail_video?
    video = page.find(".detail-item video")
    unless presigned_url_format?(:jpg).match video[:poster]
      raise "Expected to find video poster image with presigned S3 formatted URL, but found: #{video[:poster]}"
    end
    unless presigned_url_format?(:mp4).match video[:src]
      raise "Expected to find video src with presigned S3 formatted URL, but found: #{video[:src]}"
    end

    # Video loaded and is ready
    unless page.has_css?(".detail-item .item-video.vjs-paused .vjs-poster")
      raise "Expected to find a paused video, but did not."
    end
    true
  end

  # def click_work_video_play
  #  This causes chromedriver to crash! Spent some time trying to resolve, but am moving on.
  #  page.find('.detail-item .item-video').click
  # end

  def click_work_thumb(idx)
    page.find(".work-thumb-item:nth-of-type(#{idx + 1})").click
  end

  def has_log_out?(first_name)
    page.has_css? 'a#log-out', text: "Log Out, #{first_name}"
  end

  def click_log_out
    page.find('#log-out').click
  end

  private

  def presigned_url_format?(file_type) # jpg, mp4
    /\Ahttps:\/\/[^.]*.[^.]*.amazonaws.com\/.*(\.#{file_type})\?.*X-Amz-Expires=\d+.*/
  end
end
