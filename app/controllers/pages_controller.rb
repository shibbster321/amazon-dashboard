class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  require 'date'

  def home
    @all_sales = Sale.order(params[:sort]).limit(10)
    @product_type_sales_list = ProductType.where(id: Sale.distinct.pluck(:product_type_id)).order(title: :desc)
    @dropdown_list = @product_type_sales_list
    # Date range
    @most_recent_date = Sale.maximum('date')
    @date_range = @most_recent_date - 30.days
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end

    # @bar_data = []
    # @inventories.each do |item|
    #   @bar_data << ["#{item.product.title}-#{item.product.color_size}", item.supply_days]
    # end
  end

end
