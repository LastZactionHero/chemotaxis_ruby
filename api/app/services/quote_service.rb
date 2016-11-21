class QuoteService
  def load_all_stocks
    Stock.all.each_slice(100) do |stock_set|
      quotes = StockQuote::Stock.quote(stock_set.map{|s| s.symbol})
      quotes.each do |quote|
        stock = Stock.find_by(symbol: quote.symbol)
        StockValue.create({
          stock: stock,
          quoted_at: DateTime.now,
          value: quote.last_trade_price_only
        })
      end
    end
  end

  def load(stock)
    quote = StockQuote::Stock.quote(stock.symbol)
    StockValue.create({
      stock: stock,
      quoted_at: DateTime.now,
      value: quote.last_trade_price_only
    })
  end
end