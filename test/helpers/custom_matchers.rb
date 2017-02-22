# Modified from original source: http://stackoverflow.com/a/41603801/281809

# frozen_string_literal: true

module Capybara
  module CustomMatchers
    include Capybara::DSL

    class Asset
      def asset_exists?(actual, src)
        js_script = <<JSS
xhr = new XMLHttpRequest();
xhr.open('GET', '#{src}', true);
xhr.send();
JSS
        actual.execute_script(js_script)
        status = actual.evaluate_script('xhr.status') # get js variable value
        status == 200 || status == 302
      end
    end

    class LoadImage < Asset
      def initialize(*args)
        @args = args
        @src = args.first
      end

      def matches?(actual)
        is_present = actual.has_selector?("img[src='#{@src}']")
        is_present && asset_exists?(actual, @src)
      end

      def does_not_match?(actual)
        actual.has_no_selector?("img[src='#{@src}']")
      end

      def failure_message
        "No image loaded with source: '#{@src}'"
      end
    end

    # has_image? 'src_path.jpg', session
    def has_loaded_image?(*args)
      img = LoadImage.new(*args)
      unless img.matches?(args[1])
        raise img.failure_message
      end
      true
    end
  end
end
