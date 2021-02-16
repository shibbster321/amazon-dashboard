class AmazonApiService

  def initialize(url)
    @url = url
    set_access_token
    set_signed_headers
  end
  def call
    response = Typhoeus::Request.get(
      "https://sellingpartnerapi-na.amazon.com#{@url}",
      headers: @signed_headers
    )
    JSON.parse(response.body)
  end
    def post_orders(startDate)
    response = Typhoeus.post(
      "https://sellingpartnerapi-na.amazon.com#{@url}",
      headers: @signed_headers,
      body: {"reportType" => "GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL", "dataStartTime" => startDate, "marketplaceIds" => ENV["MARKETPLACE_ID"]}
    )
    JSON.parse(response.body)
  end
# 2021-02-10T20:55:23+0000
# GET_FLAT_FILE_ALL_ORDERS_DATA_BY_ORDER_DATE_GENERAL
# GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL
# GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_SALES_DATA
# GET_AFN_INVENTORY_DATA
# GET_FBA_FULFILLMENT_CURRENT_INVENTORY_DATA
  private
    def set_access_token
      get_access_token_response = Typhoeus.post(
        "https://api.amazon.com/auth/o2/token",
        body: {
          grant_type: "refresh_token",
          refresh_token: ENV["AWS_REFRESH_TOKEN"],
          client_id: ENV["AWS_CLIENT_ID"],
          client_secret: ENV["AWS_CLIENT_SECRET"]
        },
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8"
        }
      )
      @access_token = JSON.parse(get_access_token_response.body)["access_token"]
    end
    def set_signed_headers
      signature = Aws::Sigv4::Signer.new(
        service: 'execute-api',
        region: 'us-east-1',
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      ).sign_request(
        http_method: 'POST',
        url: "https://sellingpartnerapi-na.amazon.com#{@url}",
        headers: {
          "User-Agent" => "SellingPartnerAPI/1.0 (Language=Ruby)",
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Host" => "sellingpartnerapi-na.amazon.com",
        }
      )
      headers = {
        "User-Agent" => "SellingPartnerAPI/1.0 (Language=Ruby)",
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "x-amz-access-token" => @access_token
      }
      @signed_headers = signature.headers.merge(headers)
    end
end
