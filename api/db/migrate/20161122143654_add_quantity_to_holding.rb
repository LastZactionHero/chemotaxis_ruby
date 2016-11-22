class AddQuantityToHolding < ActiveRecord::Migration[5.0]
  def change
    add_column :holdings, :quantity, :integer
  end
end
