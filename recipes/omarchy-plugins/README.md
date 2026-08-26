# Omarchy plugins

Bundled Omarchy shell plugins. Plugin source is deployed directly rather than installed from an external repository.

## Pomodoro

`fgrehm.pomodoro` is based on [nejcm/omarchy-pomodoro](https://github.com/nejcm/omarchy-pomodoro), currently from commit `eeff9dabd197b46f75b8adc975e03cdd52bfd25b`.

The recipe adds the plugin source under `~/.config/omarchy/plugins/` and runs `omarchy plugin enable fgrehm.pomodoro --section center`. Cleanup of the layout entry when the recipe is removed is deferred.
