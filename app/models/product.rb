class Product < ApplicationRecord
  belongs_to :product_type
  has_one_attached :photo

  validates :asin, uniqueness: true
  validates :sku, uniqueness: true
  validates :product_type_id, presence: true
end
