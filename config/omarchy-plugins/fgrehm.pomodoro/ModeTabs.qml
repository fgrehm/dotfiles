import QtQuick
import qs.Commons
import qs.Ui as Ui

Item {
  id: root

  property string value: "pomodoro"
  property color foreground: Color.foreground
  property color accent: Color.accent
  property string fontFamily: Style.font.family

  signal changed(string value)

  implicitHeight: tabs.implicitHeight

  Row {
    id: tabs
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 0

    Ui.Button {
      width: tabs.width / 2
      text: "Pomodoro"
      bordered: false
      foreground: root.foreground
      fontFamily: root.fontFamily
      opacity: root.enabled ? (root.value === "pomodoro" ? 1 : 0.5) : 0.35
      onClicked: if (root.value !== "pomodoro") root.changed("pomodoro")
    }

    Ui.Button {
      width: tabs.width / 2
      text: "Timer"
      bordered: false
      foreground: root.foreground
      fontFamily: root.fontFamily
      opacity: root.enabled ? (root.value === "timer" ? 1 : 0.5) : 0.35
      onClicked: if (root.value !== "timer") root.changed("timer")
    }
  }

  Rectangle {
    anchors.bottom: parent.bottom
    x: root.value === "timer" ? root.width / 2 : 0
    width: root.width / 2
    height: Math.max(1, Style.normalBorderWidth)
    color: root.accent
    opacity: root.enabled ? 1 : 0.35
  }
}
