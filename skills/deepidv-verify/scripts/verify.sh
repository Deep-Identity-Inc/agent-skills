#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DEFAULT_PRODUCTION_URL="https://api.deepidv.com/v1"
DEFAULT_SANDBOX_URL="https://sandbox.api.deepidv.com/v1"

usage() {
  cat <<'EOF'
Usage: ./verify.sh <endpoint> [json_body_file]

Endpoints:
  liveness        POST /v1/verify/liveness
  identity        POST /v1/verify/identity
  deepfake        POST /v1/verify/deepfake
  adverse-media   POST /v1/screen/adverse-media
  aml             POST /v1/screen/aml
  full            POST /v1/verify/full

Environment:
  DEEPIDV_API_KEY   API key override.
  DEEPIDV_ENV       sandbox or production. Defaults to production.
  DEEPIDV_BASE_URL  Explicit base URL override.

Credential fallback files:
  .deepidv/credentials in the project root
  ~/.deepidv/credentials in the user home directory

Examples:
  DEEPIDV_ENV=sandbox ./verify.sh liveness request.json
  ./verify.sh aml screening.json
  cat request.json | ./verify.sh full
EOF
}

read_credential_file() {
  local credential_file="$1"
  local line

  if [[ ! -f "$credential_file" ]]; then
    return 1
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line%$'\r'}"

    if [[ -z "$line" ]]; then
      continue
    fi

    if [[ "$line" == *=* ]]; then
      case "$line" in
        DEEPIDV_API_KEY=*)
          printf '%s\n' "${line#DEEPIDV_API_KEY=}"
          return 0
          ;;
      esac
    else
      printf '%s\n' "$line"
      return 0
    fi
  done < "$credential_file"

  return 1
}

load_api_key() {
  if [[ -n "${DEEPIDV_API_KEY:-}" ]]; then
    printf '%s\n' "$DEEPIDV_API_KEY"
    return 0
  fi

  local project_credentials="$PROJECT_ROOT/.deepidv/credentials"
  local home_credentials="${HOME:-}/.deepidv/credentials"
  local loaded_key

  if loaded_key="$(read_credential_file "$project_credentials")"; then
    printf '%s\n' "$loaded_key"
    return 0
  fi

  if [[ -n "${HOME:-}" ]] && loaded_key="$(read_credential_file "$home_credentials")"; then
    printf '%s\n' "$loaded_key"
    return 0
  fi

  return 1
}

resolve_base_url() {
  if [[ -n "${DEEPIDV_BASE_URL:-}" ]]; then
    printf '%s\n' "$DEEPIDV_BASE_URL"
    return 0
  fi

  case "${DEEPIDV_ENV:-production}" in
    production)
      printf '%s\n' "$DEFAULT_PRODUCTION_URL"
      ;;
    sandbox)
      printf '%s\n' "$DEFAULT_SANDBOX_URL"
      ;;
    *)
      echo "Error: DEEPIDV_ENV must be 'production' or 'sandbox'." >&2
      exit 1
      ;;
  esac
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]]; then
  usage
  [[ -z "${1:-}" ]] && exit 1 || exit 0
fi

ENDPOINT="$1"
BODY_FILE="${2:-}"
case "$ENDPOINT" in
  liveness)
    URL_PATH="/verify/liveness"
    ;;
  identity)
    URL_PATH="/verify/identity"
    ;;
  deepfake)
    URL_PATH="/verify/deepfake"
    ;;
  adverse-media)
    URL_PATH="/screen/adverse-media"
    ;;
  aml)
    URL_PATH="/screen/aml"
    ;;
  full)
    URL_PATH="/verify/full"
    ;;
  *)
    echo "Error: invalid endpoint alias '$ENDPOINT'." >&2
    usage >&2
    exit 1
    ;;
esac

API_KEY="$(load_api_key || true)"

if [[ -z "$API_KEY" ]]; then
  echo "Error: no deepidv API key found." >&2
  echo "Checked DEEPIDV_API_KEY, $PROJECT_ROOT/.deepidv/credentials, and ~/.deepidv/credentials." >&2
  exit 1
fi

BASE_URL="$(resolve_base_url)"
URL="$BASE_URL$URL_PATH"

REQUEST_ID="$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || date +%s)"

if [[ -n "$BODY_FILE" ]]; then
  if [[ ! -f "$BODY_FILE" ]]; then
    echo "Error: JSON body file '$BODY_FILE' was not found." >&2
    exit 1
  fi
  DATA_ARG=(--data "@$BODY_FILE")
elif [[ -t 0 ]]; then
  echo "Error: provide a JSON body file or pipe JSON on stdin." >&2
  usage >&2
  exit 1
else
  DATA_ARG=(--data @-)
fi

curl -sS -X POST "$URL" \
  -H "Content-Type: application/json" \
  -H "X-DEEPIDV-KEY: $API_KEY" \
  -H "X-Request-ID: $REQUEST_ID" \
  "${DATA_ARG[@]}"