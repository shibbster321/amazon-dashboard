class AddLeadTimeToProductType < ActiveRecord::Migration[6.0]
  def change
    add_column :product_types, :lead_time, :integer
  end
end
