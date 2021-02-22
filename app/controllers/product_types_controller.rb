class ProductTypesController < ApplicationController
  after_action :verify_authorized, only: [:index, :new, :create, :edit, :update, :destroy]
  skip_after_action :verify_policy_scoped, only: :index
  def index
    authorize ProductType
    @product_types = ProductType.order(params[:sort])
  end

  def new
    authorize ProductType
    @product_type = ProductType.new
  end

  def create
    authorize ProductType
     @product_type = ProductType.new(product_type_params)
    if @product_type.save
      @product_type.save
      update_sale_fee_data(@product_type)
      redirect_to new_product_type_product_path(@product_type)
    else
      render :new
    end
  end

  def show
    authorize ProductType
    @product_type = find_product_type_instance
    @products = @product_type.products
  end

  def edit
    authorize ProductType
    @product_type = ProductType.find(params[:id])

  end

  def update
    authorize ProductType
    @product_type = ProductType.find(params[:id])
    if @product_type.update(product_type_params)
      update_sale_fee_data(@product_type)
      redirect_to product_types_path, notice: 'Parent product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize ProductType
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
    params.require(:product_type).permit(:title, :cost, :fba_fee, :lead_time, :photo)
  end

  def update_sale_fee_data(ptype)
    array = Sale.where("product_type_id = ?", ptype.id )
    array.each do |sale|
      sale.update_sale_event
    end
  end
end
