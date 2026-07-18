#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"
CONFIG_FILE=""
ARCHIVE_TMP_DIR=""
AUTO_LEGACY_CODEX=1
ASSUME_YES=0
TARGET_MODE="all"

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Install the skill globally for Codex, Claude, and Cursor.

Options:
  --all               Install to all supported harnesses (default)
  --codex             Install only to Codex
  --claude            Install only to Claude
  --cursor            Install only to Cursor
  --legacy-codex      Also install to the legacy Codex skills path
  --no-legacy-codex   Do not install to the legacy Codex skills path
  --yes               Replace existing installed folders without prompting
  --help              Show this help text

Remote bootstrap:
  If this script is executed without the repo checked out beside it, set
  ENGRAM_REPO_ARCHIVE_URL to a GitHub archive URL for the repo before running it.
EOF
}

cleanup() {
  if [[ -n "${ARCHIVE_TMP_DIR}" && -d "${ARCHIVE_TMP_DIR}" ]]; then
    rm -rf "${ARCHIVE_TMP_DIR}"
  fi
}

trap cleanup EXIT

load_env_file() {
  local env_file="$1"
  set -a
  # shellcheck disable=SC1090
  source "${env_file}"
  set +a
}

resolve_repo_root() {
  if [[ -f "${REPO_ROOT}/config/defaults.env" && -d "${REPO_ROOT}/template/skill" ]]; then
    echo "${REPO_ROOT}"
    return 0
  fi

  local archive_url="${ENGRAM_REPO_ARCHIVE_URL:-}"
  if [[ -z "${archive_url}" ]]; then
    printf '%s\n' \
      "Remote execution needs ENGRAM_REPO_ARCHIVE_URL because a standalone shell script cannot infer its parent GitHub repo." \
      "Example: ENGRAM_REPO_ARCHIVE_URL=https://github.com/OWNER/REPO/archive/refs/heads/main.tar.gz bash install.sh" >&2
    return 1
  fi

  ARCHIVE_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/engram-install.XXXXXX")"
  local archive_path="${ARCHIVE_TMP_DIR}/repo.tar.gz"
  curl -fsSL "${archive_url}" -o "${archive_path}"
  tar -xzf "${archive_path}" -C "${ARCHIVE_TMP_DIR}"

  local extracted_root
  extracted_root="$(find "${ARCHIVE_TMP_DIR}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "${extracted_root}" ]]; then
    echo "Could not find the extracted repository root." >&2
    return 1
  fi

  echo "${extracted_root}"
}

confirm_replace() {
  local harness="$1"
  local path="$2"

  if [[ ! -e "${path}" ]]; then
    return 0
  fi

  if [[ "${ASSUME_YES}" -eq 1 ]]; then
    return 0
  fi

  printf 'Replace existing %s install at %s? [y/N] ' "${harness}" "${path}" >&2
  local reply
  read -r reply
  case "${reply}" in
    y|Y|yes|YES)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

install_one() {
  local harness="$1"
  local root_dir="$2"
  local skill_name="$3"
  local rendered_skill_dir="$4"
  local dest_dir="${root_dir}/${skill_name}"

  mkdir -p "${root_dir}"

  if ! confirm_replace "${harness}" "${dest_dir}"; then
    echo "Skipped ${harness}."
    return 0
  fi

  if [[ -e "${dest_dir}" ]]; then
    rm -rf "${dest_dir}"
  fi

  cp -R "${rendered_skill_dir}" "${dest_dir}"
  echo "Installed ${harness}: ${dest_dir}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      TARGET_MODE="all"
      ;;
    --codex|--claude|--cursor)
      if [[ "${TARGET_MODE}" == "all" ]]; then
        TARGET_MODE=""
      fi
      TARGET_MODE="${TARGET_MODE} $1"
      ;;
    --legacy-codex)
      AUTO_LEGACY_CODEX=1
      ;;
    --no-legacy-codex)
      AUTO_LEGACY_CODEX=0
      ;;
    --yes)
      ASSUME_YES=1
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

REPO_ROOT="$(resolve_repo_root)"
CONFIG_FILE="${REPO_ROOT}/config/defaults.env"
load_env_file "${CONFIG_FILE}"

if [[ -n "${DEFAULT_REPO_ARCHIVE_URL}" && -z "${ENGRAM_REPO_ARCHIVE_URL:-}" ]]; then
  export ENGRAM_REPO_ARCHIVE_URL="${DEFAULT_REPO_ARCHIVE_URL}"
fi

RENDER_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/engram-render.XXXXXX")"
trap 'cleanup; [[ -d "${RENDER_ROOT}" ]] && rm -rf "${RENDER_ROOT}"' EXIT

RENDERED_SKILL_DIR="$(
  python3 "${REPO_ROOT}/scripts/render_skill.py" \
    --repo-root "${REPO_ROOT}" \
    --output-dir "${RENDER_ROOT}"
)"

if [[ ! -d "${RENDERED_SKILL_DIR}" ]]; then
  echo "Rendered skill directory not found: ${RENDERED_SKILL_DIR}" >&2
  exit 1
fi

declare -a TARGETS=()
if [[ "${TARGET_MODE}" == "all" ]]; then
  TARGETS=(codex claude cursor)
else
  for item in ${TARGET_MODE}; do
    TARGETS+=("${item#--}")
  done
fi

for target in "${TARGETS[@]}"; do
  case "${target}" in
    codex)
      install_one "Codex" "${HOME}/.agents/skills" "${PRODUCT_NAME}" "${RENDERED_SKILL_DIR}"
      ;;
    claude)
      install_one "Claude" "${HOME}/.claude/skills" "${PRODUCT_NAME}" "${RENDERED_SKILL_DIR}"
      ;;
    cursor)
      install_one "Cursor" "${HOME}/.cursor/skills" "${PRODUCT_NAME}" "${RENDERED_SKILL_DIR}"
      ;;
    *)
      echo "Unknown target: ${target}" >&2
      exit 1
      ;;
  esac
done

if [[ "${AUTO_LEGACY_CODEX}" -eq 1 ]]; then
  LEGACY_BASE="${CODEX_HOME:-${HOME}/.codex}"
  LEGACY_ROOT="${LEGACY_BASE}/skills"
  if [[ -n "${CODEX_HOME:-}" || -d "${LEGACY_BASE}" ]]; then
    install_one "Codex legacy" "${LEGACY_ROOT}" "${PRODUCT_NAME}" "${RENDERED_SKILL_DIR}"
  fi
fi
