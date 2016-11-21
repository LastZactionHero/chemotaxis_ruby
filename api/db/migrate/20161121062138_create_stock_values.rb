class CreateStockValues < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_values do |t|
      t.integer :stock_id
      t.float :value
      t.datetime :quoted_at

      t.timestamps
    end

    add_index :stock_values, :stock_id
    add_index :stock_values, :quoted_at
  end
end
