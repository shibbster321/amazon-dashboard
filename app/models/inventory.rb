class Inventory < ApplicationRecord
  belongs_to :product

  validates_uniqueness_of :date, scope: [:sku, :location]

  def self.recent
    most_recent_date = Inventory.maximum('date')
    Inventory.where(date: most_recent_date)
  end

  def self.fetch_amzn_inventory
    # attributes = {url: "/reports/2020-09-04/reports", report_type: "GET_AFN_INVENTORY_DATA"}
      attributes = {url: "/fba/inventory/v1/summaries"}
      # start_date: "2021-01-01", end_date: "2021-01-31"
    csv = AmazonApiService.new(attributes).get_inventory

    # CsvConverter.new(csv).to_sales
  end
end

