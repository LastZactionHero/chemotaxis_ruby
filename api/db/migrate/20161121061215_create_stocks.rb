class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.integer :row
      t.integer :column

      t.timestamps
    end
  end
end
