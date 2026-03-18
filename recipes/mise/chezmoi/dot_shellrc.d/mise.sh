# shellcheck shell=bash
# mise (dev tool manager) - shims-based setup.
#
# Using shims instead of `mise activate` so that ~/.local/bin (added by
# env.sh) keeps higher precedence. Shims still support per-directory version
# switching by reading PWD on each invocation.
#
# Trade-off: env vars exported by mise (e.g. JAVA_HOME) won't be set
# automatically on cd. If a recipe needs that, it should use `mise activate`.

if command -v mise >/dev/null 2>&1; then
  MISE_SHIMS_DIR="$(mise shims-dir 2>/dev/null || echo "$HOME/.local/share/mise/shims")"
  case ":$PATH:" in
    *":$MISE_SHIMS_DIR:"*) ;;
    *) export PATH="$PATH:$MISE_SHIMS_DIR" ;;
  esac
fi
