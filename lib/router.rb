require_relative('./route_helper')

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method = pattern, http_method
    @controller_class, @action_name = controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    pattern =~ req.path &&
      http_method == req.request_method.downcase.to_sym
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = pattern.match(req.path)
    route_params = {}
    match_data.names.each do |name|
      route_params[name] = match_data[name]
    end
    @controller_class.new(req, res, route_params).invoke_action(action_name)
  end
end

class Router
  include RouteHelper
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def get(pattern, controller_class, action_name)
    add_route(pattern, :get, controller_class, action_name)

  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
      
      matcher = Regexp.new("^(?<class>.+)Controller$")
      class_name = matcher.match(controller_class.to_s)['class'].downcase
      RouteHelper.create_helper(action_name, class_name)
    end

  end

  # should return the route that matches this request
  def match(req)
    @routes.find { |route| route.matches?(req) }
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    p req.cookies
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
