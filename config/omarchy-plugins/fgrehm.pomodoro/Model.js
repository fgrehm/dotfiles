// Pure logic for the pomodoro plugin. No QML types, no imports, no side effects.
// Loadable as a QML JS library (.import) and as a CommonJS module (node/test).

function mmss(seconds) {
    var s = Math.floor(seconds);
    if (!isFinite(s) || s < 0) s = 0;
    var m = Math.floor(s / 60);
    var r = s % 60;
    var pad = function (n) { return n < 10 ? "0" + n : "" + n; };
    return pad(m) + ":" + pad(r);
}

// Session rows kept on disk and in memory. Single source for both the write
// path (pushSession) and the read path (parseHistory) so they can't diverge.
// Sized so a day's pomodoros can never fill it, because countToday() is what
// drives the cycle and a saturated count freezes the long break (see the
// comment there).
//
// Worst case is back-to-back work at MIN_MINUTES with no break between them:
//   n*MIN <= dayMinutes  ->  n <= dayMinutes / MIN
// Nothing forces a break in between. Breaks are skippable (skip()), timer
// mode has none at all, and autoStartBreaks can be off with the user simply
// starting the next work interval -- so a derivation that budgets a mandatory
// break per pomodoro understates this by half.
//
// `dayMinutes` is deliberately generous: 48 hours, not the 1440 of an ordinary
// day or the 1500 of a DST fall-back. That is a safety margin, not a claim
// about real days -- countToday() groups by *local* day, and a local day
// stretches whenever a zone shifts its offset westward. Antarctica/Casey ran
// 27 hours in 2023, and a system timezone change can do worse. Rather than
// track how long a local day can get, budget an absurd one:
//   2880 / 1 -> 2880 pomodoros. One more than that and the count can always
// be trusted.
var HISTORY_CAP = 2881;

var MIN_MINUTES = 1;
var MAX_MINUTES = 180;
var DEFAULT_MINUTES = 25;

// Returns a valid whole-minute duration, or `fallback` when the input is out
// of the MIN_MINUTES..MAX_MINUTES contract. Deliberately falls back rather
// than clamping: a hand-typed 2500 in shell.json is a typo, and the default
// is a better guess than 180.
function validMinutesOr(value, fallback) {
    if (typeof value !== "number" || !isFinite(value) || value < MIN_MINUTES || value > MAX_MINUTES) return fallback;
    return Math.round(value);
}

// The two things this plugin can be. "timer" is a bare countdown -- no
// breaks, no cycle -- and is the fallback, so an install with no `mode` key
// behaves exactly as it did before the cycle existed.
var MODE_TIMER = "timer";
var MODE_POMODORO = "pomodoro";

// Returns a known mode, or `fallback` for anything else. Same
// fall-back-don't-guess contract as validMinutesOr.
function validModeOr(value, fallback) {
    if (value !== MODE_TIMER && value !== MODE_POMODORO) return fallback;
    return value;
}

// The interval currently running. Timer mode never leaves PHASE_WORK.
var PHASE_WORK = "work";
var PHASE_SHORT = "short";
var PHASE_LONG = "long";

var DEFAULT_BREAK_MINUTES = 5;
var DEFAULT_LONG_BREAK_MINUTES = 15;

// How many pomodoros run before the long break.
var MIN_CYCLES = 1;
var MAX_CYCLES = 12;
var DEFAULT_CYCLES = 4;

// Returns a valid whole cycle count, or `fallback` when out of the
// MIN_CYCLES..MAX_CYCLES contract. Falls back rather than clamping, for the
// same reason validMinutesOr does.
function validCyclesOr(value, fallback) {
    if (typeof value !== "number" || !isFinite(value) || value < MIN_CYCLES || value > MAX_CYCLES) return fallback;
    return Math.round(value);
}

// The duration a phase counts down, from a settings snapshot. Every value
// goes through validMinutesOr, so a garbage key falls back to that phase's
// default rather than to another phase's number.
function phaseMinutes(phase, settings) {
    var s = (settings && typeof settings === "object") ? settings : {};
    if (phase === PHASE_SHORT) return validMinutesOr(s.breakMinutes, DEFAULT_BREAK_MINUTES);
    if (phase === PHASE_LONG) return validMinutesOr(s.longBreakMinutes, DEFAULT_LONG_BREAK_MINUTES);
    return validMinutesOr(s.minutes, DEFAULT_MINUTES);
}

