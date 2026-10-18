#!/usr/bin/env bash
# deploy.sh: build, tag, push, and deploy this site to the FC home Kubernetes cluster.
#
# Usage:
#   ./bin/deploy.sh <env>                   # auto-increment patch (e.g. v0.1.1 → v0.1.2)
#   ./bin/deploy.sh <env> --version 0.2.0   # explicit version override
#   ./bin/deploy.sh <env> --dry-run         # print what would happen; don't execute
#   ./bin/deploy.sh <env> --clean           # full rebuild, no Docker layer cache
#
#   <env> is prod (the only environment for now).
#
# Version source of truth: the image tag in .k8s/<app>-<env>-nginx-deployment.yaml.
# Prod is gated: it must run from a clean `main`/`master` and asks for typed confirmation.
#
# One-time setup: `docker login registry.functionalchaos.net`, and the cluster repo must already have
# created the `harbor-pull-secret` pull secret, and the Gateway listeners for this site.

set -euo pipefail

# ── Config (the only part that differs between the site repos) ──────────────────

APP="fc"                                   # prefix for images, manifests and deployments
SITE="functionalchaos.net"                 # for display only
NAMESPACE="${NAMESPACE:-functionalchaos}"
REGISTRY="registry.functionalchaos.net/functionalchaos"

# kctl-fc is the home cluster. Never point this at any other cluster.
# Full path, because ~/bin in PATH isn't expanded for every caller.
KUBECTL="${KUBECTL:-$HOME/bin/kctl-fc}"

# ── Parse env + flags ───────────────────────────────────────────────────────────

ENV=""
VERSION_OVERRIDE=""
DRY_RUN=false
NO_CACHE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        prod)
            ENV="$1"
            shift
            ;;
        --version|-v)
            VERSION_OVERRIDE="${2#v}"   # strip leading 'v' if provided
            shift 2
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --clean)
            NO_CACHE="--no-cache"
            shift
            ;;
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $1  (use --help for usage)"
            exit 1
            ;;
    esac
done

[[ -n "$ENV" ]] || { echo "Missing environment. Usage: ./bin/deploy.sh <prod> [flags]"; exit 1; }

# Uppercase label for display (portable: macOS ships bash 3.2, no ${ENV^^}).
ENV_UPPER=$(echo "$ENV" | tr '[:lower:]' '[:upper:]')

# ── Per-environment derived values ──────────────────────────────────────────────

NGINX_LOCAL="${APP}-${ENV}-nginx"          # local image name from docker-compose-${ENV}.yaml
NGINX_REMOTE="${REGISTRY}/${APP}-${ENV}-nginx"
COMPOSE_FILE="docker-compose-${ENV}.yaml"
NGINX_DEPLOY=".k8s/${APP}-${ENV}-nginx-deployment.yaml"
NGINX_DEPLOY_NAME="${APP}-${ENV}-nginx-deployment"

cd "$(dirname "$0")/.."

for f in "$COMPOSE_FILE" "$NGINX_DEPLOY"; do
    [[ -f "$f" ]] || { echo "Missing required file for env '${ENV}': $f"; exit 1; }
done

# ── Helpers ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${BOLD}▶  $*${NC}"; }
success() { echo -e "${GREEN}✔  $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠  $*${NC}"; }
die()     { echo -e "${RED}✖  $*${NC}" >&2; exit 1; }

run() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}  [dry-run] $*${NC}"
    else
        eval "$@"
    fi
}

# ── Prod safety gate ────────────────────────────────────────────────────────────

if [[ "$ENV" == "prod" && "$DRY_RUN" == false ]]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] \
        || die "Production deploys must run from 'main' or 'master' (currently on '${BRANCH}')."
    [[ -z "$(git status --porcelain)" ]] || die "Working tree is not clean. Commit or stash before a prod deploy."
fi

# Fail before building if the cluster isn't reachable (e.g. away from home without the VPN).
if [[ "$DRY_RUN" == false ]]; then
    "$KUBECTL" get namespace "$NAMESPACE" >/dev/null 2>&1 \
        || die "Can't reach namespace '${NAMESPACE}' with ${KUBECTL}. Check your network or VPN connection."
fi

# ── Determine version ─────────────────────────────────────────────────────────

CURRENT_TAG=$(grep -oE "${APP}-${ENV}-nginx:v[0-9]+\.[0-9]+\.[0-9]+" "$NGINX_DEPLOY" | head -1 | sed 's/.*://') \
    || die "Could not find a version tag in $NGINX_DEPLOY"
