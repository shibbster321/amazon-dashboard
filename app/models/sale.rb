class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :product_type

  validates :date, uniqueness: true

  def self.thismonth
    most_recent_date = Sale.maximum('date')
    last_month = most_recent_date - 30.days
    Sale.where(["date > ? and date < ?", last_month, most_recent_date])
  end
end
