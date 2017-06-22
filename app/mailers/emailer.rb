class Emailer < ActionMailer::Base
  layout 'mailer'
  default from: ENV["email_username"] + "@" + ENV["email_domain"]

  def info_email(receiver, subject, message)

    check_email receiver.email

    @user = receiver
    @message = message
    puts "测试"
    mail(to: receiver.email, subject: subject, send_on: Time.now)
    rescue
  end

  def puni_email(receiver, puni)
    check_email receiver.email
    @user = receiver
    @puni = puni
    mail(to: receiver.email, subject: "处罚通知", send_on: Time.now)
    rescue
  end

  def validate_email(receiver, link, action)
    check_email receiver.email
    @link = link
    @action = action
    mail(to: receiver.email, subject: "验证邮件", send_on: Time.now)
    rescue
  end

  private
    def check_email email
      return if email.blank? || !Validate::VALID_EMAIL_REGEX.match(email)
    end
end
