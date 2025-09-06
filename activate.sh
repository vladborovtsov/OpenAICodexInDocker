# Source this file to add Codex Docker helpers to your shell.
# Usage:
#   source ./activate.sh
#   codex-docker-build
#   codex-docker-shell
#   codex-auth-docker-run

IMAGE_NAME="my-codex-image"
CODEX_CONFIG_PATH="$HOME/.codex-docker-config"

codex-docker-build() {
  docker build -t $IMAGE_NAME .
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