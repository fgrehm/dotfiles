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

# Install tools from .tool-versions (single source of truth for tool versions)
COPY --chown=vscode .tool-versions /tmp/.tool-versions
RUN mise use --global $(awk '!/^#/ && NF {print $1"@"$2}' /tmp/.tool-versions) && mise install && rm /tmp/.tool-versions
