# fgrehm.pomodoro

A bundled, locally maintained Omarchy Pomodoro plugin.

This plugin is based on [nejcm/omarchy-pomodoro](https://github.com/nejcm/omarchy-pomodoro), commit `eeff9dabd197b46f75b8adc975e03cdd52bfd25b`. The original project and its author, Nejc, deserve credit for the timer, history, persistence, and shell integration this plugin starts from.

The source is vendored into the dotfiles repository so it can be customized without installing or updating an external plugin checkout. It remains available under the original MIT license in `LICENSE`.

## Runtime flow

- The canonical source lives at `config/omarchy-plugins/fgrehm.pomodoro/`.
- The `omarchy-plugins` recipe symlinks it to `~/.config/omarchy/plugins/fgrehm.pomodoro/`.
- The recipe's post-apply script runs `omarchy plugin enable fgrehm.pomodoro --section center`.
- Omarchy discovers the plugin and loads `Service.qml` once, while `BarWidget.qml` provides the per-monitor bar view.
- The service owns timer state, transitions, notifications, history, and active-session persistence.
- History is stored in `~/.local/state/omarchy/pomodoro.json`.
- An active or paused session is stored in `~/.local/state/omarchy/pomodoro-session.json` and restored when the service starts. Running sessions resume from their wall-clock deadline; expired sessions complete once during restore.
- Pomodoro mode is the default tab and mode. Focus, short-break, and long-break states set muted red, green, and blue bar backgrounds. Idle restores the current theme bar color.

Saving a plugin file normally triggers Omarchy's plugin hot reload. Use `omarchy-shell shell rescanPlugins` to request discovery again, or `omarchy restart shell` when testing service startup and session restoration.
