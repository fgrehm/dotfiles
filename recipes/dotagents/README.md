# dotagents

Clones and installs the separate [dotagents](https://github.com/fgrehm/dotagents) repository after dotfiles' first successful `chezmoi apply`. The checkout is managed as a plain Git repo, not as part of the chezmoi source state.

## Behavior

- Clone to `/data/projects` when it is a mount point (a guest whose project tree is mounted there), otherwise to `~/Projects/oss` when `~/Projects` exists, otherwise to `~/.local/share`.
- Clone with `https://github.com/fgrehm/dotagents.git` only. An existing GitHub SSH-origin checkout is switched to the HTTPS remote without pulling.
- Reuse an existing dotagents checkout without pulling. Refuse to overwrite a non-repository or a checkout with a different origin.
- Delegate installation to the clone's `install.sh`.

The run-once script fails if cloning or installation fails, so chezmoi can retry on the next apply. An existing checkout's installer is also run the first time this recipe executes.

## Project tree root

The checkout lives in the project tree, so the recipe has to know where that tree is rooted. On the laptop it is `~/Projects/oss`; everywhere else it is mounted at `/data/projects`, and the mount point is the tree root, so the checkout belongs directly in `/data/projects`. The distinction has to be made on the mount rather than on the directory. Inside a guest `/data/projects` exists as a mount of the host tree, so testing only for the directory produced a stray `~/Projects/oss/oss/dotagents` instead of reusing the checkout that is already there.
