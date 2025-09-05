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
  docker run --rm -it \
    -v "$CODEX_CONFIG_PATH:/root/.codex" \
    -v "$(pwd):/workspace/$(basename "$(pwd)")" \
    -w "/workspace/$(basename "$(pwd)")" \
    $IMAGE_NAME
}

codex-auth-docker-run() {
  docker run --rm -it \
    --network="host" \
    --entrypoint="/bin/bash" \
    -v "$CODEX_CONFIG_PATH:/root/.codex" \
    -v "$(pwd):/workspace/$(basename "$(pwd)")" \
    -w "/workspace/$(basename "$(pwd)")" \
    $IMAGE_NAME \
    -c ". /root/.nvm/nvm.sh && codex auth"
}

codex-deactivate() {
  unset -f codex-docker-build codex-docker-shell codex-auth-docker-run codex-deactivate
}