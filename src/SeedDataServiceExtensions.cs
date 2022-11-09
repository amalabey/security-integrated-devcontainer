using Microsoft.Extensions.Hosting;
using System.Threading.Tasks;
using System.Data.SQLite;
public static class SeedDataServiceExtensions
{
    public static void EnsureSeeData(this IHostBuilder builder)
    {
        SQLiteConnection.CreateFile("cache.sqlite");

        SQLiteConnection dbConnection = new SQLiteConnection("Data Source=cache.sqlite");
        dbConnection.Open();

        string sql = "create table open_stock_price (symbol varchar(20), price decimal)";

        SQLiteCommand command = new SQLiteCommand(sql, dbConnection);
        command.ExecuteNonQuery();

        sql = @"insert into open_stock_price (symbol, price) values ('VIRTU', 10.00);
        insert into open_stock_price (symbol, price) values ('ABC', 20.00);
        insert into open_stock_price (symbol, price) values ('DEF', 30.00);";

        command = new SQLiteCommand(sql, dbConnection);
        command.ExecuteNonQuery();

        dbConnection.Close();
    }
}