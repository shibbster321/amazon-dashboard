class ProductType < ApplicationRecord
    has_many :products, :dependent => :destroy
    has_one_attached :photo
    validates :title, uniqueness: true
end
