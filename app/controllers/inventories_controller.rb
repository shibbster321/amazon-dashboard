class InventoriesController < ApplicationController
  after_action :verify_authorized, only: [:index, :subindex]
  skip_after_action :verify_policy_scoped, only: :index
  def index
    authorize Inventory
    @dropdown_list = ProductType.all
    @inventories = Inventory.recent.order(params[:sort])
    @product_type = ProductType.all

    @bar_data = []
    @inventories.each do |item|
      @bar_data << ["#{item.product.title[0..15]}-#{item.product.color_size}", item.supply_days]
    end

    # data for sales by store
    date_recent = Inventory.recent.first.date
    locations = ["amazon", "etsy", "avid"]
    @location_data = []
    locations.each do |location|
      inventories_store = @inventories.where("location = ?", location)
      item_array_data =[]
      inventories_store.each do |item|
        item_array_data << ["#{item.product.title[0..15]}-#{item.product.color_size}", item.available ]
      end
      @location_data << {name: location, data: item_array_data }
    end

  end

  def subindex
    authorize Inventory
    @parentlist = ProductType.all
    @product_type = ProductType.find(params[:product_type_id])
    children = Product.where(product_type_id: @product_type.id).ids
    @inventories = Inventory.recent.where(product_id: children).order(params[:sort])
    @bar_data = []
    @inventories.each do |item|
      @bar_data << ["#{item.product.color_size}", item.supply_days]
    end
    # data for sales by store
    date_recent = Inventory.recent.first.date
    locations = ["amazon", "etsy", "avid"]
    @location_data = []
    locations.each do |location|
      inventories_store = @inventories.where("location = ?", location)
      item_array_data =[]
      inventories_store.each do |item|
        item_array_data << [item.product.color_size, item.available ]
      end
      @location_data << {name: location, data: item_array_data }
    end
  end
  private

end
