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

FactoryGirl.define do
  factory :stock do
    symbol {SecureRandom.hex(3)}
    row 1
    column 1
  end
end
