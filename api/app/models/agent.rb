# == Schema Information
#
# Table name: agents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cash       :float
#

class Agent < ApplicationRecord
  class InsufficientCashError < StandardError
  end

  class NoMovesAvailableError < StandardError
  end

  has_many :holdings

  def stock
    current_holding ? current_holding.stock : nil
  end

  def current_holding
    holding = holdings.latest
    holding.present? ? holding : nil
  end

  def purchase(stock)
    cash_after_sale = value

    quantity = (cash_after_sale / stock.value).to_i # Purchase the maximum amount possible
    raise InsufficientCashError unless quantity > 0

    # Sell the current Holding, if present
    current_holding.update_attribute(:sale_price, current_holding.stock.value) if current_holding

    holding = Holding.create(
      stock: stock,
      agent: self,
      held_at: DateTime.now,
      purchase_price: stock.value,
      quantity: quantity)

    update_attribute(:cash, cash_after_sale - holding.value )
  end

  def move
    raise StandardError unless stock

    adjacent_stocks = stock.adjacent.to_a.shuffle! # Randomize the array of nearby Stocks

    adjacent_stocks.each do |adjacent_stock|
      if adjacent_stock.value <= value # Can we purchase this?
        purchase(adjacent_stock)
        return
      end
    end

    # If we fall through to here, there was nothing affordable to buy
    raise NoMovesAvailableError
  end

  def last_prices(quote_count)
    stock.stock_values.order('quoted_at DESC').limit(quote_count).pluck(:value)
  end

  def direction(quote_count)
    prices = last_prices(quote_count)
    delta = prices.last - prices.first
    delta > 0 ? :up : delta < 0 ? :down : :equal
  end

  def value
    total_value = cash
    total_value += current_holding.value if current_holding
    total_value
  end


end
