# Omarchy plugins

Bundled Omarchy shell plugins. Plugin source is maintained under `config/omarchy-plugins/` and linked into `~/.config/omarchy/plugins/` rather than installed from an external repository. Vendored forks are marked with a `FORK.md` file and retain their upstream link and source commit.

## Pomodoro

`fgrehm.pomodoro` is based on [nejcm/omarchy-pomodoro](https://github.com/nejcm/omarchy-pomodoro), currently from commit `eeff9dabd197b46f75b8adc975e03cdd52bfd25b`.

The recipe links the plugin source from `config/omarchy-plugins/fgrehm.pomodoro` into `~/.config/omarchy/plugins/` and runs `omarchy plugin enable fgrehm.pomodoro --section center`. Cleanup of the layout entry when the recipe is removed is deferred.

## Screen Time

`agx.screen-time` is a vendored fork of [ax1g/quickshell-screentime-plugin](https://github.com/ax1g/quickshell-screentime-plugin), currently from commit `1f5a222b5367587d70755906d282fca92d049daf` (v1.4.0). Local changes may be contributed upstream. The recipe links it from `config/omarchy-plugins/agx.screen-time` into `~/.config/omarchy/plugins/` and enables it in the Omarchy shell. Its history remains in `~/.config/omarchy/screen-time/history.json` when the plugin is removed.

## My Agents

`fgrehm.myagents` is a vendored fork of the stock [omacom/omarchy](https://github.com/omacom/omarchy) `omarchy.agents` bar plugin (`shell/plugins/agents` vendored at upstream commit `e848f1df97bbbe23db42fc2b1fb04937d7a0eae0`, where the plugin last changed at `3af7675a10fdfc5a49789ea4723e454aac17704b`), rebranded so it can coexist with the stock plugin. It reads the same usage records directory, so both plugins show identical numbers while testing. See `FORK.md` inside the plugin for the planned pi-auth changes. Unlike the stock plugin it is **not** in the default bar layout and is not auto-enabled: switch over manually with `omarchy plugin disable omarchy.agents && omarchy plugin enable fgrehm.myagents --section right`.

It pairs with the `pi-usage-snapshot` recipe, which feeds cross-machine pi usage snapshots from VMs/containers into the plugin's sync directory. The fork ships its own bundled updater (`bin/myagents-usage-update`) so codex/ollama-cloud/opencode-go limits and stats come from pi's `~/.pi/agent/auth.json` instead of the codex CLI, and only fetches while the panel is open.
