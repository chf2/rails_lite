require_relative '../../lib/controller_base'
require_relative '../models/cat'

class CatsController < ControllerBase
  def index
    flash[:notice] = "Regular flash from Cats"
    flash.now[:notice] = "Flash.now from Cats"
    @cats = Cat.all
  end

  def new
    @cat = Cat.new
  end

  def create
    fail
    @cat = Cat.new(name: params[:cat][:name])
    if @cat.save
      flash[:success] = "Cat created!"
      redirect_to cat_path(@cat.id)
    else
      flash.now[:errors] = "Failed!"
      render :new
    end
  end

  def show
    @cat = Cat.find(params['id'])
  end

end