# Demo: Copilot Code Review como Gate Ligero

Este demo monta **Opción 1 — Gate Ligero**: Copilot revisa automáticamente cada PR,
y **nadie puede mergear** mientras queden comentarios sin resolver
(`required_review_thread_resolution`). No depende de que la gente "se acuerde" de pedir
la revisión ni de que decida hacerle caso — el merge queda técnicamente bloqueado.

## Estado actual (verificado en vivo)

- Repo público: **https://github.com/armandoblanco/copilot-code-review-demo**
- Ruleset **"Gate Ligero - Copilot Review"** activo (ver
  `https://github.com/armandoblanco/copilot-code-review-demo/settings/rules`).
- 4 PRs abiertos, cada uno ya revisado automáticamente por Copilot:

  | PR | Rama | Resultado de Copilot |
  |---|---|---|
  | [#1](https://github.com/armandoblanco/copilot-code-review-demo/pull/1) | `feature/payments-charge-endpoint` | 🟡 Changes recommended — SQL injection, log de datos sensibles/PII, `float` para dinero, llamada externa sin manejo de errores |
  | [#2](https://github.com/armandoblanco/copilot-code-review-demo/pull/2) | `feature/login-form` | 🟡 Changes recommended — XSS y manejo inseguro de credenciales |
  | [#3](https://github.com/armandoblanco/copilot-code-review-demo/pull/3) | `feature/infra-customer-uploads` | 🟡 Changes recommended — bucket público sin cifrado, security group abierto a Internet, credenciales hardcodeadas |
  | [#4](https://github.com/armandoblanco/copilot-code-review-demo/pull/4) | `fix/ruleset-script-json-payload` | Copilot encontró 2 bugs reales en el propio script del demo (`mktemp` no portable, parámetro de rama ignorado) — ya corregidos en commits posteriores del mismo PR |

- Verificado con la API: los PRs #1–#3 tienen `mergeStateStatus: BLOCKED` — el botón de
  merge está deshabilitado en GitHub hasta resolver los hilos de conversación de Copilot.
  Esto es la prueba de que es un **gate real**, no una sugerencia decorativa.
- Un `git push` directo a `main` fue rechazado por el ruleset
  (`GH013: Changes must be made through a pull request`), confirmando que ni siquiera el
  dueño del repo puede saltarse el flujo de PR.

## Qué incluye

```
copilot-code-review-demo/
├── .github/
│   ├── copilot-instructions.md              # baseline repo-wide
│   └── instructions/
│       ├── backend-python.instructions.md   # applyTo: services/**/*.py
│       ├── frontend-typescript.instructions.md  # applyTo: **/*.ts,**/*.tsx
│       └── infra-terraform.instructions.md  # applyTo: infra/**/*.tf
├── services/payments/app.py                 # baseline seguro (Python)
├── frontend/src/Login.tsx                   # baseline seguro (TS/React)
├── infra/main.tf                             # baseline seguro (Terraform)
└── scripts/setup-gate-ligero.sh              # crea el ruleset real vía gh api
```

`main` contiene una versión **limpia** de cada stack. Los problemas intencionales viven
en 3 ramas de feature separadas, cada una abierta como su propio PR — simulando trabajo
real en paralelo:

| Rama | PR | Qué introduce |
|---|---|---|
| `feature/payments-charge-endpoint` | PR #1 | SQL injection, log de tarjeta/CVV, sin validación de input, `float` para dinero |
| `feature/login-form` | PR #2 | `dangerouslySetInnerHTML` sin sanitizar, contraseña logueada y en `localStorage`, fetch sin manejo de error |
| `feature/infra-customer-uploads` | PR #3 | bucket S3 público sin cifrado, security group abierto a `0.0.0.0/0`, password hardcodeada |

Cada PR debería disparar automáticamente la revisión de Copilot y quedar bloqueado para
merge hasta resolver los comentarios (gate real, no sugerencia).

## Paso 1 — El repo ya está publicado

Repo: **https://github.com/armandoblanco/copilot-code-review-demo**

`main` tiene el baseline seguro. Las 3 ramas de feature (ver tabla arriba) ya están
publicadas, cada una con su PR abierto contra `main`.

## Paso 2 — Activar el gate (ruleset real, vía API)

Requiere Copilot code review habilitado en la org (policy) y permisos de admin en el repo.

```bash
export REPO="armandoblanco/copilot-code-review-demo"
./scripts/setup-gate-ligero.sh "$REPO"
```

Esto crea un ruleset activo sobre la rama por defecto con:

- **`copilot_code_review`**: `review_on_push=true` — Copilot revisa cada push nuevo al PR.
- **`pull_request`**: `required_review_thread_resolution=true` — el gate real: no se puede
  mergear con hilos de conversación abiertos (incluidos los de Copilot).
- `required_approving_review_count=1`, `dismiss_stale_reviews_on_push=true`.

> El *effort level* (Lite/Balanced) y el toggle "Review draft pull requests" a nivel repo
> se configuran hoy solo desde Settings → Copilot → Code review (no expuesto aún vía este
> endpoint para effort level). Déjalo en **Lite** para la demo — es el más rápido y barato.

## Paso 3 — Ver la revisión en acción

Abre cualquiera de los 3 PRs ya publicados:

```bash
gh pr list --repo armandoblanco/copilot-code-review-demo
gh pr view 1 --repo armandoblanco/copilot-code-review-demo --web
```

Si el ruleset del Paso 2 ya estaba activo **antes** de abrir un PR (o si vuelves a
empujar un commit tras activarlo), Copilot comentará automáticamente en 1–3 minutos.
Si los PRs se abrieron antes de correr el script, pide la revisión manualmente:

```bash
gh pr comment 1 --repo armandoblanco/copilot-code-review-demo --body "@copilot review"
```

Intenta hacer merge: GitHub debe **bloquear el botón de merge** con el mensaje
"Merging is blocked" hasta resolver los hilos.

## Qué debería señalar Copilot en cada archivo (para verificar que el gate "ve" el path correcto)

| Archivo | Instrucción `applyTo` que debería activarse | Problema intencional |
|---|---|---|
| `services/payments/app.py` | `backend-python.instructions.md` | falta validación de input, SQL armado con f-string, log de dato sensible |
| `frontend/src/Login.tsx` | `frontend-typescript.instructions.md` | `dangerouslySetInnerHTML`, contraseña en `console.log`, sin manejo de error |
| `infra/main.tf` | `infra-terraform.instructions.md` | bucket S3 público, security group abierto a `0.0.0.0/0` |

## La conversación de gobierno (esto es lo que realmente importa)

Antes de activarlo en un repo real del equipo, deciden explícitamente y lo escriben en
el propio `copilot-instructions.md` o en el README del repo:

1. **¿Qué bloquea merge?** En este modelo: *cualquier* comentario de Copilot sin resolver.
   No hay distinción de severidad — es deliberadamente simple para la demo, pero en la
   vida real casi ningún equipo tolera esto sin ajustar (ver opción 2/3).
2. **¿Quién puede resolver un hilo sin arreglar el código?** Cualquiera con permiso de
   escritura. Esto es la fuga más común: la gente aprende a click "Resolve conversation"
   por costumbre. Mitigación mínima: revisar semanalmente cuántos hilos de Copilot se
   resolvieron *sin* un commit posterior en esa línea.
3. **¿Aplica a todo el repo o hay excepciones?** Este demo lo aplica a la rama default
   completa. Definan si `docs/**` o `*.md` deberían excluirse del ruleset (vía
   `conditions` adicionales) para no generar fatiga en cambios de bajo riesgo.
4. **¿Quién puede saltarse el gate (`bypass_actors`)?** Por defecto este script no
   configura bypass — ni siquiera admins. Decidan si eso es lo que quieren o si el
   equipo de plataforma necesita una vía de escape auditada.

## Limpieza

```bash
gh api -X DELETE "repos/$REPO/rulesets/<ID>"
```
