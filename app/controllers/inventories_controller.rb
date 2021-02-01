class InventoriesController < ApplicationController

  def index
    @parentlist = ProductType.all
    @inventories = Inventory.recent.order(params[:sort])
    @product_type = ProductType.all

    @bar_data = []
    @inventories.each do |item|
      @bar_data << ["#{item.product.title}-#{item.product.color_size}", item.supply_days]
    end
  end

  def subindex
    @parentlist = ProductType.all
    product_type = ProductType.find(params[:product_type_id])
    children = Product.where(product_type_id: product_type.id).ids
    @inventories = Inventory.recent.where(product_id: children).order(params[:sort])

    @bar_data = []
    @inventories.each do |item|
      @bar_data << ["#{item.product.color_size}", item.supply_days]
    end
  end

  private

end
