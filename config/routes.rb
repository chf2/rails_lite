require_relative '../lib/controller_base'
require_relative '../app/controllers/cats_controller'
require_relative '../lib/router'

class AllRoutes
  def initialize
    @collection = []
  end

  def run(router)
    router.draw do
      get gen_rgx("cats"), CatsController, :index
      post gen_rgx("cats"), CatsController, :create
      get gen_rgx("cats/new"), CatsController, :new
      get gen_rgx("cats/\d+"), CatsController, :show
      put gen_rgx("cats/\d+"), CatsController, :update
      delete gen_rgx("cats/\d+"), CatsController, :destroy
      get gen_rgx("cats/\d+/edit"), CatsController, :edit
    end
  end

end