import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Pomodoro bar widget -- a *view* onto Service.qml.
//
// Instantiated once per rendered module slot: zero or more per screen, never
// a count this file may assume. Zero is real -- a plugin enabled only at the
// top level has a service and no bar widget at all -- and so is more than one,
// since nothing stops a layout from listing the same id twice
// (Bar.qml:1493-1518 repeats a slot per entry).
//
// It therefore owns no timer state: the countdown, the completion
// notification and the session-history file all live on the single service
// instance reached through `timer` below.
//
// It does own one write, though: persistSettings() saves settled setting
// changes back to this widget's shell.json entry. That cannot live on
// the service -- the shell injects `bar` and `settings` here and neither one
// there -- so the service says *when* and *who*, and this file does it.
//
// Everything else here is genuinely per-surface: the button, the panel
// loader, and the open/close contract Bar.qml's popout coordinator looks for
// on the bar-widget root (see the panel routing section).
BarWidget {
    id: root

    // Idle glyph: nf-fa-hourglass_half (U+F252). Classic Font Awesome
    // (U+F0xx-U+F2xx), the one Nerd Fonts range v3 kept intact -- unlike the
    // legacy MDI block (U+F500-U+FD46) it deleted. Monochrome, so it inherits
    // the bar foreground. Built from a hex literal, never a pasted character:
    // a raw Private-Use-Area byte in the file is invisible in review, and
    // this keeps the source pure ASCII. Panel.qml's glyphs follow the same
    // rule; that block carries the codepoint-range rationale for all four.
    readonly property string idleGlyph: String.fromCharCode(0xf252)

    // --- the shared timer --------------------------------------------------
    // `_services` is a property on shell.qml, so this binding is live: it
    // flips from null to the instance the moment the service mounts, and back
    // to null if `_syncServices` tears it down. Guarded on the function's
    // existence so an older host shell without the service API degrades to a
    // visibly dead widget (idle glyph, inert panel) plus the warning below,
    // instead of throwing on every binding evaluation.
    // Keyed by `moduleName`, never by a hardcoded id. The bar could only have
    // rendered this widget by resolving its registry entry, which is stored
    // under `String(manifest.id)` (shell.qml:678) and looked up by
    // `canonicalWidgetId(moduleName)` (Bar.qml:1536-1539) -- and that function
    // is the identity (Commons/Util.qml:61-63). So a rendered widget's
    // moduleName *is* the manifest id, which is the same key `_services` uses
    // (shell.qml:275-277). A constant would only match the unrenamed original:
    // copy this folder, change `id` in manifest.json, enable it, and the
    // service mounts under the new id while the lookup asks for the old one --
    // a permanently dead hourglass with nothing logged, since serviceFor()
    // exists and simply answers null. moduleName is strictly the safer key,
    // and it is already what persistSettings() writes against.
    readonly property var timer: bar && bar.shell && moduleName !== ""
                                 && typeof bar.shell.serviceFor === "function"
                                 ? bar.shell.serviceFor(moduleName) : null

    // Mounting the service is the host's job alone -- deliberately, and this
    // widget must not "help".
    //
    // shell.qml's ensureService() (line 283) is only idempotent once the
    // instance is recorded, and its Component.Loading branch (line 315) hooks
    // finalize() to statusChanged and returns *without* reserving the key. A
    // second caller inside that window therefore passes the
    // `if (_services[key]) return` guard, builds a second component and a
    // second instance; both are parented to serviceHost, and lines 312-313
    // record only the last. The orphan keeps its ticker and its FileView on
    // pomodoro.json -- precisely the several-timers-one-history-file bug this
    // plugin split a service out to kill. Calling from every bar surface
    // multiplied the callers by surface count, making the widget the largest
    // contributor to a race it cannot fix host-side.
    //
    // Nothing is lost by staying out of it. Every path that can produce this
    // widget also drives _syncServices(): shell.qml's own Component.onCompleted
    // (line 155), `onPluginsChanged` (line 358), and `onScanFinished`
    // (line 767, synchronizing at 775) -- and onShellConfigChanged re-emits
    // pluginsChanged (line 69), so the very config change that puts the entry
    // on the bar mounts the service in the same turn. Until it lands, `timer`
    // is null, which is the state the next comment block describes and the
    // widget already renders honestly.
    function warnIfNoServiceApi() {
        if (!bar || !bar.shell) return
        if (typeof bar.shell.serviceFor === "function") return
        // Otherwise the widget is a permanently dead hourglass with no
        // explanation anywhere.
        console.warn("pomodoro: host shell has no serviceFor();",
                     "the timer cannot start. Update omarchy-shell.")
    }

    // The shell injects omarchyPath/shell/manifest/... into a service, but not
    // `settings` -- those live on the bar *entry*, which only this widget can
    // see. So resolve them here (setting() applies the shell.json fallbacks)
    // and hand the service already-resolved values; it still re-validates
    // `minutes` through Model, because shell.json is hand-edited.
    //
    // Called from onTimerChanged as well as onSettingsChanged, so the mount
    // order does not matter. That means N monitors push N times, and a `var`
    // property re-assignment can re-fire onTimerChanged with an unchanged
    // instance -- applySettings is idempotent for exactly this reason.
    function pushSettings() {
        // Bar.qml's injectProps() assigns `bar` before `settings`, so a push
        // driven by the bar arriving (or by the service mounting in that same
        // window) would hand over setting()'s *fallbacks* rather than the
        // entry. Harmless on the first monitor, not on a second one attached
        // later: the fallback would differ from a duration the user had
        // nudged, and applySettings would take it as a real config change and
        // stomp the nudge. So wait for the entry.
        if (!settingsReceived) return
        if (!timer || typeof timer.applySettings !== "function") return
        timer.applySettings({
            minutes: setting("minutes", Model.DEFAULT_MINUTES),
            breakMinutes: setting("breakMinutes", Model.DEFAULT_BREAK_MINUTES),
            longBreakMinutes: setting("longBreakMinutes", Model.DEFAULT_LONG_BREAK_MINUTES),
            cyclesBeforeLongBreak: setting("cyclesBeforeLongBreak", Model.DEFAULT_CYCLES),
            mode: setting("mode", Model.MODE_POMODORO),
            autoStartBreaks: setting("autoStartBreaks", true) === true,
            autoStartWork: setting("autoStartWork", false) === true,
            notify: setting("notify", true) === true
        })
    }

    // Writes settled setting changes back to this widget's shell.json entry,
    // so they survive a restart instead of being discarded. Reached only
    // through the service's debounce timer, and only by the writer it elected
    // -- once per gesture, once per timer, not once per monitor.
    function persistSettings(patch) {
        if (!settingsReceived) return
        if (!bar || !bar.shell || typeof bar.shell.updateEntryInline !== "function") return
        if (!timer || typeof timer.claimSettingsWriter !== "function") return
        if (!timer.claimSettingsWriter(root)) return

        // Exactly one writable entry, or nothing is written.
        //
        // The write needs a single unambiguous target and the config loader
        // guarantees neither half of that: `allowMultiple` reaches only the
        // widget registry (shell.qml:693) and canonicalWidgetId is the
        // identity function (Commons/Util.qml:61-63), so a hand-edit can
        // repeat the id; and the bar renders a bare id string as a widget
        // while updateEntryInline matches on `arr[i].id` (shell.qml:379), so
        // a string entry is invisible to the write. Proceeding anyway fails
        // silently either way -- copying one entry's settings onto another
        // erases keys (shell.qml:376-389 loops without a break), and a write
        // that matches nothing leaves a change that looks applied until the
        // next restart. So: Service.qml's historyUnreadable posture. Stop
        // writing, name the fault once, leave the file alone. Only saving
        // settings stops; countdown, history and in-session adjustment are
        // untouched.
        //
        // This gives up the top-level `plugins` array updateEntryInline would
        // also search (shell.qml:390-400), deliberately and at no cost: a
        // plugin enabled only there has no bar widget, so nothing can reach
        // this function. Do not re-add the fallthrough -- that loop has no
        // break either, so entering it unsurveyed would rewrite two entries at
        // once.
        var config = bar.shell.shellConfig
        var census = Model.surveyBarEntries(config && config.bar ? config.bar.layout : null,
                                            root.moduleName)
        if (census.total !== 1 || census.writable !== 1) {
            if (census.total > 1)
                warnAboutEntry("duplicate", "'" + root.moduleName + "' appears " + census.total
                    + " times in bar.layout, so there is no single entry to save to")
            else if (census.total === 1)
                warnAboutEntry("stringEntry", "'" + root.moduleName + "' is listed in bar.layout"
                    + " as a bare id string; give it the object form { \"id\": \""
                    + root.moduleName + "\" } so settings can be written to it")
            else
                warnAboutEntry("noEntry", "no writable '" + root.moduleName + "' entry was found"
                    + " in bar.layout")
            return
        }

        // Already what the entry says. Cheap, but it also covers a hand-edit
        // to shell.json that landed inside the debounce window and was
        // adopted: there is nothing of ours left to write.
        var unchanged = true
        for (var patchedKey in patch) {
            if (setting(patchedKey) !== patch[patchedKey]) {
                unchanged = false
                break
            }
        }
        if (unchanged) return

        // Every other key is carried over, not just the ones this plugin
        // knows about: the host replaces the whole entry with what it is
        // handed, and the bar derives `settings` from the entry minus `id`
        // (BarModel.entrySettings). A key dropped here is dropped from the
        // user's shell.json -- `notify` included.
        var entry = { id: root.moduleName }
        for (var key in root.settings) if (key !== "id") entry[key] = root.settings[key]
        for (var patchKey in patch) entry[patchKey] = patch[patchKey]

        // Local first, as the clock widget does. `settings` is what
        // pushSettings() reads, so leaving it stale would let a later push
        // re-announce old values and stomp the change. The write comes
        // straight back through shellConfig -> the bar -> `settings` carrying
        // this same value, which is why the loop settles: applySettings only
        // acts on a value it has not already applied.
        //
        // Its return value is ignored on purpose. With a unique writable
        // target established above, `false` means only that the entry already
        // held what we were about to write (shell.qml:402) -- the value
        // compare above cannot rule that out, because it reads this view's
        // `settings`, which may lag the file.
        root.settings = entry
        bar.shell.updateEntryInline(root.moduleName, entry)
    }

    // Routes a refusal through the service's per-reason latch, so each
    // distinct fault is named once per service instance rather than once per
    // wheel notch or once per monitor. The consequence is the same for all of
    // them, so it is stated here instead of in every message.
    function warnAboutEntry(reason, problem) {
        if (!timer || typeof timer.claimEntryWarning !== "function") return
        if (!timer.claimEntryWarning(reason)) return
        console.warn("pomodoro:", problem + "; settings changes will not be saved to shell.json")
    }

    // Rebinds when the service mounts or `_syncServices` tears it down; a
    // null target is inert, so no guard is needed here.
    Connections {
        target: root.timer
        function onSettingsCommitted(patch) { root.persistSettings(patch) }
    }

    // The bar background is a shared host property, not a theme singleton
    // mutation. Keep the state colors muted so the bar remains readable while
    // still making focus and breaks visually distinct.
    readonly property color focusBarBackground: "#5c2626"
    readonly property color shortBreakBarBackground: "#234d35"
    readonly property color longBreakBarBackground: "#29445c"

    function desiredBarBackground() {
        if (!timer || timer.idle) return Color.bar.background
        if (timer.phase === Model.PHASE_SHORT) return shortBreakBarBackground
        if (timer.phase === Model.PHASE_LONG) return longBreakBarBackground
        return focusBarBackground
    }

    function bindBarBackground() {
        if (!bar) return
        // Install a binding on the actual host Bar instance. This is necessary
        // because the bar object is injected after construction and can be
        // replaced during a plugin reload.
        bar.background = Qt.binding(function () { return root.desiredBarBackground() })
    }

    Connections {
        target: root.timer
        function onRunningChanged() { root.bindBarBackground() }
        function onStartedChanged() { root.bindBarBackground() }
        function onPhaseChanged() { root.bindBarBackground() }
    }

    // Until the service mounts, `timer` is null and the widget shows the idle
    // hourglass -- the same thing a mounted-but-unstarted timer shows, so the
    // bar never flashes a bogus countdown. A click in that window still opens
    // the panel; every control in there is guarded on `timer` and reads as
    // disabled, which is the honest rendering of "no timer yet".
    readonly property string activeTaskTitle: timer && timer.activeTaskId ? (timer.tasks.find(function (task) { return task.id === timer.activeTaskId }) || {}).title || "" : ""
    readonly property string barText: !timer || timer.idle ? idleGlyph
        : (timer.mode === Model.MODE_POMODORO
           && (timer.phase === Model.PHASE_SHORT || timer.phase === Model.PHASE_LONG)
           ? String.fromCharCode(0xf0f4) + "  " : "") + Model.mmss(timer.remainingSeconds) + (root.activeTaskTitle ? " · " + root.activeTaskTitle : "")

    // --- panel routing contract -------------------------------------------
    // Must live on this bar-widget root, not the nested panel — Bar.qml's
    // popout coordinator (findPanelWidget / requestPopout) looks here.
    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() {
        if (panelLoader.item) panelLoader.item.open()
    }

    function close() {
        if (panelLoader.item) panelLoader.item.close()
    }

    function togglePanel() {
        if (panelLoader.item) panelLoader.item.toggle()
    }

    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    function closeForPopoutSwitch() {
        if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
    }

    // Injects what Panel.qml needs onto the loaded instance, same shape as
    // the clock/weather plugins. `hostWidget` is the panel's *identity* (the
    // bar-widget root the popout coordinator keys off); `timer` is where it
    // reads state and drives transitions. They are separate on purpose --
    // there is one panel per monitor but one timer for all of them.
    function injectPanel() {
        var target = panelLoader.item
        if (!target) return
        if ("bar" in target) target.bar = root.bar
        if ("settings" in target) target.settings = root.settings
        if ("anchorItem" in target) target.anchorItem = button
        if ("hostWidget" in target) target.hostWidget = root
        if ("timer" in target) target.timer = root.timer
    }

    // Set by the first settings injection; see pushSettings().
    property bool settingsReceived: false

    onBarChanged: {
        warnIfNoServiceApi()
        injectPanel()
        pushSettings()
        bindBarBackground()
    }

    onSettingsChanged: {
        settingsReceived = true
        injectPanel()
        pushSettings()
    }

    // `timer` is a pushed value on the panel, not a binding, so the panel
    // would otherwise keep a stale (or destroyed) reference when the service
    // mounts late or `_syncServices` tears it down. Re-inject on every change.
    onTimerChanged: {
        injectPanel()
        pushSettings()
        bindBarBackground()
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: root.barText
        dimmed: !!root.timer && root.timer.paused
        onPressed: function (b) {
            // Left click only — no right/middle click actions.
            if (b === Qt.LeftButton) root.togglePanel()
        }
    }

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    // `bar` is injected after construction (Bar.qml injectProps), so this is
    // normally a no-op and onBarChanged does the work. Kept for a host that
    // passes `bar` as an initial property instead, where that signal never
    // fires; the warning is guarded on `bar`, so on a normal host this is
    // silent and onBarChanged does the talking.
    Component.onCompleted: warnIfNoServiceApi()
}
