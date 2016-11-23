class DataCollector
  def run
    Rails.logger.level=1

    while true
      Rails.logger.warn time_eastern
      if market_open?
        QuoteService.new.load_all_stocks
        Rails.logger.warn "Stock Values: #{StockValue.count}"
      else
        Rails.logger.warn "Market Closed"
      end

      sleep(5 * 60)
    end
  end

  private

  def market_open?
    datetime = time_eastern
    is_weekday = [1,2,3,4,5].include?(datetime.wday)

    time = datetime.to_time
    start_min = 9 * 60 + 30
    end_min = 16 * 60 + 30

    current_min = time.hour * 60 + time.min

    is_weekday && current_min >= start_min && current_min < end_min
  end

  def time_eastern
    DateTime.now.in_time_zone('Eastern Time (US & Canada)')
  end
end