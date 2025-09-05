# Use the official OpenAI environment as a base image
FROM ghcr.io/openai/codex-universal:latest

# Switch to the root user to install global packages
USER root

# Install the Codex CLI tool globally by first sourcing the nvm script
RUN . /root/.nvm/nvm.sh && npm install -g @openai/codex

# Install supplementary tools
RUN apt-get update && \
    apt-get install -y vim nano mc htop bat && \
    rm -rf /var/lib/apt/lists/*

# Set the default working directory
WORKDIR /workspace
