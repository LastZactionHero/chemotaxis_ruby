require 'rails_helper'

RSpec.describe Agent, type: :model do
  describe 'purchase' do
    let(:agent){FactoryGirl.create(:agent)}

    let(:first_stock){FactoryGirl.create(:stock)}
    let(:first_stock_value){FactoryGirl.create(:stock_value, stock: first_stock, value: agent.cash / 2)}
    let(:second_stock){FactoryGirl.create(:stock)}
    let(:second_stock_value){FactoryGirl.create(:stock_value, stock: second_stock, value: agent.cash)}

    it 'creates a holding for the stock' do
      expect(Holding.count).to eq(0) # Assumption

      stock = FactoryGirl.create(:stock)
      stock.stub(:value).and_return(100)

      date = 1.month.ago
      travel_to date do
        agent.purchase(stock)

        expect(Holding.count).to eq(1)
        holding = Holding.first
        expect(holding.agent).to eq(agent)
        expect(holding.held_at).to be_within(1.second).of(date)
        expect(holding.purchase_price).to eq(100)
        expect(holding.stock).to eq(stock)
        expect(holding.quantity).to eq(1)
      end
    end

    it 'sets the sale price of the current Holding' do
      agent_starting_cash = agent.cash

      first_holding = FactoryGirl.create(:holding, agent: agent, stock: first_stock)
      first_stock_value; second_stock_value

      agent.purchase(second_stock)
      expect(first_holding.reload.sale_price).to eq(agent_starting_cash / 2)
    end

    it 'subtracts cash from the new holding' do
      first_stock_value.update_attribute(:value, 200)
      agent.update_attribute(:cash, first_stock_value.value + 2)

      agent.purchase(first_stock)
      expect(agent.cash).to eq(2)
    end

    it 'adds cash from the sold holding' do
      second_stock_value.update_attribute(:value, 100)
      agent.update_attribute(:cash, 102) # Has enough cash on hand to purchase one share of the Stock, with a bit left over

      # Also owns two shares of a different Stock. Together with it's cash on hand, it should be able to purchase 3
      # Shares of the new stock
      first_stock_value.update_attribute(:value, 100)
      holding = FactoryGirl.create(:holding, agent: agent, stock: first_stock, quantity: 2)

      agent.purchase(second_stock)
      expect(agent.cash).to eq(2) # Still has $2 left over
      expect(agent.current_holding.quantity).to eq(3) # Was able to puchase 3 shares
    end

    it 'purchases the maximum amount of the Stock possible with cash available' do
      expect(Holding.count).to eq(0) # Assumption

      stock = FactoryGirl.create(:stock)
      stock_value = FactoryGirl.create(:stock_value, stock: stock, value: 100)

      agent.update_attribute(:cash, stock.value * 3)

      agent.purchase(stock)

      holding = Holding.first
      expect(holding.quantity).to eq(3)
    end

    it 'raises an exception if it does not have enough cash available to purchase any of the Stock' do
      stock = FactoryGirl.create(:stock)
      stock_value = FactoryGirl.create(:stock_value, stock: stock, value: 100)

      agent.update_attribute(:cash, 50)

      expect{agent.purchase(stock)}.to raise_error(Agent::InsufficientCashError)
    end
  end

  describe 'stock' do
    let(:agent){FactoryGirl.create(:agent)}

    it 'returns nil if there are no Holdings' do
      expect(agent.stock).to be_nil
    end

    it 'returns the Stock from the most recent Holding' do
      stock_first = FactoryGirl.create(:stock)
      stock_last = FactoryGirl.create(:stock)

      holding_first = FactoryGirl.create(:holding, agent: agent, stock: stock_first, held_at: 10.minutes.ago)
      holding_last = FactoryGirl.create(:holding, agent: agent, stock: stock_last, held_at: 5.minutes.ago)

      expect(agent.stock).to eq(holding_last.stock)
    end
  end

  describe 'move' do
    let(:agent){FactoryGirl.create(:agent)}

    it 'raises an exception if there is no current stock' do
      expect{agent.move}.to raise_error(StandardError)
    end

    it 'purchases an adjacent stock' do
      current_stock = FactoryGirl.create(:stock)
      adjacent_stock = FactoryGirl.create(:stock)
      non_adjacent_stock = FactoryGirl.create(:stock)

      Stock.any_instance.stub(:value).and_return(100)
      Stock.any_instance.stub(:adjacent).and_return(Stock.where(id: adjacent_stock.id))

      agent.purchase(current_stock)

      # Expect the Agent to move to the only adjacent Stock
      agent.move
      expect(agent.reload.stock).to eq(adjacent_stock)
    end

    it 'only purchases affordable stocks' do
      current_stock = FactoryGirl.create(:stock)
      FactoryGirl.create(:stock_value, stock: current_stock, value: 10)

      # Lots of Stocks cost too much to purchase
      unaffordable_stock_a = FactoryGirl.create(:stock)
      unaffordable_stock_a.stub(:value).and_return(1000)

      unaffordable_stock_b = FactoryGirl.create(:stock)
      unaffordable_stock_b.stub(:value).and_return(1000)

      unaffordable_stock_c = FactoryGirl.create(:stock)
      unaffordable_stock_c.stub(:value).and_return(1000)

      # Only one stock is cheap enough to buy
      affordable_stock_d = FactoryGirl.create(:stock)
      affordable_stock_d.stub(:value).and_return(agent.cash)

      Stock.any_instance.stub(:adjacent).and_return([unaffordable_stock_a, unaffordable_stock_b, unaffordable_stock_c, affordable_stock_d])

      # Expect the Agent to move to the only affordable stock.
      agent.purchase(current_stock)
      agent.move
      expect(agent.reload.stock).to eq(affordable_stock_d)
    end

    it 'raises an exception if no affordable moves are available' do
      current_stock = FactoryGirl.create(:stock)
      FactoryGirl.create(:stock_value, stock: current_stock, value: 10)

      # Only adjacent Stock costs too much
      unaffordable_stock_a = FactoryGirl.create(:stock)
      unaffordable_stock_a.stub(:value).and_return(1000)


      Stock.any_instance.stub(:adjacent).and_return([unaffordable_stock_a])

      # Expect the Agent to move to the only affordable stock.
      agent.purchase(current_stock)
      expect{agent.move}.to raise_error(Agent::NoMovesAvailableError)
    end

  end

  describe 'last_prices' do
    let(:agent){FactoryGirl.create(:agent)}

    it 'recalls the latest N prices of the current holding' do
      stock = FactoryGirl.create(:stock)

      # Order is scrambled chronologically
      stock_value_a = FactoryGirl.create(:stock_value, stock: stock, quoted_at: 30.minutes.ago, value: 100)
      stock_value_d = FactoryGirl.create(:stock_value, stock: stock, quoted_at: 27.minutes.ago, value: 400)
      stock_value_c = FactoryGirl.create(:stock_value, stock: stock, quoted_at: 28.minutes.ago, value: 300)
      stock_value_e = FactoryGirl.create(:stock_value, stock: stock, quoted_at: 26.minutes.ago, value: 500)
      stock_value_b = FactoryGirl.create(:stock_value, stock: stock, quoted_at: 29.minutes.ago, value: 200)

      holding = FactoryGirl.create(:holding, agent: agent, stock: stock)
      expect(agent.last_prices(3)).to eq([500, 400, 300])
    end
  end

  describe 'direction' do
    let(:agent){FactoryGirl.create(:agent)}

    it 'returns :up if the latest prices are trending upward' do
      agent.stub(:last_prices).and_return([100,200,150,125,300])
      expect(agent.direction(5)).to eq(:up)
    end

    it 'returns :down if the latest prices are trending downward' do
      agent.stub(:last_prices).and_return([300,125,150,200,100])
      expect(agent.direction(5)).to eq(:down)
    end

    it 'returns :equal if the latest prices are not changing' do
      agent.stub(:last_prices).and_return([300,125,125,300])
      expect(agent.direction(5)).to eq(:equal)
    end
  end

  describe 'value' do
    let(:cash_value){200}
    let(:agent){FactoryGirl.create(:agent, cash: cash_value)}

    it 'returns the cash value if no holdings' do
      expect(agent.value).to eq(cash_value)
    end

    it 'returns the cach value + holding value' do
      holding_value = 500
      Holding.any_instance.stub(:value).and_return(holding_value)

      holding = FactoryGirl.create(:holding, agent: agent, stock: FactoryGirl.create(:stock))

      expect(agent.value).to eq(cash_value + holding_value)
    end
  end

  # describe 'act' do
  #   it 'purchases an adjacent stock if the direction is down' do
  # 
  #   end
  # 
  #   it 'stays in place if the direction is up' do
  # 
  #   end
  # 
  #   it 'stays in place is the direction is equal' do
  # 
  #   end
  # 
  #   it 'dies if there are no affordable stocks to purchase' do
  # 
  #   end
  # end

end
