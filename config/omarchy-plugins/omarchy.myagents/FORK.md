Fork notice: vendored from https://github.com/omacom/omarchy (`shell/plugins/agents` on the `quattro` branch) at upstream commit e848f1df97bbbe23db42fc2b1fb04937d7a0eae0. The plugin directory itself last changed at 3af7675a10fdfc5a49789ea4723e454aac17704b (v4.0.0-91); the vendored copy is byte-identical to `shell/plugins/agents` at the baseline commit.

Rebranded as `omarchy.myagents` so it can coexist with (and eventually replace) the stock `omarchy.agents` plugin:

- `manifest.json`: id `omarchy.myagents`, name/displayName `My Agents`
- `Panel.qml`: `moduleName`/`ipcTarget` changed to `omarchy.myagents` (hardcoded upstream; must not collide with the stock plugin's IPC handlers)

Everything else is upstream verbatim, including the usage record directory (`~/.local/state/omarchy/agents/usage`) and the settings schema. Implemented on top of upstream:

- `bin/myagents-usage-update` — fork updater bundled in the plugin dir, keeping the `omarchy-agent-usage-update` CLI contract (`--force`, `--limits-only`, `--except`, agent ids) and record shape. codex/ollama-cloud/opencode-go stats come from pi session logs (`~/.pi/agent/sessions` + bb's `~/.bb/pi-bridge-sessions`, one shared cached scan) and limits from the providers' usage endpoints authenticated with pi's `~/.pi/agent/auth.json` credentials: codex `GET chatgpt.com/backend-api/wham/usage` (Bearer + `ChatGPT-Account-Id`), opencode-go `GET opencode.ai/zen/go/v1/usage`, ollama-cloud `GET ollama.com/api/usage` (needs `User-Agent: undici`; rolling window, no reset time). codex `credits.balance` maps to the record's balance card (`funded: 0`, so the fuel gauge hides and only the amount renders). claude/fireworks delegate to the stock omarchy collectors. An expired codex token is *not* refreshed here — pi owns auth.json and refresh rotation; the record reports `run /login openai-codex in pi` and self-heals when pi next runs.
- `Main.qml` invokes the bundled updater (`updaterPath` via `Qt.resolvedUrl`) and the refresh timer is gated on `opened` (fetch-on-open; `triggeredOnStart` gives the instant refresh on open; Panel binds `opened: root.opened`). A one-shot `runUpdate("limits")` at shell start keeps the bar from sitting stale until the first panel open.
- `manifest.json` adds `ollama-cloud`/`opencode-go` provider defaults (also enabled by default via `providerEnabled`).
- `Main.qml`'s sync gains a `syncDirs` setting (comma-separated, read-only merge sources next to the write-side `syncDir`), multi-folder scanning, and a deviceId dedup (newest `updatedAt` wins) so a machine appearing in several folders cannot double-count device-scoped stats.

- `assets/` gains `ollama-cloud.svg`/`ollama-cloud-light.svg` (Ollama llama mark) and `opencode-go.svg`/`opencode-go-light.svg` (OpenCode square-in-square mark), sourced from [Simple Icons](https://simpleicons.org) (CC0) and following the panel's white-mark + `-light` twin convention like codex.

Record ids follow the `pi-usage-snapshot` contract (`codex`, `ollama-cloud`, `opencode-go`) so local records, cross-machine snapshots, and future collectors all aggregate under the same keys. Cross-machine snapshots for non-plugin machines are produced by the `pi-usage-snapshot` dotfiles recipe (`~/.local/bin/pi-usage-snapshot`).

Upstream note: the quattro plugin API surface (`PluginShellApi`, `AuthServiceStore`, plugin auth boundary) landed after the plugin was written and does not constrain it — the vendored copy is compatible with the current shell as-is.

Install/replace flow (manual, not automated by chezmoi so the switch stays deliberate):

```
omarchy plugin disable omarchy.agents
omarchy plugin enable omarchy.myagents --section center
```
