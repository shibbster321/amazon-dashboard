class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  require 'date'

  def home
    @products = Product.all
    @product_type = ProductType.all
    @sales = Sale.order(params[:sort])

    @most_recent_date = Sale.maximum('date')
    @date_range = @most_recent_date - 30.days
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] != "year"
      @date_range = @most_recent_date - 30.days
    end
    @product_type_sales = ProductType.where(id: Sale.distinct.pluck(:product_type_id))
    @this_month_sales = Sale.thismonth
    # @bar_data = []
    # @inventories.each do |item|
    #   @bar_data << ["#{item.product.title}-#{item.product.color_size}", item.supply_days]
    # end
  end

end
