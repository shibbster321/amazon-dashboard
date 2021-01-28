class Inventory < ApplicationRecord
  belongs_to :product

  validates_uniqueness_of :date, scope: :asin

end
