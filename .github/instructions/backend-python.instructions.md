---
applyTo: "services/**/*.py"
---

# Estándar de backend Python (servicios)

- Toda función que reciba input externo (request body, query params, headers) debe
  validar tipos y rangos antes de usarlo. Usa Pydantic o validación explícita — nunca
  asumas que el input tiene la forma esperada.
- Prohibido construir queries SQL con f-strings, `.format()` o concatenación de
  strings. Usa siempre parámetros bindeados (`cursor.execute(query, params)`) o un ORM.
- Prohibido loguear (`print`, `logging`, `logger.info/debug/error`) contraseñas, tokens,
  números de tarjeta, o cualquier dato marcado como sensible en el modelo de datos.
- Cualquier llamada a un servicio externo (pago, email, HTTP) debe manejar excepciones
  explícitamente — no dejar que una excepción no capturada tumbe el request completo sin
  contexto de log útil (sin incluir el dato sensible).
- Los montos de dinero deben manejarse en enteros (centavos) o `Decimal`, nunca `float`.
