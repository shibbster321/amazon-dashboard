require "csv"
# AmazonApiService.new(url: "/reports/2020-09-04/reports", report_type: "GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL", start_date: "2021-01-01", end_date: "2021-01-31")
# GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL

class AmazonApiService
  class ProcessingError < StandardError; end

  def initialize(attributes = {})
    @url         = attributes[:url]
    @report_type = attributes[:report_type]
    @start_date  = attributes[:start_date]
    @end_date    = attributes[:end_date]
    set_access_token
  end
  def get_all_reports
    response = Typhoeus::Request.get(
      "https://sellingpartnerapi-na.amazon.com#{@url}",
      headers: get_signed_headers_for_get_request(@url)
    )
    JSON.parse(response.body)
  end

  def get_inventory_report
    body = "{'reportType': '#{@report_type}','marketplaceIds': [#{ENV['MARKETPLACE_ID']}]}"
    #### GENERATED THE REPORT
    response = Typhoeus.post(
      "https://sellingpartnerapi-na.amazon.com#{@url}",
      headers: get_signed_headers_for_post_request(@url, body),
      body: body
    )
    report_id = JSON.parse(response.body)["payload"]["reportId"]
    puts report_id
    30.times do
      sleep 1
      print "."
    end
    ### GET THE REPORT DOCUMENT ID
    url = "https://sellingpartnerapi-na.amazon.com#{@url}/#{report_id}"
    get_report = Typhoeus.get(
      url,
      headers: get_signed_headers_for_get_request(url)
    )
    puts "got document id"

    10.times do
      sleep 1
      print "."
    end
    # check if document is created correctly
    if report_document_id = JSON.parse(get_report.body)["payload"]["processingStatus"] == "FATAL"
      puts "processing status fatal for get_report"
      raise ProcessingError
      # report_document_id = Apicall.where(type: "inventory").last.report_document_id
    else
      report_document_id = JSON.parse(get_report.body)["payload"]["reportDocumentId"]
      puts report_document_id
      ### GET THE REPORT DOCUMENT
      url = "https://sellingpartnerapi-na.amazon.com/reports/2020-09-04/documents/#{report_document_id}"
      get_report_document = Typhoeus.get(
        url,
        headers: get_signed_headers_for_get_request(url)
      )
      puts "got document"
      30.times do
        sleep 1
        print "."
      end
      # Reponse gives us report document encryption details
      get_report_document_data = JSON.parse(get_report_document.body)["payload"]
      raise ProcessingError if get_report_document_data.nil?
      cipher = OpenSSL::Cipher::AES256.new(:CBC).decrypt
      puts "getting cipher details"
      cipher.key = Base64.decode64(get_report_document_data["encryptionDetails"]["key"])
      cipher.iv = Base64.decode64(get_report_document_data["encryptionDetails"]["initializationVector"])
      encrypted_document = Typhoeus.get(get_report_document_data["url"]).body
      document = cipher.update(encrypted_document) + cipher.final
      # That gives us kind of a CSV of sale data that we need to parse
      puts "document is ciphered"
      CSV.parse(document, headers: true, row_sep: "\n", col_sep: "\t", quote_char: nil)
    end
  end
  def get_report
    body = "{'reportType': '#{@report_type}','dataStartTime': '#{@start_date}','dataEndTime': '#{@end_date}','marketplaceIds': [#{ENV['MARKETPLACE_ID']}]}"
    #### GENERATED THE REPORT
    response = Typhoeus.post(
      "https://sellingpartnerapi-na.amazon.com#{@url}",
      headers: get_signed_headers_for_post_request(@url, body),
      body: body
    )
    report_id = JSON.parse(response.body)["payload"]["reportId"]
    puts report_id
    30.times do
      sleep 1
      print "."
    end
    ### GET THE REPORT DOCUMENT ID
    url = "https://sellingpartnerapi-na.amazon.com#{@url}/#{report_id}"
    get_report = Typhoeus.get(
      url,
      headers: get_signed_headers_for_get_request(url)
    )
    puts "got document id"
    10.times do
      sleep 1
      print "."
    end
    if JSON.parse(get_report.body)["payload"]["processingStatus"] == "FATAL"
      puts "processing status fatal for get_report"
      raise ProcessingError
    else
      report_document_id = JSON.parse(get_report.body)["payload"]["reportDocumentId"]
      puts report_document_id
      url = "https://sellingpartnerapi-na.amazon.com/reports/2020-09-04/documents/#{report_document_id}"
      get_report_document = Typhoeus.get(
        url,
        headers: get_signed_headers_for_get_request(url)
      )
      puts "got document"
      10.times do
        sleep 1
        print "."
      end

      get_report_document_data = JSON.parse(get_report_document.body)["payload"]
      raise ProcessingError if get_report_document_data.nil?
      cipher = OpenSSL::Cipher::AES256.new(:CBC).decrypt
      puts "getting cipher details"
      cipher.key = Base64.decode64(get_report_document_data["encryptionDetails"]["key"])
      cipher.iv = Base64.decode64(get_report_document_data["encryptionDetails"]["initializationVector"])
      encrypted_document = Typhoeus.get(get_report_document_data["url"]).body
      document = cipher.update(encrypted_document) + cipher.final
      # That gives us kind of a CSV of sale data that we need to parse
      puts "document is ciphered"
      csv = CSV.parse(document, headers: true, row_sep: "\n", col_sep: "\t", quote_char: nil)
    end
  end

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
    def get_signed_headers_for_get_request(url)
      signer = Aws::Sigv4::Signer.new(
        service: 'execute-api',
        region: 'us-east-1',
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      )
      signature = signer.sign_request(
        http_method: 'GET',
        url: url,
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
        "x-amz-access-token" => @access_token,
        ##manually adding madketplace header
        # "[MarketplaceId]" => "#{ENV['MARKETPLACE_ID']}"
      }
      return signature.headers.merge(headers)
    end
    def get_signed_headers_for_post_request(url, body)
      signer = Aws::Sigv4::Signer.new(
        service: 'execute-api',
        region: 'us-east-1',
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      )
      signature = signer.sign_request(
        http_method: 'POST',
        url: "https://sellingpartnerapi-na.amazon.com#{@url}",
        headers: {
          "User-Agent" => "SellingPartnerAPI/1.0 (Language=Ruby)",
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Host" => "sellingpartnerapi-na.amazon.com",
        },
        body: body
      )
      headers = {
        "User-Agent" => "SellingPartnerAPI/1.0 (Language=Ruby)",
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "x-amz-access-token" => @access_token
      }
      return signature.headers.merge(headers)
    end
end