// Today's completed pomodoros as a whole non-negative count. Garbage from a
// hand-edited pomodoro.json means "no pomodoros yet", not a broken cycle.
function validCount(value) {
    if (typeof value !== "number" || !isFinite(value) || value < 0) return 0;
    return Math.floor(value);
}

// The phase that follows the one that just ended. Any break is followed by
// work; work is followed by the long break every `cyclesBeforeLong`th
// pomodoro, else the short one.
//
// `pomodorosToday` counts the pomodoro that just finished, so the modulo is
// taken on the new total: with the default 4, pomodoros 1..3 earn a short
// break and the 4th the long one. A zero count means no work interval was
// logged, so there is nothing for a long break to reward yet.
function nextPhase(phase, pomodorosToday, cyclesBeforeLong) {
    if (phase === PHASE_SHORT || phase === PHASE_LONG) return PHASE_WORK;
    var count = validCount(pomodorosToday);
    var cycles = validCyclesOr(cyclesBeforeLong, DEFAULT_CYCLES);
    if (count > 0 && count % cycles === 0) return PHASE_LONG;
    return PHASE_SHORT;
}

function phaseLabel(phase) {
    if (phase === PHASE_SHORT) return "Short break";
    if (phase === PHASE_LONG) return "Long break";
    return "Focus";
}

// Where the *next* pomodoro sits in the cycle, 1..cyclesBeforeLong, for the
// panel's dots. Wraps straight back to 1 after a long break, so the dots read
// as the cycle about to be worked rather than the one just finished.
function cyclePosition(pomodorosToday, cyclesBeforeLong) {
    var cycles = validCyclesOr(cyclesBeforeLong, DEFAULT_CYCLES);
    return (validCount(pomodorosToday) % cycles) + 1;
}

// Auto-advance, defaulted the way the decisions table has them: breaks roll
// on by themselves, work waits for a press. Written as !== false / === true so
// a missing key lands on the default rather than on `undefined`, the same
// shape Service.qml already uses for `notify`.
function autoStartFor(phase, settings) {
    var s = (settings && typeof settings === "object") ? settings : {};
    if (phase === PHASE_SHORT || phase === PHASE_LONG) return s.autoStartBreaks !== false;
    return s.autoStartWork === true;
}

// The armed-next payload every decision below returns, so the duration is
// resolved in exactly one place.
function arm(phase, settings) {
    return { phase: phase, minutes: phaseMinutes(phase, settings) };
}

// Starts an idle or paused session. The caller supplies the clock instant in
// `state.nowMs`; this only returns the state to apply. A running session, an
// invalid clock, or an invalid paused remainder is a no-op.
function start(state) {
    var st = (state && typeof state === "object") ? state : {};
    if (st.running === true || typeof st.nowMs !== "number" || !isFinite(st.nowMs))
        return { changed: false };

    var resumed = st.started === true;
    var minutes = validMinutesOr(st.durationMinutes, DEFAULT_MINUTES);
    var ms = resumed ? st.pausedMs : minutes * 60 * 1000;
    if (typeof ms !== "number" || !isFinite(ms) || ms < 0) return { changed: false };
    if (resumed && (typeof st.sessionStartedAt !== "number" || !isFinite(st.sessionStartedAt) ||
                    typeof st.sessionMinutes !== "number" || !isFinite(st.sessionMinutes)))
        return { changed: false };

    var endsAt = st.nowMs + ms;
    if (!isFinite(endsAt)) return { changed: false };
    return {
        changed: true,
        running: true,
        started: true,
        sessionStartedAt: resumed ? st.sessionStartedAt : st.nowMs,
        sessionMinutes: resumed ? st.sessionMinutes : minutes,
        nowMs: st.nowMs,
        endsAt: endsAt
    };
}

