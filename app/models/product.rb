class Product < ApplicationRecord
  belongs_to :product_type
  has_one_attached :photo
  has_many :inventories, :dependent => :destroy
  has_many :sales, :dependent => :destroy

  validates :sku, uniqueness: true
  validates :product_type_id, presence: true

  def self.fetch_product_details
    attributes = {url: "/catalog/v0/items"}
      # start_date: "2021-01-01", end_date: "2021-01-31"
    csv = AmazonApiService.new(attributes).get_products

    # CsvConverter.new(csv).to_sales
  end

end
