FROM mcr.microsoft.com/devcontainers/base:debian-13

# Install chezmoi-recipes from GitHub releases
ARG CHEZMOI_RECIPES_VERSION=0.5.0
ARG TARGETARCH=amd64
RUN wget -qO- "https://github.com/fgrehm/chezmoi-recipes/releases/download/v${CHEZMOI_RECIPES_VERSION}/chezmoi-recipes_linux_${TARGETARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin chezmoi-recipes

USER vscode

ENV XDG_CONFIG_HOME="/home/vscode/.config"
ENV XDG_DATA_HOME="/home/vscode/.local/share"
ENV PATH="/home/vscode/.local/bin:/home/vscode/.local/share/mise/shims:${PATH}"

# Install mise
RUN wget -qO- https://mise.jdx.dev/install.sh | sh

# Install tools (keep versions in sync with .tool-versions)
RUN mise use --global bats@1.11.1 chezmoi@2.70.0 && mise install
