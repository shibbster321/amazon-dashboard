class SalesController < ApplicationController
  after_action :verify_authorized, only: [:index, :subindex]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    authorize Sale
    @all_sales = Sale.order(params[:sort]).limit(10)
    @product_type_sales_list = ProductType.where(id: Sale.distinct.pluck(:product_type_id)).order(title: :desc)
    @dropdown_list = @product_type_sales_list
    # Date range
    @most_recent_date = Sale.maximum('date')
    @sales_this_week = Sale.where("date >= ?", @most_recent_date - 7.days).sum(:sale_amt)
    @sales_this_month = Sale.where("date >= ?", @most_recent_date - 30.days).sum(:sale_amt)
    @inventory_warning = Inventory.recent.where("supply_days < ?", 60).count
    @date_range = @most_recent_date - 30.days
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end

  end

  def subindex
    authorize Sale
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
