class ProductType < ApplicationRecord
  # The set_defaults will only work if the object is new
  after_initialize :set_defaults, unless: :persisted?

  after_validation :round, on: [ :create, :update ]


  has_many :products, :dependent => :destroy
  has_one_attached :photo
  validates :title, uniqueness: true
  has_many :sales, :dependent => :destroy

  private

  def set_defaults
    self.fba_fee = 0.00 if self.fba_fee.nil?
    self.cost = 0.00 if self.cost.nil?
    self.lead_time = 14 if self.lead_time.nil?
  end

  def round
    self.fba_fee.round(2) unless self.fba_fee.nil?
    self.cost.round(2) unless self.cost.nil?
  end
end
