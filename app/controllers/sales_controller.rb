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
    @inventory_warning = 0
      Inventory.recent.each do |inventory|
      ptype = inventory.product.product_type
      if inventory.supply_days < ptype.lead_time
        @inventory_warning +=1
      end
    end

    @date_range = @most_recent_date - 30.days
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end

    @stacked_data = []
    @product_type_sales_list.each do |ptype|
      @stacked_data << { name: ptype.title, data: ptype.sales.where("date >= ?", @date_range).group_by_week(:date).sum(:sale_amt).to_a }
    end


  end

  def subindex
    authorize Sale
    @most_recent_date = Sale.maximum('date')
    @date_range = @most_recent_date - 30.days

    @product_type_sales_list = ProductType.where(id: Sale.distinct.pluck(:product_type_id)).order(title: :desc)
    @dropdown_list = @product_type_sales_list

    @product_type = ProductType.find(params[:product_type_id])

    @inventory_warning = 0
      Inventory.recent.each do |inventory|
      if inventory.supply_days < @product_type.lead_time && inventory.product.product_type == @product_type
        @inventory_warning +=1
      end
    end
    @sales_this_week = Sale.where("date >= ? and product_type_id = ?", @most_recent_date - 7.days, @product_type.id).sum(:sale_amt)
    @sales_this_month = Sale.where("date >= ? and product_type_id = ?", @most_recent_date - 30.days, @product_type.id).sum(:sale_amt)

    @stacked_data = []
    @product_sales_list = Product.where(product_type_id: @product_type.id).order(title: :desc)
    @product_sales_list.each do |product|
      @stacked_data << { name: product.color_size, data: product.sales.where("date >= ?", @date_range).group_by_week(:date).sum(:sale_amt).to_a }
    end

    @all_sales = Sale.order(params[:sort]).where(product_type: @product_type.id).limit(10)

    # Date range
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end
  end

end
