var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var connectionString = builder.Configuration.GetConnectionString("Orders")
    ?? throw new InvalidOperationException("La connection string 'Orders' no está configurada.");
var repository = new OrdersRepository(connectionString);

app.MapGet("/orders/{id:int}", async (int id, CancellationToken cancellationToken) =>
{
    var order = await repository.GetOrderByIdAsync(id, cancellationToken);
    return order is null ? Results.NotFound() : Results.Ok(order);
});

app.MapPost("/orders/{id:int}/refund", async (
    int id,
    decimal amount,
    CancellationToken cancellationToken) =>
{
    await repository.RefundOrderAsync(id, amount, cancellationToken);
    return Results.Ok();
});

app.Run();
