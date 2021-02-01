class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  require 'date'

  def home
    @products = Product.all
    @product_type = ProductType.all
    @sales = Sale.order(params[:sort])

    @most_recent_date = Sale.maximum('date')
    @last_month = @most_recent_date - 30.days
    @last_year = @most_recent_date - 1.year

    @this_month_sales = Sale.thismonth
    # @bar_data = []
    # @inventories.each do |item|
    #   @bar_data << ["#{item.product.title}-#{item.product.color_size}", item.supply_days]
    # end
  end

end
