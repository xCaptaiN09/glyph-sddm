import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 300
    height: 100

    property color accentColor: "#D71921" // Nothing Red
    property color textColor: "white"
    property string fontName: "monospace"

    RowLayout {
        id: powerRow
        spacing: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // Sleep
        Button {
            id: sleepBtn
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            
            background: Rectangle {
                color: Qt.rgba(0, 0, 0, 0.7)
                radius: 24
                border.color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.2)
                border.width: 1
            }
            
            contentItem: Item {
                Text {
                    anchors.centerIn: parent
                    text: "󰤄"
                    font.pixelSize: 20
                    color: root.textColor
                }
            }
            
            onClicked: sddm.suspend()
        }

        // Restart
        Button {
            id: restartBtn
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            
            background: Rectangle {
                color: Qt.rgba(0, 0, 0, 0.7)
                radius: 24
                border.color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.2)
                border.width: 1
            }
            
            contentItem: Item {
                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    font.pixelSize: 20
                    color: root.textColor
                }
            }
            
            onClicked: sddm.reboot()
        }

        // Power (Red Accent)
        Button {
            id: powerBtn
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            
            background: Rectangle {
                color: root.accentColor
                radius: 30
            }
            
            contentItem: Item {
                Text {
                    anchors.centerIn: parent
                    text: "󰐥"
                    font.pixelSize: 24
                    color: "white"
                    // Manual nudge if the font baseline is off
                    anchors.verticalCenterOffset: 0
                }
            }
            
            onClicked: sddm.powerOff()
        }
    }
}
