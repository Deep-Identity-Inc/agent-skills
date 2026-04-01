#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DEFAULT_BASE_URL="https://api.deepidv.com/v1"

usage() {
  cat <<'EOF'
Usage:
  ./verify.sh create-session [json_body_file]
  ./verify.sh list-sessions [query_string]
  ./verify.sh get-session <session_id>
  ./verify.sh update-session-status <session_id> [json_body_file]
  ./verify.sh create-workflow [json_body_file]
  ./verify.sh list-workflows
  ./verify.sh get-workflow <workflow_id>

Commands:
  create-session         POST /v1/sessions
  list-sessions          GET /v1/sessions
  get-session            GET /v1/sessions/{id}
  update-session-status  PATCH /v1/sessions/{id}/update-status
  create-workflow        POST /v1/workflows
  list-workflows         GET /v1/workflows
  get-workflow           GET /v1/workflows/{id}

Environment:
  DEEPIDV_API_KEY   API key override.
  DEEPIDV_BASE_URL  Explicit base URL override.

Credential fallback files:
  .deepidv/credentials in the project root
  ~/.deepidv/credentials in the user home directory

Examples:
  ./verify.sh create-session request.json
  ./verify.sh list-sessions "limit=25&workflow_id=wf_abc123"
  ./verify.sh get-session a1b2c3d4-e5f6-7890-abcd-ef1234567890
  ./verify.sh update-session-status a1b2c3d4-e5f6-7890-abcd-ef1234567890 status.json
  ./verify.sh create-workflow workflow.json
  ./verify.sh list-workflows
  ./verify.sh get-workflow 6d6da499-9225-40fb-9ffd-a06634b915bd
EOF
}

validate_uuid() {
  local id="$1"
  local label="$2"
  if [[ ! "$id" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "Error: ${label} '${id}' is not a valid UUID." >&2
    exit 1
  fi
}

validate_query_string() {
  local qs="$1"
  if [[ "$qs" =~ [^a-zA-Z0-9_=\&.:%+@/\-] ]]; then
    echo "Error: query string contains unexpected characters." >&2
    exit 1
  fi
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
    if [[ "$DEEPIDV_BASE_URL" != https://* ]]; then
      echo "Error: DEEPIDV_BASE_URL must use HTTPS to protect the API key in transit." >&2
      exit 1
    fi
    printf '%s\n' "$DEEPIDV_BASE_URL"
    return 0
  fi

  printf '%s\n' "$DEFAULT_BASE_URL"
}

build_body_arg() {
  local body_file="${1:-}"

  if [[ -n "$body_file" ]]; then
    if [[ ! -f "$body_file" ]]; then
      echo "Error: JSON body file '$body_file' was not found." >&2
      exit 1
    fi
    BODY_ARG=(--data "@$body_file")
    return 0
  fi

  if [[ -t 0 ]]; then
    echo "Error: provide a JSON body file or pipe JSON on stdin." >&2
    usage >&2
    exit 1
  fi

  BODY_ARG=(--data @-)
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]]; then
  usage
  [[ -z "${1:-}" ]] && exit 1 || exit 0
fi

COMMAND="$1"
ARG_ONE="${2:-}"
ARG_TWO="${3:-}"

API_KEY="$(load_api_key || true)"

if [[ -z "$API_KEY" ]]; then
  echo "Error: no deepidv API key found." >&2
  echo "Checked DEEPIDV_API_KEY, $PROJECT_ROOT/.deepidv/credentials, and ~/.deepidv/credentials." >&2
  exit 1
fi

BASE_URL="$(resolve_base_url)"
BODY_ARG=()
METHOD="GET"
URL_PATH=""
CONTENT_TYPE=false

case "$COMMAND" in
  create-session)
    METHOD="POST"
    URL_PATH="/sessions"
    CONTENT_TYPE=true
    build_body_arg "$ARG_ONE"
    ;;
  list-sessions)
    URL_PATH="/sessions"
    if [[ -n "$ARG_ONE" ]]; then
      validate_query_string "$ARG_ONE"
      URL_PATH+="?$ARG_ONE"
    fi
    ;;
  get-session)
    if [[ -z "$ARG_ONE" ]]; then
      echo "Error: get-session requires a session ID." >&2
      usage >&2
      exit 1
    fi
    validate_uuid "$ARG_ONE" "session ID"
    URL_PATH="/sessions/$ARG_ONE"
    ;;
  update-session-status)
    if [[ -z "$ARG_ONE" ]]; then
      echo "Error: update-session-status requires a session ID." >&2
      usage >&2
      exit 1
    fi
    validate_uuid "$ARG_ONE" "session ID"
    METHOD="PATCH"
    URL_PATH="/sessions/$ARG_ONE/update-status"
    CONTENT_TYPE=true
    build_body_arg "$ARG_TWO"
    ;;
  create-workflow)
    METHOD="POST"
    URL_PATH="/workflows"
    CONTENT_TYPE=true
    build_body_arg "$ARG_ONE"
    ;;
  list-workflows)
    URL_PATH="/workflows"
    ;;
  get-workflow)
    if [[ -z "$ARG_ONE" ]]; then
      echo "Error: get-workflow requires a workflow ID." >&2
      usage >&2
      exit 1
    fi
    validate_uuid "$ARG_ONE" "workflow ID"
    URL_PATH="/workflows/$ARG_ONE"
    ;;
  *)
    echo "Error: invalid command '$COMMAND'." >&2
    usage >&2
    exit 1
    ;;
esac

URL="$BASE_URL$URL_PATH"

CURL_ARGS=(
  -sS
  --fail-with-body
  -X "$METHOD"
  "$URL"
  -H "x-api-key: $API_KEY"
)

if [[ "$CONTENT_TYPE" == true ]]; then
  CURL_ARGS+=( -H "Content-Type: application/json" )
fi

if [[ ${#BODY_ARG[@]} -gt 0 ]]; then
  CURL_ARGS+=( "${BODY_ARG[@]}" )
fi

curl "${CURL_ARGS[@]}"
