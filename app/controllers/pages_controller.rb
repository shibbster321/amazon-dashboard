class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:etsyshow, :etsyauthorize, :home ]
  after_action :verify_authorized, only: [:index, :amzn]
  skip_after_action :verify_policy_scoped, only: :amzn
  def home

  end

  def amzn
    authorize Sale

    render "home"
  end

  def etsyshow
    Etsy.api_key = ENV["ETSY_KEY"]
    Etsy.api_secret = ENV["ETSY_SECRET"]
    Etsy.callback_url = 'http://localhost:3000/authorize'

    request_token = Etsy.request_token
    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to Etsy.verification_url
  end

  def etsyauthorize
    access_token = Etsy.access_token(session[:request_token], session[:request_secret], params[:oauth_verifier] )
    access = {:access_token => access_token.token, :access_secret => access_token.secret}
    response = Etsy::Request.get('/shops/BBDesignCoUS/transactions', access.merge(:limit => 1000))
    # response = Etsy::Request.get('/listings/929705473/transactions')
    # access_token.token and access_token.secret can now be saved for future API calls
    hash = response.to_hash
    hash["results"].each do |sale|
      date = Time.at(sale["creation_tsz"]).to_datetime
      qty = sale["quantity"]
      sku = sale["product_data"]["sku"]
      order_id = sale["transaction_id"].to_s
      sale_amt =sale["price"].to_f
      selling_fee = 5.00
      fba_fee = 0
      total = sale_amt
      new = Sale.new({date: date, orderid: order_id, sku: sku, qty: qty, sale_amt: sale_amt, selling_fee: selling_fee, fba_fee: fba_fee, total: total})
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
    flash.now[:notice] = 'Etsy sata succesfully imported!'
    render "home"
  end

  private


end
