class Inventory < ApplicationRecord
  belongs_to :product

  validates_uniqueness_of :date, scope: [:sku, :location]

  def self.recent
    most_recent_date = Inventory.maximum('date')
    Inventory.where(date: most_recent_date)
  end

  def self.fetch_amzn_inventory
    attributes = {url: "/reports/2020-09-04/reports", report_type: "GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA"}
    csv = AmazonApiService.new(attributes).get_inventory_report
    CsvConverter.new(csv).to_inventory if csv
  end
end