// Pauses a running session, or reports that its deadline has already passed.
// The latter is a decision for Service.qml to hand to complete(false), not a
// completion side effect. `state.nowMs` is the instant being applied.
// The caller supplies the instant; a stale `state.nowMs` banks the wrong
// remainder.
// The deadline can already have passed: remainingSeconds reaches 0 the
// moment Date.now() > endsAt, but complete() only runs on the next
// tick, and ticks land late. Pausing inside that gap used to bank a
// zero remainder and stop the ticker, stranding the widget on a dimmed
// 00:00 forever -- no notification, no history row, and a reset from
// there would discard a session that had in fact finished. Finish it
// instead; a session past its deadline is complete, not pausable.
// Pause still returns stopped when completion would normally
// auto-start the next phase.
function pause(state) {
    var st = (state && typeof state === "object") ? state : {};
    if (st.running !== true || typeof st.nowMs !== "number" || !isFinite(st.nowMs) ||
        typeof st.endsAt !== "number" || !isFinite(st.endsAt))
        return { changed: false };

    var remainingMs = st.endsAt - st.nowMs;
    if (!isFinite(remainingMs)) return { changed: false };
    if (remainingMs <= 0) return { changed: true, complete: true, nowMs: st.nowMs };
    return { changed: true, complete: false, nowMs: st.nowMs, pausedMs: remainingMs, running: false };
}

// Abandons a started session and re-arms work. History and cycle position are
// outside this decision, so reset never writes or advances them.
// Back to work whatever was abandoned: reset is the user saying "not
// this", and leaving them armed on the break they just rejected is a
// worse answer than the phase every cycle begins from. No history row. Never
// auto-starts.
function reset(state) {
    var st = (state && typeof state === "object") ? state : {};
    if (st.started !== true) return { changed: false };
    return { changed: true, running: false, started: false, phase: PHASE_WORK };
}

// What a finished session should cause. Pure: the caller pushes the log row,
// fires the notification and installs `next` -- this only decides.
//
// `state` is {phase, sessionStartedAt, sessionMinutes, pomodorosToday}, where
// `pomodorosToday` is the count *before* this session is logged (the caller
// reads it from history, which it has not written yet). The work branch adds
// the pomodoro it is logging, because nextPhase counts the one just finished.
//
// Timer mode is a branch, not a second machine: it logs and notifies exactly
// as this plugin always has, and always re-arms work without starting it. An
// install with no `mode` key therefore cannot reach a break.
function completion(state, settings) {
    var st = (state && typeof state === "object") ? state : {};
    var cfg = (settings && typeof settings === "object") ? settings : {};
    var mode = validModeOr(cfg.mode, MODE_POMODORO);

    // What ran is decided by the session's own phase, never by what `mode`
    // reads at this instant. The two disagree in a reachable case: with
    // autoStartBreaks off, a finished work interval leaves the timer idle but
    // *armed* on a break, and armed is neither running nor paused -- so the
    // panel's mode switch is live and the user can flip to Timer right then.
    // Gating on the current mode would log that 5-minute break as a pomodoro
    // and announce it as work, which is precisely the invariant breaks exist
    // to keep. Timer mode's guarantee is that it never *advances into* a
    // break, not that it reinterprets one it is handed.
    if (st.phase === PHASE_SHORT || st.phase === PHASE_LONG) {
        // Breaks are not logged and do not move the cycle: a pomodoro is a
        // completed *work* interval, and that is the only thing counted.
        return {
            log: null,
            notify: notifyOr(cfg, "Break over", "Time to focus"),
            next: arm(PHASE_WORK, cfg),
            // Timer mode still never auto-starts, even settling a stray break.
            autoStart: mode === MODE_POMODORO && autoStartFor(PHASE_WORK, cfg)
        };
    }

    var row = logRow(st);
    var next = PHASE_WORK;
    if (mode === MODE_POMODORO) next = nextPhase(PHASE_WORK, projectedCount(st, row), cfg.cyclesBeforeLongBreak);
    return {
        log: row,
        notify: notifyOr(cfg, "Pomodoro complete", st.sessionMinutes + " minute session done"),
        next: arm(next, cfg),
        // Timer mode has nothing to advance into, so it never auto-starts --
        // pressing start is how today's plugin begins a session and stays so.
        autoStart: mode === MODE_POMODORO && autoStartFor(next, cfg)
    };
}

