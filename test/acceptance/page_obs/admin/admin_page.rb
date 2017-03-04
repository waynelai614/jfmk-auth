require "acceptance/page_obs/base_page"

class Admin::AdminPage < Page::Base
  def has_log_out?(first_name)
    page.has_css? 'a#log-out', text: "Log Out, #{first_name}"
  end

  def has_no_breadcrumb?
    page.has_no_css?('.breadcrumb')
  end

  def has_breadcrumb?(arr)
    css = '.breadcrumb li'
    unless page.has_css?(css, count: arr.size)
      raise "Expected breadcrumb to have #{arr.size} items, but found #{page.all(css).size}."
    end
    arr.each_with_index do |item, idx| # item = {label: 'Label', link: 'path'}
      item_css = "#{css}:nth-of-type(#{idx + 1})"
      if idx < arr.length - 1
        # Non-last items have link and label
        item_css += " a[href='#{item[:link]}']"
        unless page.has_css?(item_css, text: item[:label])
          raise "Expected breadcrumb[#{idx}] to have link: '#{item[:link]}' " \
            "and label: '#{item[:label]}', but it does not."
        end
      else
        # Last item has .active and no link
        item_css += '.active'
        if !page.has_css?(item_css, text: item[:label])
          raise "Expected breadcrumb[#{idx}] to have label: '#{item[:label]}', but it does not."
        elsif page.has_css?(item_css + ' a')
          raise "Expected breadcrumb[#{idx}] to have no link, but found one."
        end
      end
    end
    true
  end

  def has_btn_link?(label, path)
    page.has_css?("a[href='#{path}'] .btn", text: label)
  end

  def click_btn_link(label)
    page.find('a .btn', text: label).click
  end

  def has_no_headline?
    page.has_no_css?('h1')
  end

  def has_headline?(headline)
    page.has_css?('h1', text: headline)
  end
end
