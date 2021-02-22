class Sale < ApplicationRecord
  after_initialize :set_defaults, unless: :persisted?

  after_validation :round, on: [ :create, :save ]

  belongs_to :product
  belongs_to :product_type

  validates :date, uniqueness: true

  def self.thismonth
    most_recent_date = Sale.maximum('date')
    last_month = most_recent_date - 30.days
    Sale.where(["date > ? and date < ?", last_month, most_recent_date])
  end

  def self.fetch_amzn_sales(start_date, end_date)
    puts "fetching amazon sales"
    attributes = {
      url: "/reports/2020-09-04/reports",
      report_type: "GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL",
      start_date: start_date, end_date: end_date
      }
    csv = AmazonApiService.new(attributes).get_report
    puts "csv report created, now parsing"
    CsvConverter.new(csv).to_sales
  end

  def update_sale_event
    puts"updating fees"
    self.fba_fee = self.product_type.fba_fee if self.store == "amazn"
    self.cost = self.product_type.cost
    self.profit = (if self.sale_amt then self.sale_amt else 0.0 end) - (if self.cost then self.cost else 0.0 end) - (if self.fba_fee then self.fba_fee else 0.0 end)
    self.save if self.save
  end
  private
  def set_defaults
    puts "defaults set"
    self.sale_amt = 0.00 if self.sale_amt.nil?
    self.fba_fee = self.product_type.fba_fee if self.fba_fee.nil?
    self.cost = self.product_type.cost if self.cost.nil?
    self.profit = (if self.sale_amt then self.sale_amt else 0.0 end) - (if self.cost then self.cost else 0.0 end) - (if self.fba_fee then self.fba_fee else 0.0 end)
    self.profit.round(2) unless self.profit.nil?
  end
  def round
    puts "rounded"
    self.sale_amt.round(2) unless self.sale_amt.nil?
    self.cost.round(2) unless self.cost.nil?
    self.fba_fee.round(2) unless self.fba_fee.nil?
    self.profit.round(2) unless self.profit.nil?
  end

end
