using System;

public class StockDataUnavailableException : Exception
{
    public StockDataUnavailableException()
    {
    }

    public StockDataUnavailableException(string message)
        : base(message)
    {
    }

    public StockDataUnavailableException(string message, Exception inner)
        : base(message, inner)
    {
    }
}