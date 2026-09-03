---
applyTo: "**/*.ts,**/*.tsx"
---

# Estándar de frontend TypeScript / React

- Prohibido `dangerouslySetInnerHTML` sin sanitización explícita (ej. DOMPurify) — riesgo
  de XSS.
- Prohibido loguear contraseñas, tokens de sesión, o cualquier credencial en
  `console.log`/`console.error`, incluso en código que "solo corre en desarrollo".
- Toda llamada a `fetch`/`axios` debe manejar el caso de error (network fail, status
  >= 400) y no dejar promesas sin `.catch` o `try/catch`.
- Formularios con campos de contraseña o datos financieros deben usar `type="password"`
  y nunca almacenarse en `localStorage`/`sessionStorage`.
- Evita `any` en props y estado — preferir tipos explícitos o `unknown` con narrowing.
