Fork notice: vendored from https://github.com/omacom/omarchy (`shell/plugins/agents` on the `quattro` branch) at upstream commit e848f1df97bbbe23db42fc2b1fb04937d7a0eae0. The plugin directory itself last changed at 3af7675a10fdfc5a49789ea4723e454aac17704b (v4.0.0-91); the vendored copy is byte-identical to `shell/plugins/agents` at the baseline commit.

Rebranded as `omarchy.myagents` so it can coexist with (and eventually replace) the stock `omarchy.agents` plugin:

- `manifest.json`: id `omarchy.myagents`, name/displayName `My Agents`
- `Panel.qml`: `moduleName`/`ipcTarget` changed to `omarchy.myagents` (hardcoded upstream; must not collide with the stock plugin's IPC handlers)

Everything else is upstream verbatim, including the usage record directory (`~/.local/state/omarchy/agents/usage`) and the settings schema. Planned local changes (do not exist yet):

- Codex rate limits read via pi's `~/.pi/agent/auth.json` token instead of the `codex` CLI RPC.
- Fetch-on-open refresh (refresh timer gated on panel open) instead of always-running.
- New collectors for the `ollama-cloud` and `opencode-go` pi subscriptions (local records must use the ids from the `pi-usage-snapshot` README contract).
- Cross-machine snapshots for non-plugin machines are produced by the `pi-usage-snapshot` dotfiles recipe (`~/.local/bin/pi-usage-snapshot`).

Upstream note: the quattro plugin API surface (`PluginShellApi`, `AuthServiceStore`, plugin auth boundary) landed after the plugin was written and does not constrain it — the vendored copy is compatible with the current shell as-is.

Install/replace flow (manual, not automated by chezmoi so the switch stays deliberate):

```
omarchy plugin disable omarchy.agents
omarchy plugin enable omarchy.myagents --section center
```
