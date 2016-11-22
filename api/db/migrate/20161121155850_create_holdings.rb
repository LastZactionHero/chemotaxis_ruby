class CreateHoldings < ActiveRecord::Migration[5.0]
  def change
    create_table :holdings do |t|
      t.integer :agent_id
      t.integer :stock_id
      t.float :purchase_price
      t.float :sale_price
      t.datetime :held_at

      t.timestamps
    end

    add_index :holdings, :agent_id
    add_index :holdings, :stock_id
    add_index :holdings, :held_at
  end
end
