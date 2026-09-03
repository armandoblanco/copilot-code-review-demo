# Instrucciones repo-wide para GitHub Copilot

Este repositorio es un **demo educativo** para mostrar cómo configurar GitHub Copilot
code review como un gate real de calidad en pull requests, no como una sugerencia
opcional que el equipo aprende a ignorar.

## Contexto del repo

Contiene tres mini-servicios de ejemplo (backend Python, frontend TypeScript/React,
infraestructura Terraform), cada uno con **problemas de seguridad y calidad
intencionales** para que Copilot los detecte en la revisión automática del PR.

## Estándares generales (aplican a todo el repo)

- Nunca loguear secretos, contraseñas, tokens ni PII en texto plano.
- Toda entrada de usuario debe validarse antes de usarse en queries, comandos de shell,
  o renderizado HTML.
- Prefiere fallar de forma explícita (excepciones, tipos) sobre fallar en silencio.
- Los recursos de infraestructura nunca deben exponerse públicamente por defecto.

## Cómo revisar este repo

Al revisar un PR, prioriza: (1) vulnerabilidades de seguridad, (2) manejo de errores
ausente o silencioso, (3) fuga de datos sensibles en logs, (4) apertura innecesaria de
superficie de red. Estilo de código y nomenclatura son de menor prioridad frente a lo
anterior.


<!-- github-knowledge-base-start -->
## Knowledge Base

### Purpose

This repository uses the Knowledge Base at [https://github.com/armandoblanco/copilot-code-review-demo](https://github.com/armandoblanco/copilot-code-review-demo) on branch `main`.

### Required behavior

1. Before changing code, read `docs/index.md` from that branch.
2. Use the index to open only the knowledge files relevant to the task.
3. If the index is unavailable, stop and report that the Knowledge Base could not be loaded.

### Source of truth

Generated knowledge tracks the code. When the knowledge and code disagree, trust the code.
<!-- github-knowledge-base-end -->
