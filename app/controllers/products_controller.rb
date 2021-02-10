class ProductsController < ApplicationController
  after_action :verify_authorized, only: [:index, :new, :create, :edit, :update, :destroy]
  skip_after_action :verify_policy_scoped, only: :index
  def index
  end

  def new
    authorize Product
    @product_type = ProductType.find(params[:product_type_id])
    @product = Product.new

  end

  def create
    authorize Product
    @product_type = ProductType.find(params[:product_type_id])
    @product = Product.new(product_params)
    @product.product_type_id = @product_type.id
    if @product.save
      redirect_to product_type_path(@product_type)
    else
      render :new
    end
  end

  def show
    authorize Product
    @product_type = ProductType.find(params[:product_type_id])
    @products = @product_type.products
  end

  def edit
    authorize Product
    @product_type = ProductType.find(params[:product_type_id])
    @product =Product.find(params[:id])
  end

  def update
    authorize Product
    @product_type = ProductType.find(params[:product_type_id])
     @product =Product.find(params[:id])
    if @product.update(product_params)
      redirect_to product_type_path(@product_type), notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize Product
    @product_type = ProductType.find(params[:product_type_id])
     @product =Product.find(params[:id])
    if @product.destroy
      redirect_to product_type_path(@product_type), notice: 'Product was successfully deleted.'
    else
      render :show, notice: 'There was problem deleting this item.'
    end
  end
  private

  def product_params
    params.require(:product).permit(:description, :photo, :title, :asin, :sku, :color_size, :product_type_id)
  end
end
