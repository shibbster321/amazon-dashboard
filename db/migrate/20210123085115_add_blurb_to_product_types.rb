class AddBlurbToProductTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :product_types, :blurb, :string
  end
end
