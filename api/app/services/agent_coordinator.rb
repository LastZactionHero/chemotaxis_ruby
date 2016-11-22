class AgentCoordinator
  attr_reader :agents

  class InsufficientCashError < StandardError
  end

  def initialize(total_cash, agent_count)
    @total_cash = total_cash
    @agent_count = agent_count
    @agents = []
    @dead_agents = []
  end

  def total_value
    @agents.map{|agent| agent.value}.sum
  end

  def dispatch_all_agents
    cash_per_agent = @total_cash.to_f / @agent_count.to_f
    (1..@agent_count).each{ @agents << dispatch_agent(cash_per_agent) }
  end

  def turn
    newly_dead_agents = []

    # Move each Agent, and identify anyone that cannot continue
    @agents.each do |agent|
      begin
        agent.move
      rescue Agent::Dead
        newly_dead_agents << agent
        @agents.delete(agent)
      end
    end

    # Respawn any dead Agents
    newly_dead_agents.each do |dead_agent|
      @agents << dispatch_agent(dead_agent.value)
      @dead_agents << dead_agent
    end
  end

  private


  def dispatch_agent(cash)
    # Pick a random, affordable stock
    stocks = Stock.all.to_a.shuffle!
    stocks.each do |stock|
      if stock.value <= cash
        agent = Agent.create(cash: cash)
        agent.purchase(stock)
        return agent
      end
    end
    raise InsufficientCashError
  end

end