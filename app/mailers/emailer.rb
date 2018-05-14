class Emailer < ActionMailer::Base
  layout 'mailer'
  default from: ENV["email_username"] + "@" + ENV["email_domain"]

  def info_email(receiver, subject, message)
    return unless check_email receiver.email

    @user = receiver
    @message = message
    puts "测试"
    mail(to: receiver.email, subject: subject, send_on: Time.now)
    rescue
  end

  def puni_email(receiver, puni)
    return unless check_email receiver.email
    @user = receiver
    @puni = puni
    mail(to: receiver.email, subject: "处罚通知", send_on: Time.now)
    rescue
  end

  def validate_email(receiver, link, action)
    return unless check_email receiver.email
    @link = link
    @action = action
    mail(to: receiver.email, subject: "验证邮件", send_on: Time.now)
    rescue
  end

  def coedit_info_email(receiver, file, coeditor)
    return unless check_email receiver.email
    @user = receiver
    @file = file
    @coeditor = coeditor
    mail(to: receiver.email, subject: "【墨坊】协作邀请通知", send_on: Time.now)
  end

  private
    def check_email email
      email && Validate::VALID_EMAIL_REGEX.match(email)
    end
end
