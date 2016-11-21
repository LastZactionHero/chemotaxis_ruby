class QuoteService
  def load_all_stocks
    Stock.all.each_with_index do |stock, idx|
      Rails.logger.warn "Loading #{idx}: #{stock.symbol}"
      load(stock)
    end
  end

  def load(stock)
    quote = StockQuote::Stock.quote(stock.symbol)
    StockValue.create({
      stock: stock,
      quoted_at: DateTime.now,
      value: quote.ask
    })
  end
end
