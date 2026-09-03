---
applyTo: "**/*.cs"
---

# Estándar de backend .NET / C#

- Prohibido el patrón *sync-over-async*: nunca uses `.Result`, `.Wait()` o
  `GetAwaiter().GetResult()` sobre una `Task`/`Task<T>`. Usa `async`/`await` de punta a
  punta; el bloqueo síncrono sobre tareas asíncronas puede causar deadlocks bajo carga.
- Todo recurso `IDisposable` (conexiones ADO.NET, `HttpClient` de vida corta, streams,
  etc.) debe envolverse en `using`/`await using`. Nunca dejar una conexión abierta sin un
  bloque que garantice su liberación.
- Prohibido construir SQL con concatenación o interpolación de strings
  (`$"SELECT ... WHERE id = {id}"`). Usa siempre parámetros (`SqlParameter`,
  `DbParameter`) o un ORM (EF Core, Dapper con parámetros).
- No captures `Exception` genérica para "tragarte" el error en silencio. Si necesitas
  capturar ampliamente, vuelve a lanzar (`throw;`) o registra con `ILogger` incluyendo
  contexto suficiente para diagnosticar — nunca un `catch { }` vacío.
- Los connection strings, API keys y cualquier secreto deben venir de configuración
  (`IConfiguration`, Azure Key Vault, variables de entorno). Nunca hardcodeados en el
  código fuente.
- Habilita *nullable reference types* (`<Nullable>enable</Nullable>` en el `.csproj`) y
  valida argumentos públicos con guard clauses (`ArgumentNullException.ThrowIfNull`,
  o similar) antes de usarlos.
- Los métodos asíncronos deben terminar en sufijo `Async` y, si exponen I/O, aceptar y
  propagar un `CancellationToken`.
- Los montos de dinero deben modelarse con `decimal`, nunca `double`/`float`.
