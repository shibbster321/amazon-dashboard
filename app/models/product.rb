class Product < ApplicationRecord
  belongs_to :product_type
  has_one_attached :photo
  has_many :inventories, :dependent => :destroy
  has_many :sales, :dependent => :destroy

  validates :sku, uniqueness: true
  validates :product_type_id, presence: true
end
