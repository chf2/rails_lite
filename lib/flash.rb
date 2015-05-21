require 'json'
require 'webrick'

# Could implement a hash with indifferent access class here

class Flash
  attr_reader :contents

  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app_flash'
        @contents = JSON.parse(cookie.value)
        
      end
    end
    @contents ||= {}
    @stored_contents = {}
  end

  def [](key)
    @contents[key]
  end

  def []=(key, value)
    @stored_contents[key] = value
  end

  def each(&prc)
    @contents.each(&prc)
  end

  def empty?
    @contents.empty?
  end

  def method_missing(method)
    if Hash.respond_to?(method)
      @contents.send(method)
    else
      raise NoMethodError
    end
  end

  def now
    @contents
  end

  def store_flash(res)
    cookie = WEBrick::Cookie.new(
      '_rails_lite_app_flash', 
      @stored_contents.to_json
    )
    cookie.path = "/"
    res.cookies << cookie
  end
end