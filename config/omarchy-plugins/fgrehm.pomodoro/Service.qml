import QtQuick
import Quickshell
import Quickshell.Io
import "Model.js" as Model

// The one true pomodoro timer.
//
// BarWidget.qml is instantiated once per rendered module slot -- zero or more
// per screen, and the bar decides which. Owning the timer there meant N
// independent countdowns, N completion notifications, and N whole-file writes
// to the same pomodoro.json with last-writer-wins. The host mounts this
// service once, keyed by plugin id (shell.qml `_syncServices`, parented to
// `serviceHost`), and that is the instance every view resolves through
// `serviceFor` -- so it owns all timer state, the ticker, the notification,
// and the session-history file. "Once" is the host's contract rather than a
// hard guarantee: its own ensureService() can still double-mount during a
// component-load window (BarWidget.qml's mounting comment has the detail),
// which is why this plugin no longer calls it.
//
// Bar widgets are views: they read this through `bar.shell.serviceFor(...)`
// and drive it through the transitions below.
//
// Persistence is split, deliberately. The history file is this file's. The
// *settings* write -- saving a duration nudge or a settings-screen change
// back to the widget's shell.json entry -- is BarWidget.qml's, because the
// entry is only visible from the bar side; this file decides when a change
// has settled and which view writes it (see the commit section near the
// bottom).
//
// Lifecycle worth knowing:
//   - Mounted at startup for any enabled plugin declaring kind "service" with
//     an `entryPoints.service`. This plugin counts as enabled purely by having
//     a `bar.layout` entry (PluginRegistry.findEntryLocation), so no
//     shell.json change and no `keepLoaded` is needed.
//   - Destroyed by `_syncServices` when the plugin is disabled or removed --
//     which in practice also removes the bar entry, so the views go with it.
//   - Recreated on a plugin reload, which drops in-flight timer state. Same as
//     before this split: a running timer has never survived a shell restart.
//
// The shell injects omarchyPath/shell/manifest/barWidgetRegistry/
// pluginRegistry into a service if those properties exist -- it does NOT
// inject `settings`, because settings live on the bar *entry*. Hence
// applySettings() below.
Item {
    id: root

    // --- settings, pushed in by the bar widget(s) ---------------------------
    // Trust boundary: shell.json is hand-edited, so validate through Model.

    // Every setting this plugin has, resolved and validated -- and the object
    // Model's pure functions take as their `settings` argument, so the cycle
    // decides against exactly what the countdown is showing. One snapshot
    // rather than a property per key, because the keys are read together and
    // separate properties drift. Always reassigned whole (installSettings
    // below): a `var` object mutated in place is invisible to the bindings
    // that read it.
    property var settingsSnapshot: ({
        minutes: Model.DEFAULT_MINUTES,
        breakMinutes: Model.DEFAULT_BREAK_MINUTES,
        longBreakMinutes: Model.DEFAULT_LONG_BREAK_MINUTES,
        cyclesBeforeLongBreak: Model.DEFAULT_CYCLES,
        mode: Model.MODE_POMODORO,
        autoStartBreaks: true,
        autoStartWork: false,
        notify: true
    })

    // The keys a snapshot holds, listed once so the intake below and the
    // panel's writes cannot come to know a different set.
    readonly property var settingsKeys: ["minutes", "breakMinutes", "longBreakMinutes",
                                         "cyclesBeforeLongBreak", "mode",
                                         "autoStartBreaks", "autoStartWork", "notify"]

    // Views read these rather than reaching into the snapshot.
    readonly property string mode: settingsSnapshot.mode

    // The duration of the *armed* phase -- what an idle countdown shows, what
    // start() banks into a session, and what the panel's +/- steps. Derived
    // rather than assigned, so arming a break is the single act that retargets
    // all three (see settle()).
    readonly property int durationMinutes: Model.phaseMinutes(phase, settingsSnapshot)

    // The validated form of one key. Every value that reaches the snapshot
    // passes through here, whether it was pushed in from shell.json or set
    // from the panel, so a hand-edit and a panel write are held to the same
    // contract. Booleans use !== false / === true so an absent key lands on
    // its default rather than on `undefined`. An unknown key passes through
    // untouched; nothing reads it, and swallowing it would hide the typo.
    function normalizeSetting(key, value) {
        if (key === "minutes") return Model.validMinutesOr(value, Model.DEFAULT_MINUTES)
        if (key === "breakMinutes") return Model.validMinutesOr(value, Model.DEFAULT_BREAK_MINUTES)
        if (key === "longBreakMinutes") return Model.validMinutesOr(value, Model.DEFAULT_LONG_BREAK_MINUTES)
        if (key === "cyclesBeforeLongBreak") return Model.validCyclesOr(value, Model.DEFAULT_CYCLES)
        if (key === "mode") return Model.validModeOr(value, Model.MODE_POMODORO)
        if (key === "autoStartBreaks") return value !== false
        if (key === "autoStartWork") return value === true
        if (key === "notify") return value !== false
        return value
    }

    // The values last accepted from shell.json, already validated, keyed the
    // same as the snapshot. Three jobs, all load-bearing, and all of them
    // per key -- a nudge to `breakMinutes` must not make an unrelated `mode`
    // change look already-applied:
    //   - Idempotence. Every bar widget pushes settings, and it pushes them
    //     again whenever its `timer` binding re-evaluates. On a dual-head
    //     setup that is several identical calls; only a genuine change may
    //     have an effect.
    //   - It keeps a panel +/- nudge alive. adjustMinutes() writes the armed
    //     phase's key straight into the snapshot while idle; without this
    //     guard the second monitor re-announcing the unchanged config would
    //     stomp the nudge.
    //   - It absorbs the commit round-trip. A settled idle nudge is written
    //     back to shell.json (see the commit section below), and the widget
    //     applies the committed entry to its own `settings` *before* handing
    //     it to the host -- so this map has already moved onto the new value
    //     by the time the config comes back through the bar, and every
    //     announcement of it from then on compares equal and does nothing.
    //     The loop settles instead of ping-ponging.
    // A real shell.json edit still lands, because the validated value differs.
    // A key absent from the map compares unequal to anything normalizeSetting
    // can return, so it doubles as "nothing applied yet" -- the job the -1
    // sentinel did when this was a single int.
    property var appliedSettings: ({})

    // Settings arrive as a plain object of already-resolved values (the bar
    // widget applies its own `setting()` fallbacks first, since only it can
    // see the layout entry). Order against mount does not matter: if the
    // service mounts second, the widget's `timer` binding fires and pushes;
    // if it mounts first, the widget pushes on settings/bar changes anyway.
    function applySettings(obj) {
        var src = obj || ({})
        var patch = ({})
        var applied = null
        for (var i = 0; i < settingsKeys.length; i++) {
            var key = settingsKeys[i]
            var value = normalizeSetting(key, src[key])
            if (appliedSettings[key] === value) continue
            if (!applied) {
                applied = ({})
                for (var k in appliedSettings) applied[k] = appliedSettings[k]
            }
            applied[key] = value
            patch[key] = value
        }
        // Nothing genuinely changed: the common case on a re-push, and the
        // one the three jobs above depend on being a no-op.
        if (!applied) return
        appliedSettings = applied
        installSettings(patch)
    }

    // The one place the snapshot moves. Everything that changes a setting --
    // the intake above, an idle nudge, the panel -- goes through here, so the
    // reassign-whole rule and the mode guard below are written once.
    function installSettings(patch) {
        var next = ({})
        for (var k in settingsSnapshot) next[k] = settingsSnapshot[k]
        for (var p in patch) next[p] = patch[p]
        settingsSnapshot = next

        // Timer mode has no breaks, so it must not be left armed on one. The
        // reachable case: with autoStartBreaks off a finished work interval
        // arms a break without starting it, and armed is neither running nor
        // paused -- so the panel's mode switch is live and the user can flip
        // to Timer right then, leaving a five-minute countdown sitting there
        // as the "next session". Only while idle: the switch is disabled for
        // a started session (Phase D) precisely because swapping the state
        // machine out from under a live countdown is the one thing it must
        // not do, and this side keeps that promise rather than trusting it.
        if (!started && next.mode === Model.MODE_TIMER && phase !== Model.PHASE_WORK)
            phase = Model.PHASE_WORK
    }

    // --- state -------------------------------------------------------------
    property bool running: false
    property bool started: false
    property bool nextPhasePending: false
    property var history: []
    // Task state is shared by all monitor views through this service.
    property var tasks: []
    property string activeTaskId: ""
    // The interval that is armed or running. Only settle() and reset() move
    // it, and in timer mode it never leaves PHASE_WORK (installSettings above
    // holds that, Model.completion never returns a break as `next`).
    property string phase: Model.PHASE_WORK
    // Epoch milliseconds (~1.77e12 today) overflows QML's 32-bit int
    // (max ~2.15e9) — must be double, not int. Same for endsAt and nowMs.
    property double sessionStartedAt: 0
    // Duration in effect for the in-progress session, snapshotted at start()
    // so a mid-session durationMinutes edit can't retroactively relabel the
    // history row or notification for a session that already ran at the old
    // duration (duration changes apply "on the next session").
    property int sessionMinutes: 0

    // The countdown is derived from a wall-clock deadline, never decremented.
    // A Timer that misses intervals (suspend, event-loop starvation) fires
    // once on resume instead of catching up, so a counter would silently keep
    // the time that elapsed while it wasn't running; recomputing against
    // Date.now() cannot drift. The idle branch tracks durationMinutes live;
    // a mid-session shell.json edit still can't reach an in-flight session,
    // because that session reads endsAt/sessionMinutes instead. The one
    // deliberate write to a started session is adjustMinutes() below.
    property double endsAt: 0       // epoch ms; meaningful while running
    // Banked remainder as of the last pause(), in *milliseconds*. Whole
    // seconds would have to round, and the only rounding consistent with the
    // display is Math.ceil -- which hands back up to a second of extra time on
    // every pause/resume cycle, an error that accumulates rather than washing
    // out. Keeping the raw remainder makes resume exact and leaves rounding
    // where it belongs: in the display bindings on the views.
    property double pausedMs: 0
    property double nowMs: 0        // advanced by the ticker

    // A wall-clock day source independent of the countdown ticker. It catches
    // suspend and only changes once a minute, so countToday() does not scan
    // history once a second while a session runs.
    SystemClock {
        id: cycleClock
        precision: SystemClock.Minutes
    }
    readonly property double cycleClockMs: cycleClock.date.getTime()

    // Completed *work* intervals today -- the cycle position, derived from
    // history rather than counted in memory so it survives a reload. Breaks
    // are not logged, so nothing else can move it.
    readonly property int pomodorosToday: Model.countToday(history, cycleClockMs)

    readonly property int remainingSeconds: running ? Math.max(0, Math.ceil((endsAt - nowMs) / 1000))
                                                    : (started ? Math.max(0, Math.ceil(pausedMs / 1000))
                                                               : durationMinutes * 60)

    readonly property bool idle: !started
    readonly property bool paused: started && !running

    function addTask(title) {
        title = String(title || "").trim()
        if (!title) return
        var task = { id: Date.now().toString(36), title: title, pomodoros: 0 }
        tasks = tasks.concat([task])
        activeTaskId = task.id
        persistSession()
    }

    function renameTask(id, title) {
        title = String(title || "").trim()
        if (!title) return
        tasks = tasks.map(function (task) {
            return task.id === id ? ({ id: task.id, title: title, pomodoros: Number(task.pomodoros) || 0 }) : task
        })
        persistSession()
    }

    function deleteTask(id) {
        if (started && id === activeTaskId) return
        tasks = tasks.filter(function (task) { return task.id !== id })
        if (activeTaskId === id) activeTaskId = tasks.length ? tasks[0].id : ""
        persistSession()
    }

    // --- transitions -------------------------------------------------------
    function start() {
        var decision = Model.start({
            running: root.running,
            started: root.started,
            pausedMs: root.pausedMs,
            durationMinutes: root.durationMinutes,
            sessionStartedAt: root.sessionStartedAt,
            sessionMinutes: root.sessionMinutes,
            nowMs: Date.now()
        })
        if (!decision.changed) return
        started = decision.started
        sessionStartedAt = decision.sessionStartedAt
        sessionMinutes = decision.sessionMinutes
        nowMs = decision.nowMs
        endsAt = decision.endsAt
        running = decision.running
        persistSession()
    }

    function pause() {
        var decision = Model.pause({
            running: root.running,
            endsAt: root.endsAt,
            // Use the live instant; root.nowMs may still be stale after the last tick.
            nowMs: Date.now()
        })
        if (!decision.changed) return
        nowMs = decision.nowMs
        if (decision.complete) {
            // A pause that finds completion must not auto-start the next phase.
            complete(false)
            return
        }
        pausedMs = decision.pausedMs
        running = decision.running
        persistSession()
    }

    function reset() {
        var decision = Model.reset({ started: root.started })
        if (!decision.changed) return
        running = decision.running
        started = decision.started
        phase = decision.phase
        persistSession()
    }

    function toggleRunning() {
        if (running) pause()
        else start()
    }

    // Applies what Model.completion decided. The decision itself is pure and
    // tested (Model.js); this only carries it out, in the order a reader
    // would expect: record, announce, arm.
    function complete(allowAutoStart) {
        // Capture once so the count and projected row use the same instant,
        // including across midnight.
        var completionClockMs = root.cycleClockMs
        var decision = Model.completion({
            phase: root.phase,
            sessionStartedAt: root.sessionStartedAt,
            sessionMinutes: root.sessionMinutes,
            pomodorosToday: Model.countToday(root.history, completionClockMs),
            // The completion instant, and deliberately the same clock
            // pomodorosToday was counted against: Model.projectedCount uses
            // the two together to decide whether the row it is about to log
            // lands on the day that count is scoped to. A session begun 23:58
            // and finished 00:03 belongs to yesterday, and handing over a
            // different clock (or none) would decide this transition against
            // a number countToday() will not reproduce a moment later.
            nowMs: completionClockMs
        }, root.settingsSnapshot)

        // A break has no row: a pomodoro is a completed *work* interval.
        if (decision.log) {
            if (activeTaskId) {
                var completedTasks = tasks.map(function (task) {
                    if (task.id !== activeTaskId) return task
                    return ({ id: task.id, title: task.title, pomodoros: (Number(task.pomodoros) || 0) + 1 })
                })
                tasks = completedTasks
                decision.log.taskId = activeTaskId
            }
            history = Model.pushSession(history, decision.log)
            persistHistory()
            persistSession()
        }
        // When the transition offers the in-shell Start button, that card is
        // the notification. Avoid showing a second desktop alert for the same
        // event. Keep the desktop notification for transitions that do not
        // offer auto-start.
        var offersContinue = decision.autoStart && allowAutoStart !== false
        if (decision.notify && !offersContinue)
            sendCompletionNotification(decision.notify, false)
        settle(decision, allowAutoStart)
    }

    // Ends a break early. Breaks only -- which also makes it inert in timer
    // mode, where the phase never leaves work -- and it logs nothing: a break
    // that was skipped was not worked, and one that was rested through is not
    // a pomodoro either. Reachable both while the break runs and while it
    // merely sits armed; both mean the same thing from the user's side.
    function skipBreak() {
        if (phase !== Model.PHASE_SHORT && phase !== Model.PHASE_LONG) return
        settle(Model.skip({ phase: root.phase }, root.settingsSnapshot))
    }

    // The single settle path: the one place a next phase is installed, shared
    // by complete() and skipBreak() so the cycle cannot advance two different
    // ways. Clears exactly the ticker state the reset() call at the tail of
    // the old complete() cleared, and no more: endsAt, pausedMs and
    // sessionMinutes are left as they are because `started` is now false, and
    // the next start() reads none of them -- it arms from durationMinutes.
    function settle(decision, allowAutoStart) {
        running = false
        started = false
        // Before offering the next phase, so Start banks the armed phase's
        // duration rather than the finished one's.
        phase = decision.next.phase
        nextPhasePending = decision.autoStart && allowAutoStart !== false
        persistSession()
    }

    function startPendingPhase() {
        if (!nextPhasePending || started) return
        nextPhasePending = false
        start()
    }

    function dismissPendingPhase() {
        nextPhasePending = false
    }

    // --- duration adjustment, panel +/- and wheel --------------------
    // Both route through Model.adjustSession so the clamp and the
    // never-shorten-past-what-is-left guard live once, and are testable.

    // Live remainder in milliseconds. Date.now(), not nowMs: the ticker
    // advances nowMs once a second, so a guard measured against it is up to a
    // second stale -- enough for a -5 to be allowed when it would in fact
    // land the deadline in the past.
    function liveRemainingMs() {
        if (running) return endsAt - Date.now()
        if (started) return pausedMs
        return durationMinutes * 60 * 1000
    }

    function canAdjust(delta) {
        if (idle) return Model.stepMinutes(durationMinutes, delta) !== durationMinutes
        // Reading nowMs is the binding dependency that makes the panel's +/-
        // `enabled` re-evaluate each tick; the arithmetic below deliberately
        // does not use it (see liveRemainingMs).
        var tick = nowMs
        return tick >= 0 && Model.adjustSession(sessionMinutes, liveRemainingMs(), delta) !== null
    }

    // Idle writes the armed phase's key into the snapshot, same as any other
    // pending-setting change (and appliedSettings above keeps a sibling
    // monitor from stomping it), and schedules the commit that makes it the
    // persisted default -- durationMinutes follows, because it reads that key.
    // Started writes sessionMinutes instead -- the comment on that property
    // above says a mid-session *config* edit can't relabel history; this is
    // the deliberate exception, an explicit user nudge, applied live to the
    // running deadline (endsAt) or banked remainder (pausedMs) so the
    // countdown reflects it immediately.
    function adjustMinutes(delta) {
        if (idle) {
            var next = Model.stepMinutes(durationMinutes, delta)
            // Clamped to the same value (the wheel can reach a bound the
            // panel's `enabled` binding would have blocked): nothing changed,
            // so nothing to commit.
            if (next === durationMinutes) return
            // Idle means the user is setting the *default* for the phase they
            // are looking at, so it goes to that phase's key and gets
            // persisted. Only this branch: the started-session branch below
            // is scoped to the session in progress and must never reach
            // shell.json.
            var patch = ({})
            patch[settingsKeyFor(phase)] = next
            commitSettings(patch)
            return
        }
        var step = Model.adjustSession(sessionMinutes, liveRemainingMs(), delta)
        if (!step) return
        sessionMinutes = step.minutes
        if (running) endsAt += step.appliedMs
        else pausedMs += step.appliedMs
        persistSession()
    }

    // --- persisting a settings change ---------------------------------
    // An idle nudge changes a phase's default duration, and the panel's
    // settings screen changes whatever it was pointed at; both belong in
    // shell.json rather than only in memory. The write is deliberately not
    // ours: the shell injects `shell` into a service but never `settings`,
    // and the values live on the bar *entry*, which only BarWidget.qml can
    // see. This side decides *when* a change has settled and *who* writes it.
    //
    // The payload is a `{key: value}` patch rather than a bare number,
    // because there are now eight keys and a nudge writes whichever one the
    // armed phase uses.
    signal settingsCommitted(var patch)

    // Which key an idle nudge is editing. The armed phase decides it, which
    // is the same thing the countdown above the +/- is showing.
    function settingsKeyFor(p) {
        if (p === Model.PHASE_SHORT) return "breakMinutes"
        if (p === Model.PHASE_LONG) return "longBreakMinutes"
        return "minutes"
    }

    // The keys awaiting a write, as a set -- values are not banked here, only
    // the fact that the key is dirty, so the timer can read each one where it
    // finally landed. Cleared when it fires.
    property var pendingCommit: ({})

    // Set settings from the UI: applied now, persisted once the burst
    // settles. The panel's settings screen calls this with whatever field it
    // changed, and the idle nudge above calls it with one duration key -- so
    // both take the same route to disk and neither writes shell.json itself.
    //
    // Deliberately does not touch appliedSettings: that map records what
    // *shell.json* last said, and moving it here would make a sibling
    // monitor's re-push of the old config look like a genuine change and
    // stomp what the user just set. It moves on the round-trip instead.
    function commitSettings(patch) {
        if (!patch || typeof patch !== "object") return
        var next = ({})
        var pending = ({})
        for (var k in pendingCommit) pending[k] = pendingCommit[k]
        var any = false
        for (var key in patch) {
            var value = normalizeSetting(key, patch[key])
            // Already what we hold. Nothing to apply, and nothing to write.
            if (settingsSnapshot[key] === value) continue
            next[key] = value
            pending[key] = true
            any = true
        }
        if (!any) return
        installSettings(next)
        pendingCommit = pending
        commitDebounce.restart()
    }

    // Debounce. One wheel flick is several adjustMinutes() calls tens of
    // milliseconds apart, and every write re-enters synchronously as
    // shellConfig -> barConfig -> settings -> applySettings; committing per
    // notch would rewrite shell.json a dozen times for one gesture. The
    // interval only has to outlast the gaps *within* an input burst -- not
    // the round-trip, which settles on its own -- while staying short enough
    // that the value is on disk before the hand leaves the wheel. 400ms sits
    // between the two: an order of magnitude above wheel-notch spacing, well
    // under the ~1s at which a save stops feeling immediate. restart(), not
    // start(), so a burst commits once, at its final value.
    Timer {
        id: commitDebounce
        interval: 400
        repeat: false
        // The snapshot is read at fire time, not captured at change time, so
        // a burst commits where it landed -- and one patch carries every key
        // the burst touched, so a settings screen edited in a hurry is still
        // one write. Starting a session inside the window does not cancel it:
        // the nudge was still a change to the default, and start() leaves the
        // snapshot alone.
        onTriggered: {
            var patch = ({})
            var any = false
            for (var key in root.pendingCommit) {
                patch[key] = root.settingsSnapshot[key]
                any = true
            }
            root.pendingCommit = ({})
            if (any) root.settingsCommitted(patch)
        }
    }

    // The elected writer. Every monitor's bar widget hears the signal above
    // and is equally able to write, so on an N-head setup N of them would
    // call updateEntryInline with the same entry. That is not corrupting --
    // the host dirty-checks, so writes 2..N compare equal to the shellConfig
    // write 1 just installed and return false -- but each still deep-clones
    // the whole config to find that out, and leaning on the host's dirty
    // check makes single-writing a property of omarchy-shell rather than of
    // this plugin. Electing here keeps it ours and costs one comparison.
    //
    // Typed `Item`, not `var`, deliberately: QML clears an object-typed
    // property when its object is destroyed, so unplugging the elected
    // monitor re-opens the election on the next commit instead of stranding
    // it on a dead widget.
    property Item settingsWriter: null

    // Claimed by the first view that asks -- which, because the widget checks
    // its own preconditions (settings received, host API present) before
    // calling, is the first view actually able to write.
    function claimSettingsWriter(view) {
        if (!settingsWriter) settingsWriter = view
        return settingsWriter === view
    }

    // Latch for the things the writer can discover but must not repeat: a
    // shell.json whose entry for this widget cannot be safely written, for
    // any of the reasons BarWidget's settings write enumerates. Warning from
    // there directly would fire on every wheel notch; latching per view would
    // fire once per monitor. This object is the one thing all the views
    // already share, so the latch belongs here.
    //
    // Keyed by reason rather than a bare flag: the reasons are distinct
    // config faults, and fixing one can expose the next -- a single boolean
    // would swallow the second diagnosis and leave the user staring at a
    // nudge that still refuses to stick. Never reset within a reason -- but
    // the guarantee is once per *service instance*, not once per shell
    // session: a plugin reload destroys and recreates this object, and the
    // latch goes with it.
    property var entryWarnings: ({})

    function claimEntryWarning(reason) {
        var key = String(reason)
        if (entryWarnings[key]) return false
        // A `var` object needs whole reassignment for QML to notice; nothing
        // binds to this, but keeping the idiom honest costs one line.
        var next = ({})
        for (var k in entryWarnings) next[k] = entryWarnings[k]
        next[key] = true
        entryWarnings = next
        return true
    }

    Timer {
        id: initialSessionSave
        interval: 500
        repeat: false
        onTriggered: root.persistSession()
    }

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            root.nowMs = Date.now()
            if (root.remainingSeconds <= 0) root.complete()
        }
    }

    // --- notification -------------------------------------------------
    // Fires once per completed session, not once per monitor -- the point of
    // this file. argv, not a shell string: execDetached takes the arguments
    // directly, so nothing here is parsed by a shell and no argument needs
    // quoting. Also drops the dependency on bar.run being present, which a
    // service has no access to anyway.
    // Takes the copy the completion decision returned rather than composing
    // its own: what just ended is the decision's to know (a break announces
    // itself differently, and only it knows the phase the session actually
    // ran under).
    function sendCompletionNotification(notify, offersContinue) {
        // Clicking the toast routes through the shell's bar-widget summon
        // path, which opens the existing panel on the focused monitor.
        var body = notify.body
        if (offersContinue) body += " - Click Start to move on"
        Quickshell.execDetached(["omarchy", "notification", "send",
                                 "--app-name", "Pomodoro", "-u", "critical",
                                 notify.title, body,
                                 "--exec", "omarchy-shell", "shell", "summon",
                                 "fgrehm.pomodoro", "{}"])
    }

    // --- persistence ---------------------------------------------------
    // Single writer now: every view resolves the one service the host has
    // recorded for this plugin id, so the whole-file rewrite below has no
    // peer to clobber -- subject to the same mount caveat as the header.
    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy"
    readonly property string historyPath: stateDir + "/pomodoro.json"
    readonly property string sessionPath: stateDir + "/pomodoro-session.json"

    function persistSession() {
        sessionFile.setText(JSON.stringify({
            running: root.running,
            started: root.started,
            phase: root.phase,
            sessionStartedAt: root.sessionStartedAt,
            sessionMinutes: root.sessionMinutes,
            endsAt: root.endsAt,
            pausedMs: root.pausedMs,
            tasks: root.tasks,
            activeTaskId: root.activeTaskId
        }, null, 2) + "\n")
    }

    function restoreSession(raw) {
        if (!raw || !raw.trim()) return
        try {
            var saved = JSON.parse(raw)
            if (saved.started !== true) return
            phase = saved.phase === Model.PHASE_SHORT || saved.phase === Model.PHASE_LONG
                ? saved.phase : Model.PHASE_WORK
            sessionStartedAt = Number(saved.sessionStartedAt) || 0
            sessionMinutes = Number(saved.sessionMinutes) || durationMinutes
            endsAt = Number(saved.endsAt) || 0
            pausedMs = Number(saved.pausedMs) || 0
            tasks = Array.isArray(saved.tasks) ? saved.tasks : []
            activeTaskId = typeof saved.activeTaskId === "string" ? saved.activeTaskId : ""
            started = true
            running = saved.running === true
            nowMs = Date.now()
            if (running && endsAt <= nowMs) {
                running = false
                complete(false)
            }
        } catch (error) {
            console.warn("pomodoro: ignoring invalid session state", root.sessionPath)
        }
    }

    FileView {
        id: sessionFile
        path: root.sessionPath
        watchChanges: false
        atomicWrites: true
        printErrors: false
        onLoaded: root.restoreSession(text())
        onLoadFailed: root.restoreSession("")
    }

    // Ensures the state directory exists before any write. Read-on-load
    // tolerates a missing file/dir fine (FileView + Model.parseHistory both
    // degrade to []); this only matters for the first write.
    Process {
        id: ensureStateDirProc
        command: ["mkdir", "-p", root.stateDir]
        running: false
    }

    // True once we know what is on disk -- either it loaded, or it definitively
    // wasn't there. Until then `history` is an empty placeholder that merely
    // looks like an empty log, and writing it would publish that guess over
    // real data.
    property bool historyLoaded: false

    // The file exists and holds something, but parseHistory rejected all of
    // it. That is not an empty log; it is a log we failed to read (truncated
    // write, hand-edit typo, older format). Overwriting it would destroy the
    // only copy, so persistence stops until a human resolves it.
    property bool historyUnreadable: false

    // atomicWrites so a shell crash mid-write leaves the previous file
    // intact rather than a truncated one. printErrors stays off because the
    // history file is legitimately absent on first run (same setting as
    // Clipboard.qml's identically-shaped FileView); onSaveFailed covers the
    // write side that suppression would otherwise hide.
    FileView {
        id: historyFile
        path: root.historyPath
        watchChanges: false
        atomicWrites: true
        printErrors: false
        onLoaded: {
            var raw = text()
            var parsed = Model.parseHistory(raw, Model.HISTORY_CAP)
            root.history = parsed
            // Distinguishing the two ways of arriving at [] is the whole point:
            // an absent or genuinely empty file is safe to overwrite, a file
            // with bytes we couldn't parse is not.
            root.historyUnreadable = parsed.length === 0 && raw.trim().length > 0
            if (root.historyUnreadable)
                console.warn("pomodoro: could not parse", root.historyPath,
                             "- leaving it untouched; sessions will not be saved until it is fixed or removed")
            root.historyLoaded = true
        }
        onLoadFailed: {
            // Absent file on first run is the normal path, not an error.
            root.history = []
            root.historyUnreadable = false
            root.historyLoaded = true
        }
        onSaveFailed: function (error) { console.warn("pomodoro: history save failed", error) }
    }

    function persistHistory() {
        // Never write ahead of the load. complete() can only fire a full
        // session after startup, so the race is not reachable through the UI
        // today -- but the guard costs nothing and the failure it prevents
        // (publishing a placeholder [] over a real log) is unrecoverable.
        if (!historyLoaded) return
        if (historyUnreadable) {
            console.warn("pomodoro: refusing to overwrite unparseable", root.historyPath)
            return
        }
        historyFile.setText(Model.serializeHistory(root.history))
    }

    NextPhaseCard {
        timer: root
        visibleCard: root.nextPhasePending
        phaseLabel: Model.phaseLabel(root.phase)
        onStartRequested: root.startPendingPhase()
        onDismissRequested: root.dismissPendingPhase()
    }

    Component.onCompleted: {
        ensureStateDirProc.running = true
        initialSessionSave.start()
    }
}
