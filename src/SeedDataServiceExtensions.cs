using Microsoft.Extensions.Hosting;
using System.Threading.Tasks;
using System.Data.SQLite;
public static class SeedDataServiceExtensions
{
    public static void EnsureSeeData(this IHostBuilder builder)
    {
        SQLiteConnection.CreateFile("cache.sqlite");

        using SQLiteConnection dbConnection = new SQLiteConnection("Data Source=cache.sqlite");
        dbConnection.Open();

        string sql = "CREATE TABLE IF NOT EXISTS open_stock_price (symbol varchar(20), price decimal)";
        SQLiteCommand createTableCmd = new SQLiteCommand(sql, dbConnection);
        createTableCmd.ExecuteNonQuery();

        sql = @"INSERT INTO open_stock_price (symbol, price) VALUES ('VIRTU', 10.00);
        INSERT INTO open_stock_price (symbol, price) VALUES ('ABC', 20.00);
        INSERT INTO open_stock_price (symbol, price) VALUES ('XYZ', 30.00);";
        SQLiteCommand insertCmd = new SQLiteCommand(sql, dbConnection);
        insertCmd.ExecuteNonQuery();

        sql = "CREATE TABLE IF NOT EXISTS credit_cards (card_num integer, pin integer)";
        SQLiteCommand createCCTableCmd = new SQLiteCommand(sql, dbConnection);
        createCCTableCmd.ExecuteNonQuery();

        sql = @"INSERT INTO credit_cards (card_num, pin) VALUES (1234567890, 112);
        INSERT INTO credit_cards (card_num, pin) VALUES (3323423423, 342);
        INSERT INTO credit_cards (card_num, pin) VALUES (2451328834, 833);";
        SQLiteCommand insertCCCmd = new SQLiteCommand(sql, dbConnection);
        insertCCCmd.ExecuteNonQuery();

        dbConnection.Close();
    }
}