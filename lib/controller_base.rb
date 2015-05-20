require_relative './params'
require_relative './session'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

class ControllerBase
  attr_reader :params, :res, :req, :flash

  def initialize(req, res, route_params = {})
    @params = Params.new(req, route_params)
    @req, @res = req, res
    @flash = Flash.new
  end

  def already_built_response?
     @already_built_response
  end

  def invoke_action(name)
    send(name)
    # This is cool -- this is the auto render at end
    # of a controller action. Won't call in case of redirect!
    unless already_built_response?
      render(name)
    end
  end

  def redirect_to(url)
    raise if already_built_response?
    # res.set_redirect(WEBrick::HTTPStatus::Redirect, url)
    res.header['location'] = url.to_s
    res.status = 302
    @already_built_response = true
    session.store_session(res)
  end

  def render(template_name)
    erb_template = File.read(
      "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    )
    controller_binding = Kernel.binding
    rendered_html = ERB.new(erb_template).result(controller_binding)
    render_content(rendered_html, 'text/html')
  end

  def render_content(content, content_type)
    raise if already_built_response?
    res.body = content
    res.content_type = content_type
    @already_built_response = true
    session.store_session(res)
  end

  def session
    @session ||= Session.new(req)
    @flash = 
  end
end