// The pomodoro count this completion should decide against: `pomodorosToday`
// as the caller measured it, plus the row about to be pushed -- but only when
// that row will actually land on the day the count is scoped to.
//
// The two can disagree across midnight. History rows are dated by startedAt,
// so a session begun 23:58 and finished 00:03 belongs to *yesterday* and
// countToday() will not see it. Adding 1 anyway would decide this transition
// against a count nobody can reproduce: the dots and the next completion both
// read countToday() and would get one less. Same local-day rule as the row
// itself, so the number used here is exactly what countToday() reports the
// instant after the push.
//
// `nowMs` is the completion instant, the same clock the caller scoped
// `pomodorosToday` to. Absent, the session is assumed to have finished on the
// day it started -- overwhelmingly the common case, and what this did before
// the field existed.
function projectedCount(st, row) {
    var base = validCount(st.pomodorosToday);
    if (row === null) return base;
    if (typeof st.nowMs !== "number" || !isFinite(st.nowMs)) return base + 1;
    return sameLocalDay(row.startedAt, st.nowMs) ? base + 1 : base;
}

// The history row for a finished work session, or null when the caller handed
// over a session that never really ran. The values pass through unchanged --
// sessionMinutes is the snapshot the session actually counted down, and
// re-validating it here would relabel a row against what the user watched.
function logRow(st) {
    if (typeof st.sessionStartedAt !== "number" || !isFinite(st.sessionStartedAt)) return null;
    if (typeof st.sessionMinutes !== "number" || !isFinite(st.sessionMinutes)) return null;
    return { startedAt: st.sessionStartedAt, minutes: st.sessionMinutes };
}

// Honours the existing `notify` setting: absent means on, only an explicit
// false turns it off (Service.qml applySettings, `src.notify !== false`).
function notifyOr(settings, title, body) {
    if (settings.notify === false) return null;
    return { title: title, body: body };
}

// A break ended early by the user. Same shape as completion, minus everything
// that records the session: a skipped break was never worked, so there is no
// row and nothing to announce. Total off-break too -- the caller guards it,
// but a stray call must not invent a log row.
//
// autoStart is false unconditionally, ignoring autoStartWork. Skipping is an
// explicit "I am done resting", not a request to be thrown into a countdown:
// the button is one press, and auto-starting work would leave a user who
// mis-clicked already burning a pomodoro. Auto-advance exists to carry you
// across a transition you were waiting through, which is exactly what a skip
// says you were not doing.
function skip(state, settings) {
    var cfg = (settings && typeof settings === "object") ? settings : {};
    return {
        log: null,
        notify: null,
        next: arm(PHASE_WORK, cfg),
        autoStart: false
    };
}

// Steps `value` (falling back to DEFAULT_MINUTES like validMinutesOr) by `delta` minutes,
// clamped to MIN_MINUTES..MAX_MINUTES. Non-numeric/non-finite delta is a no-op.
function stepMinutes(value, delta) {
    var base = validMinutesOr(value, DEFAULT_MINUTES);
    if (typeof delta !== "number" || !isFinite(delta)) return base;
    var next = Math.round(base + delta);
    if (next < MIN_MINUTES) next = MIN_MINUTES;
    if (next > MAX_MINUTES) next = MAX_MINUTES;
    return next;
}

// An in-progress session nudged by `delta` minutes. Returns
// {minutes, appliedMs} -- the new snapshot and the exact shift to apply to
// the deadline or the banked remainder -- or null when the nudge is refused.
//
// `remainingMs` is the *live* remainder in milliseconds, never the ceil'd
// display seconds: ceil rounds 300.001s up to 301, so a -5 measured against
// it can leave the deadline in the past, completing the session on the next
// tick instead of being blocked here.
//
// Refused when: the step clamps to a no-op, the deadline has already passed
// (that session is complete, not adjustable -- same rule pause() applies), or
// the shortening would consume everything that is left.
function adjustSession(sessionMinutes, remainingMs, delta) {
    if (typeof remainingMs !== "number" || !isFinite(remainingMs) || remainingMs <= 0) return null;
    var next = stepMinutes(sessionMinutes, delta);
    if (next === sessionMinutes) return null;
    // From the clamped result, not `delta`: sessionMinutes must track exactly
    // what the deadline gets shifted by, or the history row stops matching
    // the minutes actually counted down.
    var appliedMs = (next - sessionMinutes) * 60 * 1000;
    if (remainingMs + appliedMs <= 0) return null;
    return { minutes: next, appliedMs: appliedMs };
}

