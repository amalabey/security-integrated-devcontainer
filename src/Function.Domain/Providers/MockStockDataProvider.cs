using Function.Domain.Models;
using System.Threading.Tasks;

namespace Function.Domain.Providers
{
    public class MockStockDataProvider : IStockDataProvider
    {
        public async Task<StockData> GetStockDataForSymbolAsync(string symbol)
        {
            var data = new StockData{
                Low = 1.0M,
                Current = 1.5M,
                High = 2.0M,
                Open = 2.5M
            };

            return await Task.FromResult<StockData>(data);
        }
    }
}