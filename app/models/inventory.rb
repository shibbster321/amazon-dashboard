class Inventory < ApplicationRecord
  belongs_to :product
  belongs_to :product_type

  validates_uniqueness_of :date, scope: :asin

  def self.recent
    most_recent_date = Inventory.maximum('date')
    Inventory.where(date: most_recent_date)
  end

end
