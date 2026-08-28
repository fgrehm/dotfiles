import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

PanelWindow {
    id: root

    property var timer: null
    property bool visibleCard: false
    property string phaseLabel: "Focus"

    signal startRequested()
    signal dismissRequested()

    visible: visibleCard
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "fgrehm-pomodoro-next-phase"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.28)

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissRequested()
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: card.implicitWidth + Style.space(32)
        height: card.implicitHeight + Style.space(28)
        radius: Style.space(10)
        color: Color.background
        border.color: Color.accent
        border.width: Math.max(1, Style.normalBorderWidth)

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
            id: card
            anchors.centerIn: parent
            spacing: Style.space(12)

            Text {
                text: "Ready for " + root.phaseLabel.toLowerCase() + "?"
                color: Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Click Start to move on"
                color: Qt.darker(Color.foreground, 1.25)
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Style.space(10)

                Button {
                    text: "Start " + root.phaseLabel
                    onClicked: root.startRequested()
                }

                Button {
                    text: "Dismiss"
                    onClicked: root.dismissRequested()
                }
            }
        }
    }
}
