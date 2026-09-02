# base

Installs foundational packages that other recipes depend on (jq, unzip, wget, gnupg, fd).
Scripts use a `000-` prefix to guarantee they run before all other recipe scripts.

- Debian: installs via `apt-get` (`fd-find` provides `fdfind`)
- In unprivileged containers, missing packages are skipped; `jq` is installed through mise instead
- Omarchy: installs via `omarchy pkg add` (`fd` provides `fd`); a `~/.local/bin/fdfind`
  symlink is created so scripts that call `fdfind` keep working
