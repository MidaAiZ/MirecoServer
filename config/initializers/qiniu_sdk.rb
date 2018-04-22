require 'qiniu'

Qiniu.establish_connection! access_key: 'rOuOLPx-zrNi1jZe4YasD0lX3mY4wN_I-c3-DWOZ',
                            secret_key: '4wyZeG47q4NULunznW2zZaPsjpgx_NX-vgSZjqXy'

# 要上传文件的本地路径
# filePath = './ruby-logo.png'
# 调用 upload_with_token_2 方法上传
# code, result, response_headers = Qiniu::Storage.upload_with_token_2(
#      uptoken,
#      filePath,
#      key,
#      nil, # 可以接受一个 Hash 作为自定义变量，请参照 http://developer.qiniu.com/article/kodo/kodo-developer/up/vars.html#xvar
#      bucket: bucket
# )
#打印上传返回的信息
# puts code
# puts result
