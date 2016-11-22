# == Schema Information
#
# Table name: holdings
#
#  id             :integer          not null, primary key
#  agent_id       :integer
#  stock_id       :integer
#  purchase_price :float
#  sale_price     :float
#  held_at        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_holdings_on_agent_id  (agent_id)
#  index_holdings_on_held_at   (held_at)
#  index_holdings_on_stock_id  (stock_id)
#

class Holding < ApplicationRecord
  belongs_to :stock
  belongs_to :agent

  scope :latest, -> { order('held_at DESC').first }
end
