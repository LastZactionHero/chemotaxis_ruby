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

FactoryGirl.define do
  factory :stock_value do
    stock_id 1
    value 1.5
    quoted_at "2016-11-21 06:21:38"
  end
end
