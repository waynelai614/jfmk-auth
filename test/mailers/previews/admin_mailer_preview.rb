# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def activity_email
    AdminMailer.activity_email User.first, ActionDispatch::TestRequest.create({}), Time.zone.now
  end
end

