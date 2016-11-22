# == Schema Information
#
# Table name: agents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Agent < ApplicationRecord
  has_many :holdings

  def stock
    current_holding ? current_holding.stock : nil
  end

  def current_holding
    holding = holdings.latest
    holding.present? ? holding : nil
  end

  def purchase(stock)
    current_holding.update_attribute(:sale_price, current_holding.stock.value) if current_holding

    Holding.create(
      stock: stock,
      agent: self,
      held_at: DateTime.now,
      purchase_price: stock.value)
  end

  def move
    raise StandardError unless stock

    adjacent_stocks = stock.adjacent
    purchase(adjacent_stocks.sample)
  end

  def last_prices(quote_count)
    stock.stock_values.order('quoted_at DESC').limit(quote_count).pluck(:value)
  end

  def direction(quote_count)
    prices = last_prices(quote_count)
    delta = prices.last - prices.first
    delta > 0 ? :up : delta < 0 ? :down : :equal
  end


end
