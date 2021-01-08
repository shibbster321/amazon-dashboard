# frozen_string_literal: true

module AmazonConcern 
  extend ActiveSupport::Concern
  included do
    def products
      client = MWS.orders(marketplace: "US",
                          merchant_id: "isbetter")
    end
  end
end

