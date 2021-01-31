class Sale < ApplicationRecord
  belongs_to :product
  belongs_to :product_type

  validates :date, uniqueness: true
end
