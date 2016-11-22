# == Schema Information
#
# Table name: stock_values
#
#  id         :integer          not null, primary key
#  stock_id   :integer
#  value      :float
#  quoted_at  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stock_values_on_quoted_at  (quoted_at)
#  index_stock_values_on_stock_id   (stock_id)
#

class StockValue < ApplicationRecord
  belongs_to :stock
  scope :latest, -> { order('quoted_at DESC').first }
end
