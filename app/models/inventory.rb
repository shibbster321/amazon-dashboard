class Inventory < ApplicationRecord
  belongs_to :product

  validates_uniqueness_of :date, scope: :asin

  def self.recent
    max_date = Inventory.maximum('date')
    Inventory.where(date: max_date)
  end

end
