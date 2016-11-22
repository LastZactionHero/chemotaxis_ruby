class AddCashAvailableToAgent < ActiveRecord::Migration[5.0]
  def change
    add_column :agents, :cash, :float
  end
end
