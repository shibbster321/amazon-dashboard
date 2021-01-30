class InventoriesController < ApplicationController

  def index
    @parentlist = ProductType.all
    @inventories = Inventory.recent.order(params[:sort])
    @product_type = ProductType.all


  end

  def show
    @parentlist = ProductType.all
    product_type = ProductType.find(params[:id])
    children = Product.where(product_type_id: product_type.id).ids
    @inventories = Inventory.recent.where(product_id: children).order(params[:sort])

  end

  private

end
