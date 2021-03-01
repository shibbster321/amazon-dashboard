class Sale < ApplicationRecord
  before_save :set_defaults, unless: :persisted?

  before_save :round

  belongs_to :product
  belongs_to :product_type

  validates :date, uniqueness: true

  def self.thismonth
    most_recent_date = Sale.maximum('date')
    last_month = most_recent_date - 30.days
    Sale.where(["date > ? and date < ?", last_month, most_recent_date])
  end
  def self.weekly_sale_of(product_id)
    if Product.find_by_id(product_id)
      product = Product.find_by_id(product_id)
      most_recent_date = Sale.where(product_id: product.id).maximum('date') if Sale.where(product_id: product.id).maximum('date')
      sale = Sale.where("date >= ? and product_id = ?", most_recent_date - 7.days, product.id).count if Sale.where("date >= ? and product_id = ?", most_recent_date - 7.days, product.id).count
    else
      puts "not a product id"
    end
  end
  def self.fetch_amzn_sales(start_date, end_date)
    puts "fetching amazon sales"
    attributes = {
      url: "/reports/2020-09-04/reports",
      report_type: "GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL",
      start_date: start_date, end_date: end_date
      }
    csv = AmazonApiService.new(attributes).get_report
    CsvConverter.new(csv).to_sales if csv
  end

  def update_sale_event
    puts"updating fees"
    self.fba_fee = if self.product_type.fba_fee && self.qty && self.store == "amazon" then (self.product_type.fba_fee * self.qty) else 0.00 end
    self.cost = if self.product_type.cost && self.qty then (self.product_type.cost * self.qty) else 0.00 end
    self.profit = (if self.sale_amt then self.sale_amt else 0.0 end) - (if self.cost then self.cost else 0.0 end) - (if self.fba_fee then self.fba_fee else 0.0 end)
    self.save
  end
  private
  def set_defaults
    puts "defaults set"
    self.sale_amt = 0.00 if self.sale_amt.nil?
    self.fba_fee = if self.product_type.fba_fee && self.qty && self.store == "amazon" then (self.product_type.fba_fee * self.qty) else 0.00 end
    self.cost = if self.product_type.cost && self.qty then (self.product_type.cost * self.qty) else 0.00 end
    self.profit = (if self.sale_amt then self.sale_amt else 0.0 end) - (if self.cost then self.cost else 0.0 end) - (if self.fba_fee then self.fba_fee else 0.0 end)
  end
  def round
    puts "rounded"
    self.sale_amt.round(2) unless self.sale_amt.nil?
    self.cost.round(2) unless self.cost.nil?
    self.fba_fee.round(2) unless self.fba_fee.nil?
    self.profit.round(2) unless self.profit.nil?
  end

end
