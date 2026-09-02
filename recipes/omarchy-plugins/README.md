# Omarchy plugins

Bundled Omarchy shell plugins. Plugin source is deployed directly rather than installed from an external repository. Vendored forks are marked with a `FORK.md` file and retain their upstream link and source commit.

## Pomodoro

`fgrehm.pomodoro` is based on [nejcm/omarchy-pomodoro](https://github.com/nejcm/omarchy-pomodoro), currently from commit `eeff9dabd197b46f75b8adc975e03cdd52bfd25b`.

The recipe adds the plugin source under `~/.config/omarchy/plugins/` and runs `omarchy plugin enable fgrehm.pomodoro --section center`. Cleanup of the layout entry when the recipe is removed is deferred.

## Screen Time

`agx.screen-time` is a vendored fork of [ax1g/quickshell-screentime-plugin](https://github.com/ax1g/quickshell-screentime-plugin), currently from commit `1f5a222b5367587d70755906d282fca92d049daf` (v1.4.0). Local changes may be contributed upstream. The recipe enables it in the Omarchy shell. Its history remains in `~/.config/omarchy/screen-time/history.json` when the plugin is removed.
