# dotagents

Clones and installs the separate [dotagents](https://github.com/fgrehm/dotagents) repository after dotfiles' first successful `chezmoi apply`. The checkout is managed as a plain Git repo, not as part of the chezmoi source state.

## Behavior

- Clone to `/data/projects/oss/dotagents` when `/data/projects` exists.
- Otherwise, use `~/Projects/oss/dotagents` when `~/Projects` exists.
- Otherwise, use `~/.local/share/dotagents`.
- Try `git@github.com:fgrehm/dotagents.git` with SSH batch mode first; if that fails, retry with `https://github.com/fgrehm/dotagents.git`.
- Reuse an existing dotagents checkout without pulling. Refuse to overwrite a non-repository or a checkout with a different origin.
- Delegate installation to the clone's `install.sh`.

The run-once script fails if cloning or installation fails, so chezmoi can retry on the next apply. An existing checkout's installer is also run the first time this recipe executes.
