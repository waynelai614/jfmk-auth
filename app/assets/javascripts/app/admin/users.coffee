$(document).on "turbolinks:load", ->
  return unless $('main.admin.users').length

  form = $("#user-form") # Reduce scope of queries where appropriate
  usernameInput = form.find("#user_username")

  # If user hasn't given focus to a field yet, give it to field designated by the view.
  unless $('input:focus').length
    usernameInput.focus()
    console.log usernameInput.length
