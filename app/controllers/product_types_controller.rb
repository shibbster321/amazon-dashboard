class ProductTypesController < ApplicationController
  def index
    @product_types = ProductType.all
  end

  def new
    @product_type = ProductType.new
  end

  def create
     @product_type = ProductType.new(product_type_params)
    if @product_type.save
      @product_type.save
      redirect_to new_product_type_product_path(@product_type)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def find_product_type_instance
    @product_type = product_type.find(params[:id])
  end

  def product_type_params
    params.require(:product_type).permit(:title)
  end
end
