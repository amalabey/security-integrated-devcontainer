using Function.Domain.Models;
using Function.Domain.Services;
using Function.Domain.Services.HttpClients;
using System;
using System.Threading.Tasks;

namespace Function.Domain.Providers
{
    public class FinhubProvider : IStockDataProvider
    {
        private readonly FinhubHttpClient _client;
        private readonly IFinhubDataMapper _stockDataMapper;

        public FinhubProvider(
            FinhubHttpClient client,
            IFinhubDataMapper stockDataMapper)
        {
            _client = client;
            _stockDataMapper = stockDataMapper;
        }
        public async Task<StockData> GetStockDataForSymbolAsync(string symbol)
        {
            try
            {
                var stockDataRaw = await _client.GetStockDataForSymbolAsync(symbol);
                return _stockDataMapper.MapToStockData(stockDataRaw);
            }
            catch (Exception)
            {
                throw new StockDataUnavailableException($"Unable to retrieve stock data for: {symbol}");
            }
        }
    }
}