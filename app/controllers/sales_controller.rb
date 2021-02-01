class SalesController < ApplicationController

  def index

  end

  def subindex
    @parentlist = ProductType.all
    product_type = ProductType.find(params[:product_type_id])
    children = Product.where(product_type_id: product_type.id).ids
    @this_month_sales = Sale.thismonth.where(product_id: children).order(params[:sort])

    @bar_data = []
    # @inventories.each do |item|
    #   @bar_data << ["#{item.product.color_size}", item.supply_days]
    # end
  end

end
