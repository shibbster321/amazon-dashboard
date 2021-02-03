class SalesController < ApplicationController

  def index

  end

  def subindex
    @product_type = ProductType.find(params[:product_type_id])
    @all_sales = Sale.order(params[:sort]).where(product_type: @product_type.id).limit(10)
    @product_sales_list = Product.where(id: Sale.where(product_type: @product_type.id).distinct.pluck(:product_id)).order(title: :desc)
    @dropdown_list = @product_sales_list
    # Date range
    @most_recent_date = Sale.maximum('date')
    @date_range = @most_recent_date - 30.days
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end
  end

end
