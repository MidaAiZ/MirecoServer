require 'openssl'
require 'base64'
require 'cgi'

class Valicode
  def self.set_msg_code(phone, handle)
    return 'InvalidHandle' unless handle
    return 'InvalidPhone' unless phone && Validate::VALID_PHONE_REGEX.match(phone)

    @cache = Cache.new
    # 生成由a-z和0-9组成的四位随机字符串
    @msg_code = [*(0..9)].sample(4).join

    # 向手机发送短信验证码
    begin
      key_id = 'LTAIjUfYi2HkL7QU'
      secret_key = '56iAENR1SLNG9eYSonhiS1sN0b051m' + '&'
      ture_nonce = [*('s'..'z'), '-', *(0..9)].sample(21).join
      time = Time.now.utc.iso8601
      params = {
        AccessKeyId: key_id,
        Action: :SingleSendSms,
        Format: :JSON,
        ParamString: "{code:'#{@msg_code}'}",
        RecNum: phone,
        SignName: '验证短信',
        SignatureMethod: 'HMAC-SHA1',
        SignatureNonce: ture_nonce,
        SignatureVersion: 1.0,
        TemplateCode: 'SMS_44310603',
        Timestamp: time,
        Version: '2016-09-27'
      }
      args = Hash[params.sort_by { |key, _val| key }].to_query
      string_to_sign = 'POST&%2F&' + CGI.escape(args).gsub(/[+]/, '%20').gsub(/(%7E)/, '~')
      hash = OpenSSL::HMAC.digest('sha1', secret_key, string_to_sign)
      signature = Base64.encode64(hash).gsub(/[+]/, '%2B')

      url = "https://sms.aliyuncs.com/?Signature=#{signature}&#{args}"

      response = RestClient.post(url, '')

    rescue RestClient::Exception => e
      puts e.response
      return :Fail
      # res[:failed] = true
      # response = JSON.parse(e.response)
      # res[:message] = if response['code'] == 601 # 短信数目超过限制的错误
      #                   response['error']
      #                 else # 其他错误
      #                   '验证码发送失败！请稍后再试'
      #                 end
    end

    # 将验证码添加至cache
    cache_key = self.msg_cache_key(phone, handle)
    @cache[cache_key, 10 * 60] = { code: @msg_code, times: 0 }
    return :Success
  end

  def self.set_reg_email user
      @cache = Cache.new
      # 生成由随机字符串组成的字符
      activation_token = SecureRandom.urlsafe_base64
      @key = Time.now.to_f.to_s + "-" + user.id.to_s + "-" + activation_token
      @cache["email_session_#{user.id}", 30 * 60] = { key: @key, times: 0 }
      @key
  end

  def self.msg_cache_key phone, handle
    'msg_' + handle + '_' + phone if phone && handle
  end

  def self.email_cache_key
    # "email_session_#{params[:id]}"
  end

end
