require 'rails_helper'

RSpec.describe Holding, type: :model do
  describe 'value' do
    it 'returns the total value of the holding' do
      stock_value = 150
      quantity = 3

      stock = FactoryGirl.build(:stock)
      stock.stub(:value).and_return(stock_value)

      holding = FactoryGirl.build(:holding, quantity: quantity, stock: stock)

      expect(holding.value).to eq(stock_value * quantity)
    end
  end
end
