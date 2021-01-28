class ProductTypesController < ApplicationController
  def index
    @product_types = ProductType.order(params[:sort])

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
    @product_type = find_product_type_instance
    @products = @product_type.products
  end

  def edit
    @product_type = ProductType.find(params[:id])

  end

  def update
    @product_type = ProductType.find(params[:id])
    if @product_type.update(product_type_params)
      redirect_to product_types_path, notice: 'Parent product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @product_type = ProductType.find(params[:id])
    if @product_type.destroy
      redirect_to product_types_path, notice: 'Parent product was successfully deleted.'
    else
      render :show, notice: 'There was problem deleting this item.'
    end
  end

  private
  def find_product_type_instance
    @product_type = ProductType.find(params[:id])
  end

  def product_type_params
    params.require(:product_type).permit(:title, :photo)
  end
end
