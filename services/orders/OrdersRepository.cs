using Microsoft.Data.SqlClient;

public class OrdersRepository
{
    private readonly string _connectionString;

    public OrdersRepository(string connectionString)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(connectionString);
        _connectionString = connectionString;
    }

    public async Task<Order?> GetOrderByIdAsync(
        int id,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(
            "SELECT Id, Amount FROM Orders WHERE Id = @id",
            connection);
        command.Parameters.Add("@id", System.Data.SqlDbType.Int).Value = id;
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return new Order
        {
            Id = reader.GetInt32(reader.GetOrdinal("Id")),
            Amount = reader.GetDecimal(reader.GetOrdinal("Amount")),
        };
    }

    public async Task RefundOrderAsync(
        int id,
        decimal amount,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(
            "UPDATE Orders SET Refunded = 1, RefundAmount = @amount WHERE Id = @id",
            connection);
        command.Parameters.Add("@amount", System.Data.SqlDbType.Decimal).Value = amount;
        command.Parameters.Add("@id", System.Data.SqlDbType.Int).Value = id;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}

public class Order
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
}
