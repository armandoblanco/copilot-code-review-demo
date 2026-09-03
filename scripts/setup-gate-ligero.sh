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
BRANCH="${2:-main}"

echo "Creando ruleset 'Gate Ligero - Copilot Review' en $REPO (rama: $BRANCH)..."

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "repos/$REPO/rulesets" \
  -f name="Gate Ligero - Copilot Review" \
  -f target="branch" \
  -f enforcement="active" \
  -f 'conditions[ref_name][include][]=~DEFAULT_BRANCH' \
  -f 'conditions[ref_name][exclude][]' \
  -F 'rules[][type]=pull_request' \
  -F 'rules[][parameters][required_approving_review_count]=1' \
  -F 'rules[][parameters][dismiss_stale_reviews_on_push]=true' \
  -F 'rules[][parameters][require_code_owner_review]=false' \
  -F 'rules[][parameters][require_last_push_approval]=false' \
  -F 'rules[][parameters][required_review_thread_resolution]=true' \
  -F 'rules[][parameters][allowed_merge_methods][]=squash' \
  -F 'rules[][parameters][allowed_merge_methods][]=merge' \
  -F 'rules[][type]=copilot_code_review' \
  -F 'rules[][parameters][review_on_push]=true' \
  -F 'rules[][parameters][review_draft_pull_requests]=false'

echo ""
echo "Listo. Verifica en: https://github.com/$REPO/settings/rules"
echo ""
echo "Recuerda además habilitar manualmente (no expuesto vía este endpoint):"
echo "  Settings > Copilot > Code review > Review effort level = Lite"
