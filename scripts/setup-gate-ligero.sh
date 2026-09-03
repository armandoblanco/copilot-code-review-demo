#!/usr/bin/env bash
# Crea el ruleset de "Gate Ligero" en un repo de GitHub vía API REST:
#   - Copilot revisa automáticamente cada push a PRs abiertos contra la rama default.
#   - El merge queda BLOQUEADO mientras existan hilos de conversación sin resolver
#     (incluyendo los comentarios que deje Copilot).
#
# Uso:
#   ./scripts/setup-gate-ligero.sh <owner>/<repo> [rama-default]
#
# Requiere: gh CLI autenticado con permisos de admin sobre el repo.

set -euo pipefail

REPO="${1:?Uso: setup-gate-ligero.sh <owner>/<repo> [rama-default]}"
BRANCH="${2:-}"

if [[ -n "$BRANCH" && ! "$BRANCH" =~ ^[A-Za-z0-9._/-]+$ ]]; then
  echo "La rama contiene caracteres no válidos: $BRANCH" >&2
  exit 1
fi

if [ -n "$BRANCH" ]; then
  REF_INCLUDE="refs/heads/$BRANCH"
else
  REF_INCLUDE="~DEFAULT_BRANCH"
fi

echo "Creando ruleset 'Gate Ligero - Copilot Review' en $REPO (rama: ${BRANCH:-<rama default del repo>})..."

# Nota: gh api con -F/-f no compone bien arrays de objetos anidados
# (rules[] con distintas claves por elemento), así que construimos el
# payload como JSON y lo pasamos con --input.
PAYLOAD_FILE="$(mktemp "${TMPDIR:-/tmp}/setup-gate-ligero.XXXXXX")"
trap 'rm -f "$PAYLOAD_FILE"' EXIT

cat > "$PAYLOAD_FILE" << JSON
{
  "name": "Gate Ligero - Copilot Review",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["$REF_INCLUDE"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["squash", "merge"]
      }
    },
    {
      "type": "copilot_code_review",
      "parameters": {
        "review_on_push": true,
        "review_draft_pull_requests": false
      }
    }
  ]
}
JSON

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "repos/$REPO/rulesets" \
  --input "$PAYLOAD_FILE"

echo ""
echo "Listo. Verifica en: https://github.com/$REPO/settings/rules"
echo ""
echo "Recuerda además habilitar manualmente (no expuesto vía este endpoint):"
echo "  Settings > Copilot > Code review > Review effort level = Lite"
