using Function.Domain.Models;
using System.Linq;
using System.Threading.Tasks;

namespace Function.Domain.Providers
{
    public class MockStockDataProvider : IStockDataProvider
    {
        public async Task<StockData> GetStockDataForSymbolAsync(string symbol)
        {
            string[] mappedSymbols = {"AAPL", "MSFT", "VRTU"};
            if (mappedSymbols.Contains(symbol))
            {
                var data = new StockData
                {
                    Low = 1.0M,
                    Current = 1.5M,
                    High = 2.0M,
                    Open = 2.5M,
                    PreviousClose = 3.4M
                };
                return await Task.FromResult<StockData>(data);
            }
            else
            {
                throw new StockDataUnavailableException($"Stock data unavailable for {symbol}");
            }
        }
    }
}