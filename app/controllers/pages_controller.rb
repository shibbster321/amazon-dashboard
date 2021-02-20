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
      Sale.fetch_amzn_sales(params[:query][:start_date], params[:query][:end_date])
      flash.now[:notice] = 'Amzn Sales succesfully imported!'
      render "api"
    else
      flash.now[:notice] = 'Your formatting is inccorect, please try again!'
      render "api"
    end

  end

  def etsycall
    authorize Sale
    request_token = Etsy.request_token
    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to Etsy.verification_url
  end

  def etsyauthorize
    authorize Sale
    access_token = Etsy.access_token(session[:request_token], session[:request_secret], params[:oauth_verifier] )
    access = {:access_token => access_token.token, :access_secret => access_token.secret}
    response = Etsy::Request.get('/shops/BBDesignCoUS/transactions', access.merge(:limit => 10))
    # response = Etsy::Request.get('/listings/929705473/transactions')
    # access_token.token and access_token.secret can now be saved for future API calls
    hash = response.to_hash
    hash["results"].each do |sale|
      resp = Etsy::Request.get("/shops/BBDesignCoUS/receipts/#{sale['receipt_id']}/payments", access)
      net_amt = resp.to_hash["results"][0]["amount_net"].to_i
      sale_amt = net_amt / 100.00
      date = Time.at(sale["creation_tsz"]).to_datetime
      qty = sale["quantity"]
      sku = sale["product_data"]["sku"]
      order_id = sale["transaction_id"].to_s
      selling_fee = 5.00
      fba_fee = 0
      total = sale_amt
      new = Sale.new({date: date, orderid: order_id, sku: sku, qty: qty, sale_amt: sale_amt.round(2), selling_fee: selling_fee.round(2), fba_fee: fba_fee.round(2), total: total.round(2)})
      if Product.find_by(sku: new.sku)
          product = Product.find_by(sku: new.sku)
          new.product_id = product.id
          new.product_type_id = product.product_type_id
        else #if the product does not exist
          if ProductType.find_by(title: "MISC") then ptype = ProductType.find_by(title: "MISC") else ptype = ProductType.create({title: "MISC"}) end
          new.product_type_id = ptype.id
          product = Product.create({product_type_id: ptype.id, title: sale["title"], sku: new.sku, asin: "unkown", color_size: "unkown"})
          new.product_id = product.id
        end
        if new.save
          puts new.sku + " sale saved"
        else
          puts "sale already exists or other error"
        end
      end
    flash.now[:notice] = 'Etsy data succesfully imported!'
    render "api"
  end

  private


end
