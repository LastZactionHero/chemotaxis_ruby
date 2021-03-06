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

class Stock < ApplicationRecord
  validates :symbol, uniqueness: true

  has_many :stock_values

  def value
    stock_values.latest.value
  end

  def adjacent
    Stock.where('row >= ? AND row <= ? AND stocks.column >= ? AND stocks.column <= ? AND id != ?',
                  row - 1,
                  row + 1,
                  column - 1,
                  column + 1,
                  id)
  end
end