// One wheel notch is 120 angle units (Qt convention). Banks the sub-notch
// remainder so a touchpad's fine-grained flick can't dump a whole session's
// worth of minutes at once, and so slow scrolling still adds up to a step.
var WHEEL_NOTCH = 120;

function wheelSteps(accumulator, angleDelta) {
    var acc = (typeof accumulator === "number" && isFinite(accumulator)) ? accumulator : 0;
    if (typeof angleDelta !== "number" || !isFinite(angleDelta)) return { steps: 0, remainder: acc };
    acc += angleDelta;
    // Truncate toward zero: a banked remainder always keeps the sign of the
    // scroll it came from, so reversing direction can't fire a step early.
    var steps = acc > 0 ? Math.floor(acc / WHEEL_NOTCH) : Math.ceil(acc / WHEEL_NOTCH);
    return { steps: steps, remainder: acc - steps * WHEEL_NOTCH };
}

function pushSession(history, entry, cap) {
    if (typeof cap !== "number" || !isFinite(cap) || cap < 0) cap = HISTORY_CAP;
    var base = Array.isArray(history) ? history : [];
    var out = [entry].concat(base);
    if (out.length > cap) out = out.slice(0, cap);
    return out;
}

function sameLocalDay(aMs, bMs) {
    var a = new Date(aMs);
    var b = new Date(bMs);
    return a.getFullYear() === b.getFullYear() &&
        a.getMonth() === b.getMonth() &&
        a.getDate() === b.getDate();
}

// Counts today's rows in `history`, which is capped at HISTORY_CAP -- so this
// would saturate, and a saturated count is not merely imprecise: nextPhase()
// takes this number, so a frozen count recomputes the same cycle position
// forever and the long break silently stops arriving.
//
// HISTORY_CAP is sized above the most pomodoros a local day can physically
// hold precisely so that cannot happen (see its derivation). Lowering the cap
// under that bound reintroduces the freeze; the test section pinning it says
// so, and will fail.
function countToday(history, nowMs) {
    if (!Array.isArray(history)) return 0;
    var count = 0;
    for (var i = 0; i < history.length; i++) {
        var e = history[i];
        if (e && typeof e.startedAt === "number" && isFinite(e.startedAt) && sameLocalDay(e.startedAt, nowMs)) {
            count++;
        }
    }
    return count;
}

// History is practically newest-first, so group consecutive local-day runs
// without sorting; that ordering is the contract for this view.
function groupByDay(history, nowMs) {
    if (!Array.isArray(history)) return [];
    var now = new Date(nowMs);
    var todayMidnight = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    var yesterday = new Date(todayMidnight.getTime());
    yesterday.setDate(yesterday.getDate() - 1);
    var monthLabels = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    var groups = [];

    for (var i = 0; i < history.length; i++) {
        var e = history[i];
        if (!e || typeof e.startedAt !== "number" || !isFinite(e.startedAt)) continue;

        var group = groups[groups.length - 1];
        if (group && sameLocalDay(e.startedAt, group.sessions[0].startedAt)) {
            group.sessions.push(e);
            group.count++;
            continue;
        }

        var date = new Date(e.startedAt);
        var label = sameLocalDay(e.startedAt, nowMs) ? "TODAY" :
            sameLocalDay(e.startedAt, yesterday.getTime()) ? "YESTERDAY" :
            date.getDate() + ". " + monthLabels[date.getMonth()];
        groups.push({ label: label, count: 1, sessions: [e] });
    }
    return groups;
}

