# Use the official OpenAI environment as a base image
FROM ghcr.io/openai/codex-universal:latest

# Switch to the root user to install global packages
USER root

# Install the Codex CLI tool globally by first sourcing the nvm script
RUN . /root/.nvm/nvm.sh && npm install -g @openai/codex

# Install supplementary tools
RUN apt-get update && \
    apt-get install -y vim nano mc htop bat screen tmux && \
    rm -rf /var/lib/apt/lists/*

# Set the default working directory
WORKDIR /workspace

# Ensure /usr/local/bin exists
RUN install -d -m 0755 /usr/local/bin
# Add the tmux layout script into the image
ADD scripts/start-tmux-layout /usr/local/bin/start-tmux-layout
RUN chmod +x /usr/local/bin/start-tmux-layout

# Make it the default when no args are provided (uses base entrypoint: bash --login "$@")
CMD ["-lc","start-tmux-layout"]
