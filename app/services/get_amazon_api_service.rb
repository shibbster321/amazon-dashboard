require 'open-uri'
require "peddler"

export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
client = MWS.orders(marketplace: "ATVPDKIKX0DER",
                    merchant_id: "123")

class GetAmazonApiService

  def initialize()

  end

  def call
  end
end
