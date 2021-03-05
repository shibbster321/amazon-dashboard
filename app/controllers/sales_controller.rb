class SalesController < ApplicationController
  after_action :verify_authorized, only: [:index, :subindex, :destroy, :edit_data]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    authorize Sale
    @all_sales = Sale.order("date DESC").limit(10)
    @product_type_sales_list = ProductType.where(id: Sale.distinct.pluck(:product_type_id)).order(title: :desc)
    @store_list = ["all", "amazon", "etsy"]
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
    # set date range for charts
    @date_range = @most_recent_date - 30.days
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end

    # data for sales by store
    stores = ["etsy", "amazon"]
    @store_data = []
    stores.each do |store|
      @store_data << { name: store, data: Sale.where("date >= ? and store = ?", @date_range, store).group_by_week(:date).sum(:sale_amt).to_a }
    end

    # data for sales by accounting
    @accounting_data = [
    {name: "Mfg Cost", data: Sale.where("date >= ?", @date_range).group_by_week(:date).sum(:cost).to_a },
    {name: "FBA Fee", data: Sale.where("date >= ?", @date_range).group_by_week(:date).sum(:fba_fee).to_a },
    {name: "Profit", data: Sale.where("date >= ?", @date_range).group_by_week(:date).sum(:profit).to_a}
    ]
    # data for sales by product
    @stacked_data = []
    @store = "All"
    @product_type_sales_list.each do |ptype|
      if params[:filter] == "amazon"
        @stacked_data << { name: ptype.title, data: ptype.sales.where("date >= ? and store = ?", @date_range, "amazon").group_by_week(:date).sum(:sale_amt).to_a }
        @store = "Amazon"
      elsif params[:filter] == "etsy"
        @stacked_data << { name: ptype.title, data: ptype.sales.where("date >= ? and store = ?", @date_range, "etsy").group_by_week(:date).sum(:sale_amt).to_a }
        @store = "Etsy"
      else
        @stacked_data << { name: ptype.title, data: ptype.sales.where("date >= ?", @date_range).group_by_week(:date).sum(:sale_amt).to_a }
        @store = "All"
      end
    end

  end

  def subindex
    authorize Sale
    @most_recent_date = Sale.maximum('date')
    @date_range = @most_recent_date - 30.days

    @product_type_sales_list = ProductType.where(id: Sale.distinct.pluck(:product_type_id)).order(title: :desc)
    @store_list = ["all", "amazon", "etsy"]

    @product_type = ProductType.find(params[:product_type_id])

    @inventory_warning = 0
      Inventory.recent.each do |inventory|
      if inventory.supply_days < (@product_type.lead_time ? @product_type.lead_time : 0) && inventory.product.product_type == @product_type
        @inventory_warning +=1
      end
    end
    @sales_this_week = Sale.where("date >= ? and product_type_id = ?", @most_recent_date - 7.days, @product_type.id).sum(:sale_amt)
    @sales_this_month = Sale.where("date >= ? and product_type_id = ?", @most_recent_date - 30.days, @product_type.id).sum(:sale_amt)

    @stacked_data = []
    @product_sales_list = Product.where(product_type_id: @product_type.id).order(title: :desc)
    @store = "All"
    @product_sales_list.each do |product|
      if params[:filter] == "amazon"
        @stacked_data << { name: product.color_size, data: product.sales.where("date >= ? and store = ?", @date_range, "amazon").group_by_week(:date).sum(:qty).to_a }
        @store = "Amazon"
      elsif params[:filter] == "etsy"
        @stacked_data << { name: product.color_size, data: product.sales.where("date >= ? and store = ?", @date_range, "etsy").group_by_week(:date).sum(:qty).to_a }
        @store = "Etsy"
      else
        @stacked_data << { name: product.color_size, data: product.sales.where("date >= ?", @date_range).group_by_week(:date).sum(:qty).to_a }
        @store = "All"
      end
    end

    @all_sales = Sale.order(params[:sort]).where(product_type: @product_type.id).order("date DESC").limit(10)
    # Date range
    if params[:range] == "year"
      @date_range = @most_recent_date - 1.year
    elsif params[:range] == "month"
      @date_range = @most_recent_date - 30.days
    end
  end

  def edit_data
    authorize Sale
  end

  def destroy_data
    authorize Sale
      if params[:query][:start_date].match(/^\d{4}-\d{2}-\d{2}/) && params[:query][:end_date].match(/^\d{4}-\d{2}-\d{2}/)
        if ["amazon", "etsy"].include? params[:query][:store]
          flash.now[:notice] = 'This may take a minute...'
          Sale.where("date >= ? and date <= ? and store = ?", params[:query][:start_date],params[:query][:end_date],params[:query][:store]).destroy_all
          redirect_to edit_data_path
          flash.now[:alert] = 'Data deleted succesfully'
        else
          flash.now[:alert] = 'You must choose a store source for the Data'
          render "edit_data"
        end
    else
      flash.now[:alert] = 'Your formatting is inccorect, please try again!'
      render "edit_data"
    end

  end

  private


end
