## OpenAI Codex in Docker

This repository provides a lightweight way to run the OpenAI Codex CLI inside Docker, keeping your host clean while persisting CLI auth/config on your machine. It targets the OpenAI Codex project at https://github.com/openai/codex.

#### Contents
- Dockerfile based on ghcr.io/openai/codex-universal with @openai/codex preinstalled.
- activate.sh that adds helper shell functions:
  - codex-docker-build — build the image.
  - codex-docker-shell — open an interactive shell in the container with your current project mounted.
  - codex-auth-docker-run — run Codex auth flow inside the container.
  - codex-deactivate — remove helper functions from the current shell.

#### Prerequisites
- Docker installed and running.
- Bash or Zsh shell.

#### Quick Start
1) Clone this repo and enter the directory.

2) Build the image:
   `source ./activate.sh`
   `codex-docker-build`

3) Authenticate Codex CLI inside Docker (one-time):
   `codex-auth-docker-run`

   This command uses host networking and persists Codex CLI config under:
   - Host: ~/.codex-docker-config
   - Container: /root/.codex (mounted)

4) Start a shell with your current project mounted:
   `codex-docker-shell`

   The container will:
   - Mount your current directory at /workspace/<your-folder-name>
   - Use ~/.codex-docker-config as Codex config
   - Start in that workspace directory

Persist activation in your shell (bashrc/zshrc)
To have the helper functions available in every new shell, add a line to your shell init file that sources activate.sh from this repo. Replace /absolute/path/to/OpenAICodexInDocker with your actual path.

- Bash (e.g., ~/.bashrc or ~/.bash_profile on macOS):
    ```bash 
      if [ -f "/absolute/path/to/OpenAICodexInDocker/activate.sh" ]; then
        . "/absolute/path/to/OpenAICodexInDocker/activate.sh"
      fi
    ```

- Zsh (e.g., ~/.zshrc):
    ```shell
    if [ -f "/absolute/path/to/OpenAICodexInDocker/activate.sh" ]; then
        source "/absolute/path/to/OpenAICodexInDocker/activate.sh"
    fi
    ```
  

After editing your rc file, reload it or open a new terminal:
- For Bash: `source ~/.bashrc`
- For Zsh: `source ~/.zshrc`

#### Where Codex stores auth/config
- On your host, files are kept in: ~/.codex-docker-config
- They are bind-mounted into the container at: /root/.codex
- You can back up or remove ~/.codex-docker-config if you need to reset auth.

#### Known quirk with codex auth link
When you run `codex-auth-docker-run`, Codex may print the sign-in URL in a slightly odd, wrapped way (with embedded line breaks) due to how the TTY/line wrapping behaves in Docker. If your terminal doesn’t let you open the link directly:
- Carefully select and copy the full URL from the output.
- Paste it into a text editor and remove any line breaks or stray spaces so it’s a single continuous URL.
- Paste the cleaned URL into your browser to complete the login.

#### Tips
- Update the image if Dockerfile changes:
  `codex-docker-build`
- Temporarily remove functions from your current shell:
  `codex-deactivate`


#### Notes
- --network=host is used for the auth flow to make opening the local browser and callbacks simpler.

