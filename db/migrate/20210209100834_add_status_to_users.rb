class AddStatusToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :string, default: "pending"
  end
end
