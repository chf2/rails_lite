require_relative '../../lib/controller_base'
require_relative '../models/cat'

class CatsController < ControllerBase
  def index
    @cats = Cat.all
  end
end