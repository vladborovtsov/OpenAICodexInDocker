# Source this file to add Codex Docker helpers to your shell.
# Usage:
#   source ./activate.sh
#   codex-docker-build
#   codex-docker-shell
#   codex-auth-docker-run

IMAGE_NAME="my-codex-image"
CODEX_CONFIG_PATH="$HOME/.codex-docker-config"

# Determine the directory of this script (the repo root), even when sourced from elsewhere.
# Works with Bash and most POSIX shells; realpath fallback if available.
if [ -n "$BASH_SOURCE" ]; then
  _codex_script_path="$BASH_SOURCE"
else
  # Fallback: when $BASH_SOURCE is not set (other shells), try $0 if sourced via ". ./activate.sh"
  _codex_script_path="$0"
fi
# Resolve to an absolute directory
if command -v realpath >/dev/null 2>&1; then
  CODEX_REPO_DIR="$(dirname "$(realpath "$_codex_script_path")")"
else
  # Portable resolution: cd into the script dir and print pwd
  CODEX_REPO_DIR="$(cd "$(dirname "$_codex_script_path")" 2>/dev/null && pwd)"
fi
unset _codex_script_path

codex-docker-build() {
  if [ -z "$CODEX_REPO_DIR" ]; then
    echo "Failed to locate repository directory for docker build." >&2
    return 1
  fi
  echo "Building Docker image '$IMAGE_NAME' from: $CODEX_REPO_DIR" >&2
  docker build --pull -t "$IMAGE_NAME" "$CODEX_REPO_DIR"
}

codex-docker-shell() {
  local cwd
  cwd="$(pwd)"
  if [ "$cwd" = "$HOME" ]; then
    echo "⚠️ Warning: You are running codex-docker-shell from your HOME directory." >&2
    echo "This will mount your entire HOME into the container workspace." >&2
    printf "Proceed with mounting HOME? [y/N]: " >&2
    IFS= read -r confirm
    case "$confirm" in
      [yY]|[yY][eE][sS]) ;;
      *) echo "Canceled." >&2; return 1 ;;
    esac
  fi
  docker run --rm -it \
    -v "$CODEX_CONFIG_PATH:/root/.codex" \
    -v "${cwd}:/workspace/$(basename "${cwd}")" \
    -w "/workspace/$(basename "${cwd}")" \
    $IMAGE_NAME
}

codex-auth-docker-run() {
  local cwd
  cwd="$(pwd)"
  if [ "$cwd" = "$HOME" ]; then
    echo "⚠️ Warning: You are running codex-auth-docker-run from your HOME directory." >&2
    echo "This will mount your entire HOME into the container workspace." >&2
    printf "Proceed with mounting HOME? [y/N]: " >&2
    IFS= read -r confirm
    case "$confirm" in
      [yY]|[yY][eE][sS]) ;;
      *) echo "Canceled." >&2; return 1 ;;
    esac
  fi
  docker run --rm -it \
    --network="host" \
    --entrypoint="/bin/bash" \
    -v "$CODEX_CONFIG_PATH:/root/.codex" \
    -v "${cwd}:/workspace/$(basename "${cwd}")" \
    -w "/workspace/$(basename "${cwd}")" \
    $IMAGE_NAME \
    -c ". /root/.nvm/nvm.sh && screen codex auth"
}

codex-deactivate() {
  unset -f codex-docker-build codex-docker-shell codex-auth-docker-run codex-deactivate
}