$(document).on "turbolinks:load", ->
  return unless $('main.sessions').length

  form = $("#login-form") # Reduce scope of queries where appropriate
  usernameInput = form.find("#username")

  # If user hasn't given focus to a field yet, give it to field designated by the view.
  unless $('input:focus').length
    usernameInput.focus().select()

  checkInputs = ->
    hasInput = usernameInput.val().length > 0 and form.find("#password").first().val().length > 0
    form.find('#login').first().prop 'disabled', not hasInput
  checkInputs() # Call on page load in case user filled form in super fast (capybara)

  # Toggle submit button based on user input
  $('input').on 'input', checkInputs

