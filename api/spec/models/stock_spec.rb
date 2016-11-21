# == Schema Information
#
# Table name: stocks
#
#  id         :integer          not null, primary key
#  symbol     :string
#  row        :integer
#  column     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'adjacent' do
    it 'returns an array of adjacent stocks' do
      (0..4).each do |row_idx|
        (0..4).each do |column_idx|
          FactoryGirl.create(:stock, row: row_idx, column: column_idx)
        end
      end

      Stock.all.each do |stock|
        stock.adjacent.each do |adjacent_stock|
          expect(adjacent_stock.row).to be_within(1).of(stock.row)
          expect(adjacent_stock.column).to be_within(1).of(stock.column)
          expect(adjacent_stock.id).not_to eq(stock.id)
        end
      end
    end
  end
end
