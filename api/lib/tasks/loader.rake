require 'csv'

namespace :loader do
  desc 'Load Stock Symbol Grid CSV'
  task :symbol_grid => :environment do
    rows = CSV.read("#{Rails.root}/sp500_symbol_grid.csv")
    rows.each_with_index do |row, row_idx|
      row.each_with_index do |symbol, column_idx|
        puts symbol
        Stock.create!({
          symbol: symbol,
          row: row_idx,
          column: column_idx
        })
      end
    end
  end
end
