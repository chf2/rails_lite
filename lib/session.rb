require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app_session'
        @data = JSON.parse(cookie.value)
      end
    end
    @data ||= {}
    @data["authenticity_token"] = SecureRandom.urlsafe_base64
  end

  def [](key)
    @data[key]
  end

  def []=(key, val)
    @data[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = WEBrick::Cookie.new(
      '_rails_lite_app_session', 
      @data.to_json
    )
    cookie.path = "/"
    res.cookies << cookie
  end
end