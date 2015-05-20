require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app_session'
        @cookie = JSON.parse(cookie.value)
      end
    end
    @cookie ||= {}
    @cookie["authenticity_token"] = SecureRandom.urlsafe_base64
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = WEBrick::Cookie.new(
      '_rails_lite_app_session', 
      @cookie.to_json
    )
    cookie.path = "/"
    res.cookies << cookie
  end
end