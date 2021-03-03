class PagesController < ApplicationController
  # skip_before_action :authenticate_Product!, only: [:home]
  after_action :verify_authorized, only: [:api, :etsycall, :etsyauthorize, :amzn]
  skip_after_action :verify_policy_scoped, only: [:home, :amzn]
  def home
  end

  def api
    authorize Sale
  end

  def amzn
    authorize Sale
    if params[:query][:start_date].match(/^\d{4}-\d{2}-\d{2}/) && params[:query][:end_date].match(/^\d{4}-\d{2}-\d{2}/)
      begin
        Sale.fetch_amzn_sales(params[:query][:start_date], params[:query][:end_date])
        redirect_to api_path, notice: "Successfully imported sales Data!"
      rescue AmazonApiService::ProcessingError
        redirect_to api_path, alert: "Error occured with processing amazon api fetch request"
      rescue CsvConverter::ProcessingError
        redirect_to api_path, alert: "Error occured with csv processing"
      end
    else
      render "api"
      flash.now[:alert] = 'Your formatting is inccorect, please try again!'
    end
  end

  def amzn_inv
    authorize Inventory
    begin
      Inventory.fetch_amzn_inventory
      redirect_to inventories_path
    rescue AmazonApiService::ProcessingError
      redirect_to api_path, alert: "Error occured with processing amazon api fetch request"
    rescue CsvConverter::ProcessingError
      redirect_to api_path, alert: "Error occured with csv processing"
    end
  end

  def etsycall
    authorize Sale
    # count = params[:query][:etsy_amt].to_i
    request_token = Etsy.request_token
    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to Etsy.verification_url
  end

  def etsyauthorize
    authorize Sale
    access_token = Etsy.access_token(session[:request_token], session[:request_secret], params[:oauth_verifier] )
    access = {:access_token => access_token.token, :access_secret => access_token.secret}
    response = Etsy::Request.get('/shops/BBDesignCoUS/transactions', access.merge(:limit => 1000))
    hash = if response.to_hash then response.to_hash else puts "problem with api call" end
    hash["results"].each do |sale|
      sale_amt = sale["price"].to_f
      date = Time.at(sale["creation_tsz"]).to_datetime
      qty = sale["quantity"]
      sku = sale["product_data"]["sku"]
      order_id = sale["transaction_id"].to_s
      store = "etsy"
      title = sale["title"].slice(0..20)
      new = Sale.new({store: store, date: date, fba_fee: 0.0, orderid: order_id, sku: sku, qty: qty, sale_amt: sale_amt })
      if Product.find_by(sku: new.sku)
        product = Product.find_by(sku: new.sku)
        new.product_id = product.id
        new.product_type_id = product.product_type_id
      else #if the product does not exist
        if ProductType.find_by(title: title) then ptype = ProductType.find_by(title: title) else ptype = ProductType.create({title: title}) end
        new.product_type_id = ptype.id
        product = Product.create({product_type_id: ptype.id, title: title, sku: new.sku, asin: "unkown", color_size: "unkown"})
        new.product_id = product.id
      end
      if new.save
        puts new.sku + " sale saved"
      else
        puts "sale already exists or other error"
      end
    end
    redirect_to api_path, notice: "Import Succesfull"
  end

  private


end
