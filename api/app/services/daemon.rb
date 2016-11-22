class Daemon
  def initialize(total_cash, agent_count, data_interval_sec, turn_interval_sec)
    @coordinator = AgentCoordinator.new(total_cash, agent_count)
    @data_interval_sec = data_interval_sec
    @turn_interval_sec = turn_interval_sec
  end

  def run
    Rails.logger.warn "Daemon: Starting Up"
    load_all_stocks

    @coordinator.dispatch_all_agents

    Rails.logger.warn "Agents dispatched, starting value: #{@coordinator.total_value}"

    while true
      time = Time.now.to_i
      Rails.logger.warn time

      do_load_stock_values = (time % @data_interval_sec) == 0
      do_turn = (time % @turn_interval_sec) == 0

      load_all_stocks if do_load_stock_values
      turn if do_turn

      sleep(1)
    end
  end

  private

  def load_all_stocks
    Rails.logger.warn "Daemon: Loading All Stock Values"
    QuoteService.new.load_all_stocks
  end

  def turn
    Rails.logger.warn "Daemon: Agent Turn"
    @coordinator.turn
    Rails.logger.warn "Total Stock Value: #{@coordinator.total_value}"

    Rails.logger.warn "Agents:"
    @coordinator.agents.each do |agent|
      Rails.logger.warn "#{agent.id}: #{agent.stock.symbol} #{agent.value}"
    end
  end

end