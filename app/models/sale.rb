class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :product_type

  validates :date, uniqueness: true

  def self.thismonth
    most_recent_date = Sale.maximum('date')
    last_month = most_recent_date - 30.days
    Sale.where(["date > ? and date < ?", last_month, most_recent_date])
  end

  def self.fetch_amzn_sales(start_date, end_date)
    attributes = {
      url: "/reports/2020-09-04/reports",
      report_type: "GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL",
      start_date: start_date, end_date: end_date
      }
    csv = AmazonApiService.new(attributes).get_report
    CsvConverter.new(csv).to_sales
  end



end
