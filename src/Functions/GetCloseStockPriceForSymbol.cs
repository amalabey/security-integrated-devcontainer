using System.Net;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.OpenApi.Models;
using System.Data.SQLite;
using Function.Domain.Providers;
using Function.Domain.Helpers;

namespace Example.Function
{
    public class GetCloseStockPriceForSymbol
    {
        private readonly IStockDataProvider _stockDataProvider;
        private readonly IHttpHelper _httpHelper;
        private readonly ILogger<GetOpenStockPriceForSymbol> _logger;

        public GetCloseStockPriceForSymbol(
                    IStockDataProvider stockDataProvider,
                    IHttpHelper httpHelper,
                    ILogger<GetOpenStockPriceForSymbol> logger){
                _stockDataProvider = stockDataProvider;
                _httpHelper = httpHelper;
                _logger = logger;
        }
        
        [Function("GetCloseStockPriceForSymbol")]
        [OpenApiOperation(operationId: "GetCloseStockPriceForSymbol", tags: new[] { "stock-price/symbol"})]
        [OpenApiParameter(name: "symbol", In = ParameterLocation.Path, Required = true, Type = typeof(string), Description = "Symbol to get stock data from")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "OK response")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(
                AuthorizationLevel.Anonymous,
                "get", 
                Route = "stock-price/symbol/{symbol:alpha}/close"
            )] HttpRequestData req,
            string symbol)
        {
            _logger.LogInformation($"Getting previous close stock price for symbol: {symbol}");

            decimal closePrice = 0.0M;
            if(symbol != "MSFT")
                closePrice = await GetStokPriceFromLocalCache(symbol);
            else
                closePrice = await GetCloseStockPriceForSymbolAsync(symbol);

            var response = await _httpHelper.CreateSuccessfulHttpResponse(req, closePrice);
            return response;
        }

        private async Task<decimal> GetCloseStockPriceForSymbolAsync(string symbol){
            var stockData = await _stockDataProvider.GetStockDataForSymbolAsync(symbol);
            var closePrice = stockData.PreviousClose;

            return closePrice;
        }

        private async Task<decimal> GetStokPriceFromLocalCache(string symbol) {
            string cs = "Data Source=cache.sqlite";
            string stm = "SELECT price FROM open_stock_price WHERE symbol='"+symbol+"'";
            using var con = new SQLiteConnection(cs);
            con.Open();
            using var cmd = new SQLiteCommand(stm, con);
            decimal price = (decimal)cmd.ExecuteScalar();

            return await Task.FromResult(price);
        }
    }
}
