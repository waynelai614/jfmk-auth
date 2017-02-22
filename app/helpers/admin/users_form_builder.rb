class Admin::UsersFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attr, label_text, help_text, add_on, errors, args = {})
    field_wrapper(attr, label_text, help_text, add_on, errors) do
      assign_form_control_class args
      super attr, args
    end
  end

  def password_field(attr, label_text, help_text, add_on, errors, args = {})
    field_wrapper(attr, label_text, help_text, add_on, errors) do
      assign_form_control_class args
      super attr, args
    end
  end

  private

  def assign_form_control_class(args)
    args[:class] = "#{args[:class] || ' '} form-control"
  end

  def field_wrapper(attr, label_text, help_text, add_on, errors, &block)
    klass = 'form-group'
    klass += ' has-feedback has-error' if errors.present?
    o = ''.html_safe
    o += @template.content_tag :div, class: klass, id: "#{@object_name}_form_group_#{attr}" do
      o = label attr, label_text, class: 'control-label' if label_text.present?
      o += @template.content_tag(:div, {class: 'input-group'}) do
        o = ''.html_safe
        o += @template.content_tag(:span, add_on, {class: 'input-group-addon'}) if add_on.present?
        o += block.call
        o
      end
      if errors.present?
        o += @template.content_tag(:span, class: 'form-control-feedback') do
          "<i class='fa fa-remove'></i>".html_safe
        end
      end
      if errors.present?
        o += @template.content_tag(:p, "#{label_text} #{errors.uniq.to_sentence}.", {class: 'validation-error'})
      end
      o
    end
    o += @template.content_tag(:p, help_text, {class: 'help-block'}) if help_text.present?
    o.html_safe
  end
end
