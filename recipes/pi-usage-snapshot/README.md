# pi-usage-snapshot

Standalone python3 tool that scans pi/agent session logs on a machine and emits a **cross-machine usage snapshot** in the shape consumed by the Omarchy agents bar plugin's sync system (`shell/plugins/agents/Main.qml` — the `syncDir` contract). It lets machines that do **not** run the Omarchy shell plugin (cloud VMs, devcontainers) contribute their pi usage stats to the aggregate shown in the bar.

## Why

The plugin's snapshot *writer* lives inside `Main.qml`, so only machines running the Quickshell shell can push snapshots. This script reimplements the writer as a standalone CLI so any machine with pi session logs can participate, in two modes:

- **Push** (`--dir`): run on the remote (cron/timer), atomically writes `<syncDir>/<deviceId>.json` into a folder shared with the bar machine (Syncthing, bind mount, ...). Repeat `--dir` on a machine that bridges several sync folders.
- **Pull** (`--stdout`): run remotely over SSH from the bar machine, printing the snapshot to stdout so the caller can write it into the local `syncDir` without installing anything on the remote.

## What it scans

Line-based pi session JSONL from (existing dirs only):

- `~/.pi/agent/sessions/**` (standard pi layout, nested per-project dirs)
- `~/.bb/pi-bridge-sessions/**` (bb bridge threads, flat `thr_*.jsonl`)

Only assistant messages carrying `message.usage` count, attributed per-message via `message.provider`/`message.api` (threads can switch providers mid-session). Counting semantics intentionally mirror the upstream `scan_pi_sessions()` in `bin/omarchy-agent-usage-codex` so snapshots merge consistently with locally-collected records: one usage message == one prompt, `recentDays[].messageCount` carries token totals, session == file, and the provider match is `provider == key or api.startswith(key)`.

## Provider ids (the contract)

Aggregate merge is keyed by provider id, so ids emitted here **must** match the ids local records use:

| pi provider    | snapshot id    | name           |
| -------------- | -------------- | -------------- |
| `openai-codex` | `codex`        | `Codex`        |
| `ollama-cloud` | `ollama-cloud` | `Ollama Cloud` |
| `opencode-go`  | `opencode-go`  | `OpenCode Go`  |

(`openai-codex` maps to `codex` because the upstream Codex collector record uses `AGENT_ID = "codex"`; emitting the raw pi provider string would show up as a second, duplicate tab.) Custom fork collectors for ollama-cloud and opencode-go must use these same ids.

All stats are emitted with `scope: "device"` (they count sessions that ran on this machine, so the plugin sums them across devices rather than taking a max).

## Usage

```bash
# Push mode: write into a synced folder
pi-usage-snapshot --dir ~/sync/agents-usage

# Pull mode: from the bar machine, nothing installed on the remote
ssh vm 'python3 -' < ~/.local/bin/pi-usage-snapshot --stdout \
  > ~/.local/state/omarchy/agents/usage-sync/vm.json

# Explicit stable device id (recommended where hostnames churn, e.g. containers)
pi-usage-snapshot --dir ~/sync/agents-usage --device-id buildvm
```

The deviceId defaults to the hostname, sanitized the same way as the plugin's `safeDeviceId()`. Use a stable `--device-id` on machines whose hostname changes between boots.

The bar machine's plugin setting accepts one primary folder plus comma-separated extra folders (`syncDirs`) — its own snapshot is written to every folder and all of them are scanned and merged, so one machine can bridge several sync backends or machine groups.

Scheduling is intentionally out of scope (single-shot script): use cron, a systemd user timer, or a `pi-usage-pull` wrapper.

## Deployment

Installed by this recipe as `~/.local/bin/pi-usage-snapshot` on all targets (Omarchy, Debian containers/VMs). Requires `python3` (stdlib only — no `rg`, no third-party modules).
