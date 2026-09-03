// Servicio de pedidos (demo) - capa .NET del ejemplo.
//
// NOTA: Este archivo contiene problemas intencionales para que Copilot code
// review los detecte durante la demo. No usar como referencia de buenas
// prácticas.

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Problema 1: connection string con password hardcodeada en el código fuente,
// en vez de venir de IConfiguration/Key Vault.
var repository = new OrdersRepository(
    "Server=prod-sql.example.com;Database=Orders;User Id=sa;Password=SuperSecret123!;");

app.MapGet("/orders/{id:int}", (int id) =>
{
    // Problema 2: sync-over-async — bloquea el hilo con .Result en vez de
    // usar async/await de punta a punta.
    var order = repository.GetOrderByIdAsync(id).Result;
    return order is null ? Results.NotFound() : Results.Ok(order);
});

app.MapPost("/orders/{id:int}/refund", (int id, decimal amount) =>
{
    try
    {
        repository.RefundOrderAsync(id, amount).Wait();
        return Results.Ok();
    }
    catch (Exception)
    {
        // Problema 3: catch genérico que se traga la excepción sin loguear
        // ni volver a lanzar — imposible diagnosticar fallos en producción.
        return Results.StatusCode(500);
    }
});

app.Run();
