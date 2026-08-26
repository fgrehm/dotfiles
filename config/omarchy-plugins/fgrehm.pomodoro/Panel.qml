// The history Repeater's delegate reads ids from this file's outer scope
// (root, historyRows). Under the default Unbound behavior that access is
// unqualified -- it happens to resolve, but qmllint flags it and the lookup
// isn't guaranteed. Bound captures the enclosing scope properly; it also
// requires delegate model properties to be declared `required`, which the
// delegate below already does.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC
import Quickshell
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Pomodoro control panel: countdown + play/pause/reset + session history.
// Service.qml owns all timer state and the session-history file (the one
// other write, saving an idle duration nudge back to the widget's shell.json
// entry, is BarWidget.qml's). This panel never copies
// that state in -- it reads live off `timer` and drives it through the
// service's own start()/pause()/reset()/toggleRunning(), because injectPanel
// re-fires only on bar/settings/timer changes, not every tick, so any local
// copy would go stale within a second.
Panel {
  id: root
  moduleName: "fgrehm.pomodoro"

  // Injected by BarWidget.qml's injectPanel().
  property var anchorItem: null

  // Two references, deliberately not one. `hostWidget` is the bar-widget root
  // that owns this panel -- an identity, one per monitor, used only for popout
  // routing and anchoring. `timer` is the single Service.qml instance shared
  // by every monitor, and is where all state and every transition lives.
  property var hostWidget: null

  // Null until the service mounts (and null again if `_syncServices` tears it
  // down), exactly like hostWidget is null before injection -- so every read
  // below stays guarded. BarWidget re-injects on change, so this never holds a
  // destroyed instance.
  property var timer: null

  // Bar.findPanelWidget / switchPanelFrom key off the bar-widget root
  // (BarWidget.qml's `root`), not this nested panel. So route switchPanel
  // through barIdentity rather than the base Panel's own switchPanel, which
  // would pass this nested panel as the owner. Same fix the clock plugin uses.
  readonly property var barIdentity: hostWidget || root

  // timer is injected in Loader.onLoaded (and again whenever the service
  // mounts), which fires after these bindings first evaluate -- hence the null
  // guard. Hoisted here so the history views below read as plain state instead
  // of each repeating the guard, and so the empty/non-empty pair below is
  // visibly one predicate and its negation.
  readonly property int historyCount: timer ? timer.history.length : 0
  readonly property int historyRenderLimit: 200
  readonly property var renderedHistory: timer ? timer.history.slice(0, historyRenderLimit) : []
    readonly property var historyGroups: root.screen === "history"
        ? Model.groupByDay(timer ? timer.history : [], clock.date.getTime())
        : []
  readonly property var renderedHistoryGroups: Model.groupByDay(renderedHistory, clock.date.getTime())
  readonly property int cycleCount: timer ? timer.settingsSnapshot.cyclesBeforeLongBreak : Model.DEFAULT_CYCLES
  readonly property int completedCycleCount: !timer ? 0
    : timer.phase === Model.PHASE_LONG ? cycleCount
    : timer.pomodorosToday % cycleCount

  property string screen: "timer"
  onScreenChanged: keyCatcher.forceActiveFocus()
  onOpenedChanged: if (opened) screen = "timer"

  // Transport controls, sized as the panel's hero affordance rather than as
  // incidental icons. The default `Style.font.icon` (= title, 14) reads as a
  // toolbar glyph next to a 24px countdown; `display` puts the two on the same
  // footing. The hit target is set explicitly instead of leaning on
  // PanelActionButton's default (`fontSize` + `spacing.sm` * 2, which leaves
  // only 4px around the glyph) -- a play/pause you press repeatedly wants
  // margin for an imprecise click. Both are tokens, so they still track the
  // theme's font and spacing scales.
  readonly property int controlGlyphSize: Style.font.display
  readonly property int controlHitSize: Style.space(44)

  // The +/- pair stays secondary to play/pause, but PanelActionButton's
  // default (14px glyph in a 22px box) reads as a right-edge row action
  // next to a 24px countdown. One step up on each scale -- still both
  // tokens, so they track the theme.
  readonly property int adjustGlyphSize: Style.font.iconLarge
  readonly property int adjustHitSize: Style.space(32)

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  // Guarded so the panel renders before the bar is injected, same pattern
  // as shell/plugins/panels/clock/Panel.qml.
  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  // ---- glyphs ------------------------------------------------------------
  // Classic Font Awesome (U+F0xx-U+F2xx), the range Nerd Fonts v3 kept
  // intact -- unlike the legacy MDI block (U+F500-U+FD46) it deleted. These
  // are fixed Font Awesome 4 codepoints, unaffected by Nerd Fonts' 5-hex MDI
  // churn. Same range as BarWidget.qml's hourglass, and as this omarchy
  // tree's own Tray.qml and SystemUpdate.qml glyphs.
  //
  // Always String.fromCharCode over a hex literal, never a source escape or
  // a pasted character: the codepoint stays unambiguous and the file stays
  // pure ASCII, so a stray Private-Use-Area byte can't land here invisibly.
  readonly property string playGlyph: String.fromCharCode(0xf04b)
  readonly property string pauseGlyph: String.fromCharCode(0xf04c)
  readonly property string resetGlyph: String.fromCharCode(0xf0e2)
  readonly property string plusGlyph: String.fromCharCode(0xf067)
  readonly property string minusGlyph: String.fromCharCode(0xf068)
  readonly property string dotGlyph: String.fromCharCode(0xb7)
  readonly property string filledDotGlyph: String.fromCharCode(0x25cf)
  readonly property string hollowDotGlyph: String.fromCharCode(0x25cb)
  readonly property string settingsGlyph: String.fromCharCode(0xf013)
  readonly property string historyGlyph: String.fromCharCode(0xf03a)
  readonly property string skipGlyph: String.fromCharCode(0xf04e)
  readonly property string backGlyph: String.fromCharCode(0xf060)

  // Wheel-step accumulator for the countdown's duration scroll.
  // Model.wheelSteps banks the sub-notch remainder so a touchpad flick can't
  // dump 20 minutes at once. Kept in Model rather than borrowed from a shell
  // singleton: it is a dozen lines of arithmetic, it is covered by
  // Model.test.js, and it cannot break when the host shell moves a helper.
  property real wheelAccumulator: 0

  // Duration scrolling is idle-only. adjustMinutes() carries its own guard,
  // but a touchpad brush is easy to trigger by accident and silently
  // reshaping a live countdown is worse than requiring a button press. The
  // accumulator clears on the transition so a remainder banked while idle
  // cannot survive a session and fire an early step afterwards.
  readonly property bool wheelAdjusts: !!timer && timer.idle
  onWheelAdjustsChanged: wheelAccumulator = 0

  // Clamped scroll of the active Flickable, in text-row steps. The keyboard
  // cursor is the only caller: the wheel reaches either Flickable on its own,
  // Up/Down/j/k cannot.
  function scrollPanelRows(rows) {
    var flick = root.screen === "history" ? panelFlick
              : root.screen === "settings" ? settingsFlick : null
    if (!flick) return
    var max = Math.max(0, flick.contentHeight - flick.height)
    flick.contentY = Math.max(0, Math.min(flick.contentY + rows * Style.space(56), max))
  }

  // Rolls the TODAY/YESTERDAY group labels over at midnight without needing
  // the panel closed and reopened -- same fix clock/Panel.qml uses for its
  // date highlight. Minutes precision is plenty; the labels only care that
  // the day changed.
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    // Under the bar icon that opened it, not centred on the screen. The panel
    // is a control surface for one widget, so it should read as belonging to
    // that widget; KeyboardPanel's default already centres the card on the
    // anchor and clamps it to the screen edge.
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(screenActions.height + Style.space(14) + (
      root.screen === "timer" ? headColumn.implicitHeight
      : root.screen === "history" ? historyScreen.implicitHeight
      : settingsScreen.implicitHeight), Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.screen === "settings" && (
        focusMinutesField.field.activeFocus
        || breakMinutesField.field.activeFocus
        || longBreakMinutesField.field.activeFocus
        || cyclesField.field.activeFocus)
      onCloseRequested: {
        if (root.screen === "timer") root.close()
        else root.screen = "timer"
      }
      onActivateRequested: {
        if (root.screen === "timer" && root.timer) root.timer.toggleRunning()
      }
      onTabRequested: function (direction) { root.switchPanel(direction) }
      onTextKey: function (text) {
        text = text.toLowerCase()
        if (text === "t") root.screen = "timer"
        else if (text === "y") root.screen = "history"
        else if (text === "s") root.screen = "settings"
      }
      // Left/Right/h/l selects Timer or Pomodoro directly; Up/Down/j/k
      // scrolls the active history/settings view by one text-row step.
      onMoveRequested: function (dx, dy) {
        if (dx !== 0) {
          if (root.screen === "timer" && root.timer && !root.timer.started)
            root.timer.commitSettings({ mode: dx < 0 ? Model.MODE_POMODORO : Model.MODE_TIMER })
          return
        }
        if (dy === 0) return
        root.scrollPanelRows(dy)
      }

      Item {
        id: screenActions
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: Math.max(leftActions.implicitHeight, rightActions.implicitHeight)
        height: Math.max(Style.space(30), implicitHeight)

        Row {
          id: leftActions
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter

          ModeTabs {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.screen === "timer"
            width: Style.space(180)
            value: root.timer ? root.timer.mode : root.setting("mode", Model.MODE_POMODORO)
            enabled: !!root.timer && !root.timer.started
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            onChanged: function (value) {
              if (root.timer) root.timer.commitSettings({ mode: value })
            }
          }

          PanelActionButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.screen !== "timer"
            iconText: root.backGlyph
            tooltipText: "Timer (T / Esc)"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            onClicked: root.screen = "timer"
          }
        }

        Row {
          id: rightActions
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.spacing.sm

          PanelActionButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: root.settingsGlyph
            tooltipText: "Settings (S)"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            bordered: root.screen === "settings"
            onClicked: root.screen = "settings"
          }

          PanelActionButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: root.historyGlyph
            tooltipText: "History (Y)"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            bordered: root.screen === "history"
            onClicked: root.screen = "history"
          }
        }
      }

      Column {
        id: headColumn
        anchors.top: screenActions.bottom
        anchors.topMargin: Style.space(14)
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(14)
        visible: root.screen === "timer"

        TextField {
          id: taskField
          width: parent.width
          placeholderText: "What are you focusing on?"
          text: root.timer && root.timer.activeTaskId
            ? ((root.timer.tasks.find(function (task) { return task.id === root.timer.activeTaskId }) || {}).title || "")
            : ""
          enabled: !!root.timer && !root.timer.started
          onEditingFinished: {
            if (!root.timer) return
            if (root.timer.activeTaskId) root.timer.renameTask(root.timer.activeTaskId, text)
            else root.timer.addTask(text)
          }
        }

        Text {
          visible: root.timer && root.timer.mode === Model.MODE_POMODORO
          width: parent.width
          text: root.timer ? Model.phaseLabel(root.timer.phase) : ""
          horizontalAlignment: Text.AlignHCenter
          color: root.contentForeground
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.body
          font.bold: true
        }

        // ---- countdown, dimmed when paused; +/- adjust the duration ----
        // Wrapped in an Item, not bare in the Column, same reason as the
        // transport row below: a Row anchored to horizontalCenter feeds back
        // into Column.implicitWidth.
        Item {
          width: parent.width
          height: countdownRow.height

          Row {
            id: countdownRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.space(18)

            // Row positions x only, so vertical anchors are free -- and
            // needed: a Row top-aligns its children, which left the buttons
            // riding high against the taller countdown Text.
            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: root.minusGlyph
              tooltipText: "5 minutes less"
              foreground: root.contentForeground
              fontSize: root.adjustGlyphSize
              size: root.adjustHitSize
              fontFamily: root.contentFontFamily
              enabled: !!root.timer && root.timer.canAdjust(-5)
              onClicked: if (root.timer) root.timer.adjustMinutes(-5)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.timer ? Model.mmss(root.timer.remainingSeconds) : "00:00"
              color: root.contentForeground
              opacity: root.timer && root.timer.paused ? 0.6 : 1.0
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.display
              font.bold: true
            }

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: root.plusGlyph
              tooltipText: "5 minutes more"
              foreground: root.contentForeground
              fontSize: root.adjustGlyphSize
              size: root.adjustHitSize
              fontFamily: root.contentFontFamily
              enabled: !!root.timer && root.timer.canAdjust(5)
              onClicked: if (root.timer) root.timer.adjustMinutes(5)
            }
          }

          // Wheel shield.
          //
          // PanelActionButton's own MouseArea (Ui/PanelActionButton.qml:81-92)
          // declares no onWheel, and a MouseArea without one still consumes
          // the wheel -- which is precisely why Ui/WidgetButton.qml:116 has
          // to forward it by hand. Those MouseAreas are descendants of this
          // wrapper, so they are hit before any handler on the wrapper
          // itself: resting the pointer on +/-, the natural place to aim
          // before nudging, killed the notch outright. It read as random
          // rather than broken, because a disabled MouseArea drops out of
          // the hit test -- at 180 the greyed-out + let the wheel through
          // while - still ate it.
          //
          // A later sibling of countdownRow is hit first, so the event lands
          // here instead, across the whole row. This Item carries no
          // MouseArea and no hover handler, so clicks, tooltips and the
          // disabled states still belong to the buttons underneath.
          Item {
            anchors.fill: parent

            WheelHandler {
              // QQuickWheelEvent.accepted defaults to TRUE, so a bare
              // `return` still swallows the event. Every path below sets
              // acceptance explicitly rather than leaning on the default.
              onWheel: function (event) {
                // Belt and braces, and kept deliberately. WheelHandler
                // filters by `orientation`, which defaults to Qt.Vertical,
                // so a pure side-scroll should never reach this function at
                // all -- but that is a default this file neither sets nor
                // controls, and the guard is two lines. Declining is the
                // honest answer to an event that is not ours; nothing behind
                // this row wants it either.
                if (event.angleDelta.y === 0) {
                  event.accepted = false
                  return
                }
                event.accepted = true

                var direction = event.angleDelta.y > 0 ? 5 : -5
                if (root.wheelAdjusts && root.timer.canAdjust(direction)) {
                  // steps === 0 means the notch banked a sub-notch
                  // remainder -- real work, and the reason one flick cannot
                  // dump twenty minutes at once.
                  var wheel = Model.wheelSteps(root.wheelAccumulator, event.angleDelta.y)
                  root.wheelAccumulator = wheel.remainder
                  if (wheel.steps !== 0) root.timer.adjustMinutes(wheel.steps * 5)
                  return
                }

                // Running, or clamped at 1/180: nothing here for the notch
                // to do, and it stops here rather than travelling on. The
                // history scrolls when the pointer is over the history, not
                // when it is over the countdown. The banked remainder goes
                // with it, or an adjustment that is no longer happening
                // would fire late.
                root.wheelAccumulator = 0
              }
            }
          }
        }

        Item {
          width: parent.width
          height: cycleDots.height
          visible: root.timer && root.timer.mode === Model.MODE_POMODORO

          Row {
            id: cycleDots
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.spacing.sm

            Repeater {
              model: root.cycleCount

              delegate: Text {
                required property int index
                text: index < root.completedCycleCount ? root.filledDotGlyph : root.hollowDotGlyph
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
              }
            }
          }
        }

        // ---- play/pause + reset ---------------------------------------
        // Wrapped in an Item, not bare in the Column: a Row anchored to
        // horizontalCenter feeds back into Column.implicitWidth. Harmless
        // here since headColumn takes its width from its anchors, but
        // the linter flags it, and clock/Panel.qml's hero row avoids it the
        // same way.
        Item {
          width: parent.width
          height: controlsRow.height

          Row {
            id: controlsRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.space(18)

            PanelActionButton {
              iconText: root.timer && root.timer.running ? root.pauseGlyph : root.playGlyph
              tooltipText: root.timer && root.timer.running ? "Pause" : "Start"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
              fontSize: root.controlGlyphSize
              size: root.controlHitSize
              onClicked: if (root.timer) root.timer.toggleRunning()
            }

            PanelActionButton {
              visible: root.timer && (root.timer.phase === Model.PHASE_SHORT
                                      || root.timer.phase === Model.PHASE_LONG)
              iconText: root.skipGlyph
              tooltipText: "Skip break"
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
              fontSize: root.controlGlyphSize
              size: root.controlHitSize
              onClicked: if (root.timer) root.timer.skipBreak()
            }

            PanelActionButton {
              iconText: root.resetGlyph
              tooltipText: "Reset"
              foreground: root.contentForeground
              hoverColor: root.bar ? root.bar.urgent : root.contentForeground
              fontFamily: root.contentFontFamily
              fontSize: root.controlGlyphSize
              size: root.controlHitSize
              enabled: !!root.timer && root.timer.started
              onClicked: if (root.timer) root.timer.reset()
            }
          }
        }
      }

      // Model.HISTORY_CAP is cycle state, not a rendering budget. Keep the
      // grouped view, but only instantiate its newest historyRenderLimit rows.
      // This must not be a Column: panelFlick fills the anchor-derived height,
      // while implicitHeight comes from its content. A positioner would derive
      // its implicit height from panelFlick.height and close the sizing loop.
      Item {
        id: historyScreen
        anchors.top: screenActions.bottom
        anchors.topMargin: Style.space(14)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: root.screen === "history"
        implicitHeight: historyColumn.implicitHeight

        Flickable {
          id: panelFlick
          width: parent.width
          height: parent.height
          contentWidth: width
          contentHeight: historyColumn.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          flickableDirection: Flickable.VerticalFlick
          interactive: contentHeight > height
          QQC.ScrollBar.vertical: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

          Column {
            id: historyColumn
            width: panelFlick.width
            spacing: Style.space(14)

            // ---- history ----------------------------------------------------

            Text {
              visible: root.historyCount === 0
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: "No sessions yet."
              color: Qt.darker(root.contentForeground, 1.4)
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
            }

            Text {
              visible: root.historyCount > root.historyRenderLimit
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: "Showing latest " + root.historyRenderLimit + " of " + root.historyCount + "."
              color: Qt.darker(root.contentForeground, 1.4)
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
            }

            // history arrives newest-first (Model.pushSession unshifts), so no
            // re-sort needed.
            Column {
              id: historyRows
              visible: root.historyCount > 0
              width: parent.width
              spacing: Style.space(12)

              Repeater {
                model: root.renderedHistoryGroups

                delegate: Column {
                  id: dayGroup
                  required property int index
                  required property var modelData
                  width: historyRows.width
                  spacing: Style.space(6)

                    PanelSectionHeader {
                        // Group bindings can refresh in either order during a Repeater rebuild.
                        text: dayGroup.modelData.label + " " + root.dotGlyph + " " + (root.historyGroups[dayGroup.index] || dayGroup.modelData).count
                    foreground: root.contentForeground
                    fontFamily: root.contentFontFamily
                  }

                  Repeater {
                    model: dayGroup.modelData.sessions

                    delegate: Text {
                      required property var modelData
                      width: dayGroup.width
                      text: Qt.formatDateTime(new Date(modelData.startedAt), "HH:mm") + " " + root.dotGlyph + " " + modelData.minutes + " min"
                      color: root.contentForeground
                      font.family: root.contentFontFamily
                      font.pixelSize: Style.font.body
                    }
                  }
                }
              }
            }
          }
        }
      }

      // Like historyScreen, this is an Item rather than a Column: the
      // Flickable fills an anchor-derived height while its content owns the
      // implicit height used to fit the panel. Making the outer item a
      // positioner would close that sizing path back onto itself.
      Item {
        id: settingsScreen
        anchors.top: screenActions.bottom
        anchors.topMargin: Style.space(14)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: root.screen === "settings"
        implicitHeight: settingsColumn.implicitHeight
        Keys.onEscapePressed: keyCatcher.forceActiveFocus()

        Flickable {
          id: settingsFlick
          width: parent.width
          height: parent.height
          contentWidth: width
          contentHeight: settingsColumn.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          flickableDirection: Flickable.VerticalFlick
          interactive: contentHeight > height
          QQC.ScrollBar.vertical: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

          Column {
            id: settingsColumn
            width: settingsFlick.width
            spacing: Style.space(16)

            // QQC.SpinBox replaces its value binding after an edit, so each
            // handler below restores the service-backed binding.
            // Without a timer, that deliberately reverts the unapplied edit.
            NumberField {
              id: focusMinutesField
              width: parent.width
              label: "Focus minutes"
              from: Model.MIN_MINUTES
              to: Model.MAX_MINUTES
              value: root.timer ? root.timer.settingsSnapshot.minutes : root.setting("minutes", Model.DEFAULT_MINUTES)
              field.live: false
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
              onModified: function (value) {
                if (root.timer) root.timer.commitSettings({ minutes: value })
                focusMinutesField.field.value = Qt.binding(function () { return focusMinutesField.value })
              }
            }

            NumberField {
              id: breakMinutesField
              width: parent.width
              label: "Short break"
              from: Model.MIN_MINUTES
              to: Model.MAX_MINUTES
              value: root.timer ? root.timer.settingsSnapshot.breakMinutes : root.setting("breakMinutes", Model.DEFAULT_BREAK_MINUTES)
              field.live: false
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
              onModified: function (value) {
                if (root.timer) root.timer.commitSettings({ breakMinutes: value })
                breakMinutesField.field.value = Qt.binding(function () { return breakMinutesField.value })
              }
            }

            NumberField {
              id: longBreakMinutesField
              width: parent.width
              label: "Long break"
              from: Model.MIN_MINUTES
              to: Model.MAX_MINUTES
              value: root.timer ? root.timer.settingsSnapshot.longBreakMinutes : root.setting("longBreakMinutes", Model.DEFAULT_LONG_BREAK_MINUTES)
              field.live: false
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
              onModified: function (value) {
                if (root.timer) root.timer.commitSettings({ longBreakMinutes: value })
                longBreakMinutesField.field.value = Qt.binding(function () { return longBreakMinutesField.value })
              }
            }

            NumberField {
              id: cyclesField
              width: parent.width
              label: "Cycles before long break"
              from: Model.MIN_CYCLES
              to: Model.MAX_CYCLES
              value: root.timer ? root.timer.settingsSnapshot.cyclesBeforeLongBreak : root.setting("cyclesBeforeLongBreak", Model.DEFAULT_CYCLES)
              field.live: false
              foreground: root.contentForeground
              fontFamily: root.contentFontFamily
              onModified: function (value) {
                if (root.timer) root.timer.commitSettings({ cyclesBeforeLongBreak: value })
                cyclesField.field.value = Qt.binding(function () { return cyclesField.value })
              }
            }

            Row {
              width: parent.width
              spacing: Style.spacing.md

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - autoStartBreaksSwitch.implicitWidth - parent.spacing
                text: "Auto-start breaks"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
              }

              ToggleSwitch {
                id: autoStartBreaksSwitch
                anchors.verticalCenter: parent.verticalCenter
                checked: root.timer ? root.timer.settingsSnapshot.autoStartBreaks === true : root.setting("autoStartBreaks", true) === true
                foreground: root.contentForeground
                onToggled: if (root.timer) root.timer.commitSettings({ autoStartBreaks: !autoStartBreaksSwitch.checked })
              }
            }

            Row {
              width: parent.width
              spacing: Style.spacing.md

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - autoStartWorkSwitch.implicitWidth - parent.spacing
                text: "Auto-start work"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
              }

              ToggleSwitch {
                id: autoStartWorkSwitch
                anchors.verticalCenter: parent.verticalCenter
                checked: root.timer ? root.timer.settingsSnapshot.autoStartWork === true : root.setting("autoStartWork", false) === true
                foreground: root.contentForeground
                onToggled: if (root.timer) root.timer.commitSettings({ autoStartWork: !autoStartWorkSwitch.checked })
              }
            }

            Row {
              width: parent.width
              spacing: Style.spacing.md

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - notifySwitch.implicitWidth - parent.spacing
                text: "Notify on completion"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
              }

              ToggleSwitch {
                id: notifySwitch
                anchors.verticalCenter: parent.verticalCenter
                checked: root.timer ? root.timer.settingsSnapshot.notify === true : root.setting("notify", true) === true
                foreground: root.contentForeground
                onToggled: if (root.timer) root.timer.commitSettings({ notify: !notifySwitch.checked })
              }
            }
          }
        }
      }
    }
  }
}
