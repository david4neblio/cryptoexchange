module Cryptoexchange::Exchanges
  module Hpx
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super(ticker_url)
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::Hpx::Market::API_URL}/tickers"
        end

        def adapt_all(output)
          output['data'].map do |pair|
            base, target = pair['symbol'].split('_')
            market_pair  = Cryptoexchange::Models::MarketPair.new(
              base:   base.upcase,
              target: target.upcase,
              market: Hpx::Market::NAME
            )
            adapt(market_pair, pair['ticker'])
          end
        end

        def adapt(market_pair, output)
          ticker           = Cryptoexchange::Models::Ticker.new
          ticker.base      = market_pair.base
          ticker.target    = market_pair.target
          ticker.market    = Hpx::Market::NAME
          ticker.last      = NumericHelper.to_d(output['last'])
          ticker.high      = NumericHelper.to_d(output['high'])
          ticker.low       = NumericHelper.to_d(output['low'])
          ticker.bid       = NumericHelper.to_d(output['buy'])
          ticker.ask       = NumericHelper.to_d(output['sell'])
          ticker.volume    = NumericHelper.to_d(output['vol'])
          ticker.timestamp = nil
          ticker.payload   = output
          ticker
        end
      end
    end
  end
end
