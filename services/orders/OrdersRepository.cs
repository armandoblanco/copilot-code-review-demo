// Repositorio de pedidos (demo) - capa .NET del ejemplo.
//
// NOTA: Este archivo contiene problemas intencionales para que Copilot code
// review los detecte durante la demo. No usar como referencia de buenas
// prácticas.

using Microsoft.Data.SqlClient;

public class OrdersRepository
{
    private readonly string _connectionString;

    public OrdersRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<Order?> GetOrderByIdAsync(int id)
    {
        // Problema 1: SqlConnection abierta sin "using" — nunca se libera
        // explícitamente si ocurre una excepción antes del final del método.
        var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        // Problema 2: SQL armado con interpolación de strings, vulnerable a
        // SQL injection (aunque "id" sea int aquí, el patrón se repite luego
        // con datos de usuario en otros métodos del mismo estilo).
        var command = new SqlCommand($"SELECT * FROM Orders WHERE Id = {id}", connection);
        var reader = await command.ExecuteReaderAsync();

        if (!reader.Read())
        {
            return null;
        }

        // Problema 3: el monto se lee como double en vez de decimal, lo que
        // puede introducir errores de redondeo en cálculos financieros.
        return new Order
        {
            Id = id,
            AmountDouble = reader.GetDouble(reader.GetOrdinal("Amount")),
        };
    }

    public async Task RefundOrderAsync(int id, decimal amount)
    {
        var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        // Problema 4: mismo patrón de SQL por interpolación, ahora con un
        // valor que en un escenario real podría venir directo de un query
        // param del usuario sin sanitizar.
        var command = new SqlCommand(
            $"UPDATE Orders SET Refunded = 1, RefundAmount = {amount} WHERE Id = {id}",
            connection);
        await command.ExecuteNonQueryAsync();

        // Problema 5: el método async no acepta ni propaga un
        // CancellationToken, pese a exponer I/O de red/DB.
    }
}

public class Order
{
    public int Id { get; set; }
    public double AmountDouble { get; set; }
}
