class ProductsController < ApplicationController
  def index
  end

  def new
    @product_type = ProductType.find(params[:product_type_id])
    @product = Product.new

  end

  def create
    @product_type = ProductType.find(params[:product_type_id])
    @product = Product.new(product_params)
    @product.product_type_id = @product_type.id
    if @product.save
      redirect_to product_types_path
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

  def product_params
    params.require(:product).permit(:description, :title, :asin, :sku, :color_size, :product_type_id)
  end
end