[[ -n "$CURRENT_TAG" ]] || die "Could not find a version tag in $NGINX_DEPLOY"

CURRENT_SEMVER="${CURRENT_TAG#v}"
MAJOR=$(echo "$CURRENT_SEMVER" | cut -d. -f1)
MINOR=$(echo "$CURRENT_SEMVER" | cut -d. -f2)
PATCH=$(echo "$CURRENT_SEMVER" | cut -d. -f3)

if [[ -n "$VERSION_OVERRIDE" ]]; then
    NEW_SEMVER="$VERSION_OVERRIDE"
else
    NEW_SEMVER="${MAJOR}.${MINOR}.$((PATCH + 1))"
fi

NEW_TAG="v${NEW_SEMVER}"

# ── Pre-flight summary ────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${SITE} Deploy — ${ENV_UPPER}${NC}"
echo "  Environment     : ${ENV}"
echo "  Current version : ${CURRENT_TAG}"
echo "  New version     : ${NEW_TAG}"
echo "  Compose file    : ${COMPOSE_FILE}"
echo "  Image           : ${NGINX_REMOTE}:${NEW_TAG}"
echo "  Cluster         : ${KUBECTL} (namespace ${NAMESPACE})"
[[ "$DRY_RUN" == true ]] && warn "DRY RUN — no changes will be made"
echo ""

if [[ "$ENV" == "prod" ]]; then
    read -r -p "Type 'prod' to confirm a PRODUCTION deploy: " CONFIRM
    [[ "$CONFIRM" == "prod" ]] || { info "Aborted."; exit 0; }
else
    read -r -p "Continue? [y/N] " CONFIRM
    [[ "$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')" == "y" ]] || { info "Aborted."; exit 0; }
fi
echo ""

# ── 1. Build ──────────────────────────────────────────────────────────────────

# Skip BuildKit's provenance/SBOM attestations: keeps the pushed manifest a plain image, not an OCI index.
export BUILDX_NO_DEFAULT_ATTESTATIONS=1

info "Step 1/5 — Building image with docker compose${NO_CACHE:+ (clean — no layer cache)}..."
run "docker compose -f \"${COMPOSE_FILE}\" build ${NO_CACHE}"
success "Image built."
echo ""

# ── 2. Tag ────────────────────────────────────────────────────────────────────

info "Step 2/5 — Tagging image as ${NEW_TAG}..."
run "docker tag \"${NGINX_LOCAL}\" \"${NGINX_REMOTE}:${NEW_TAG}\""
success "Tagged: ${NGINX_REMOTE}:${NEW_TAG}"
echo ""

# ── 3. Push ───────────────────────────────────────────────────────────────────

info "Step 3/5 — Pushing image to ${REGISTRY}..."
run "docker push \"${NGINX_REMOTE}:${NEW_TAG}\""
success "Image pushed."
echo ""

# ── 4. Update k8s YAML ─────────────────────────────────────────────────────────

info "Step 4/5 — Updating ${NGINX_DEPLOY} to ${NEW_TAG}..."
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}  [dry-run] sed ${CURRENT_TAG} → ${NEW_TAG} in ${NGINX_DEPLOY}${NC}"
else
    sed -i '' "s|${NGINX_REMOTE}:${CURRENT_TAG}|${NGINX_REMOTE}:${NEW_TAG}|g" "${NGINX_DEPLOY}"
fi
success "Manifest updated."
echo ""

# ── 5. Apply to Kubernetes ────────────────────────────────────────────────────

info "Step 5/5 — Applying to Kubernetes..."
run "\"${KUBECTL}\" apply -f \"${NGINX_DEPLOY}\""
echo ""

info "Waiting for rollout to complete..."
run "\"${KUBECTL}\" -n ${NAMESPACE} rollout status deployment/${NGINX_DEPLOY_NAME}"

success "Deploy complete — ${SITE} ${ENV_UPPER} is running at ${NEW_TAG}"
echo ""

if [[ "$DRY_RUN" == false ]]; then
    echo -e "  ${YELLOW}Tip:${NC} Commit the updated manifest and tag the release:"
    echo "    git add ${NGINX_DEPLOY}"
    echo "    git commit -m \"Deploy ${ENV} ${NEW_TAG}\""
    echo "    git tag ${APP}-${ENV}-${NEW_TAG}"
    echo "    git push && git push --tags"
    echo ""
fi