function parseHistory(text, cap) {
    if (typeof cap !== "number" || !isFinite(cap) || cap < 0) cap = HISTORY_CAP;
    if (typeof text !== "string" || text.length === 0) return [];
    var data;
    try {
        data = JSON.parse(text);
    } catch (e) {
        return [];
    }
    if (!data || typeof data !== "object" || !Array.isArray(data.sessions)) return [];

    var out = [];
    for (var i = 0; i < data.sessions.length && out.length < cap; i++) {
        var e = data.sessions[i];
        if (!e || typeof e !== "object") continue;
        if (typeof e.startedAt !== "number" || !isFinite(e.startedAt)) continue;
        if (typeof e.minutes !== "number" || !isFinite(e.minutes)) continue;
        if (Math.floor(e.minutes) !== e.minutes || e.minutes < 1) continue;
        out.push({ startedAt: e.startedAt, minutes: e.minutes });
    }
    return out;
}

// Where this widget's id appears in the bar layout, and how much of that the
// host's inline-settings write can actually reach. `{ total, writable }`.
//
// Two questions, one walk, because they disagree and the disagreement is
// exactly what bites:
//   - `total` counts every entry a *reader* would say claims this id,
//     including the bare-string form (`"omarchy.clock"` instead of
//     `{ "id": "omarchy.clock" }`) that the host's own BarModel.entryId
//     accepts and renders a real widget from. More than one makes "the entry"
//     ambiguous.
//   - `writable` counts only the object form, because shell.qml's
//     updateEntryInline matches on `arr[i].id` (376-389). A bare string is
//     invisible to it: the write finds nothing and changes no file.
// A caller that asked only the first question would let a bare-string entry
// through and lose the user's change at restart; one that asked only the
// second would miss duplicates. Both, or neither.
//
// Sections are the three the bar renders; anything else in the layout object
// is not a place an entry can live.
function surveyBarEntries(layout, id) {
    var key = String(id || "");
    var out = { total: 0, writable: 0 };
    if (key === "" || !layout || typeof layout !== "object") return out;
    var sections = ["left", "center", "right"];
    for (var s = 0; s < sections.length; s++) {
        var entries = layout[sections[s]];
        if (!Array.isArray(entries)) continue;
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (typeof entry === "string") {
                if (entry === key) out.total++;
                continue;
            }
            if (!entry || typeof entry !== "object") continue;
            if (String(entry.id || "") !== key) continue;
            out.total++;
            out.writable++;
        }
    }
    return out;
}

function serializeHistory(history) {
    var sessions = Array.isArray(history) ? history : [];
    return JSON.stringify({ version: 1, sessions: sessions });
}

if (typeof module !== "undefined") {
    module.exports = { HISTORY_CAP: HISTORY_CAP, MIN_MINUTES: MIN_MINUTES, MAX_MINUTES: MAX_MINUTES, DEFAULT_MINUTES: DEFAULT_MINUTES, MODE_TIMER: MODE_TIMER, MODE_POMODORO: MODE_POMODORO, PHASE_WORK: PHASE_WORK, PHASE_SHORT: PHASE_SHORT, PHASE_LONG: PHASE_LONG, DEFAULT_BREAK_MINUTES: DEFAULT_BREAK_MINUTES, DEFAULT_LONG_BREAK_MINUTES: DEFAULT_LONG_BREAK_MINUTES, MIN_CYCLES: MIN_CYCLES, MAX_CYCLES: MAX_CYCLES, DEFAULT_CYCLES: DEFAULT_CYCLES, mmss: mmss, validMinutesOr: validMinutesOr, validModeOr: validModeOr, validCyclesOr: validCyclesOr, phaseMinutes: phaseMinutes, nextPhase: nextPhase, phaseLabel: phaseLabel, cyclePosition: cyclePosition, start: start, pause: pause, reset: reset, completion: completion, skip: skip, stepMinutes: stepMinutes, adjustSession: adjustSession, wheelSteps: wheelSteps, pushSession: pushSession, countToday: countToday, groupByDay: groupByDay, parseHistory: parseHistory, serializeHistory: serializeHistory, surveyBarEntries: surveyBarEntries };
}
