class Flash
  def initialize(contents = {})
    @contents = contents
    @keep = []
  end

  def [](key)
    @contents[key]
  end

  def []=(key, value)
    @contents[key] = value
    @keep << key
  end

  def method_missing(method)
    if Hash.respond_to?(method)
      @contents.send(method)
    else
      raise NoMethodError
    end
  end

  def now[]=(key, value)
    @contents[key] = value
  end

  def keep(key)
    @keep << key
  end

end