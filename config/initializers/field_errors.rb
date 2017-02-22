ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.html_safe # Do not show 'field_with_errors' div wrapper
end
