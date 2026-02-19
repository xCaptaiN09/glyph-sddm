import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 600
    height: 300

    property string fontName: "serif"
    property color textColor: "transparent" // Start transparent to prevent flash

    function getOSLogo(name) {
        var n = name.toLowerCase()
        if (n.includes("arch")) return "󰣇"
        if (n.includes("ubuntu")) return "󰕈"
        if (n.includes("fedora")) return "󰣛"
        if (n.includes("debian")) return "󰣚"
        if (n.includes("manjaro")) return "󱘊"
        if (n.includes("mint")) return "󰣭"
        if (n.includes("kali")) return "󴑗"
        if (n.includes("pop")) return "󰣏"
        if (n.includes("nix")) return "󱄅"
        if (n.includes("gentoo")) return "󰣨"
        if (n.includes("suse")) return "󰣫"
        if (n.includes("void")) return "󰣦"
        if (n.includes("artix")) return "󰣆"
        if (n.includes("alpine")) return "󰣪"
        if (n.includes("cent")) return "󰣑"
        if (n.includes("garuda")) return "󱄊"
        if (n.includes("endeavour")) return "󰣚"
        return "" 
    }

    property string currentHostName: (sddm.hostName && sddm.hostName !== "") ? sddm.hostName : "archlinux"
    property string timeStr: Qt.formatTime(new Date(), "HH:mm")

    Column {
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: 0

        Row {
            id: clockRow
            spacing: 0
            Repeater {
                model: root.timeStr.length
                Item {
                    width: {
                        var c = root.timeStr.charAt(index)
                        if (c === "1") return 65
                        if (c === ":") return 35
                        return 95
                    }
                    height: 150
                    Text {
                        anchors.centerIn: parent
                        text: root.timeStr.charAt(index)
                        font.family: root.fontName
                        font.pixelSize: 150
                        color: root.textColor
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 5
            spacing: 0
            Text {
                id: dateLabel
                text: Qt.formatDate(new Date(), "ddd, d MMM").toUpperCase()
                font.family: root.fontName
                font.pixelSize: 32
                color: root.textColor
                opacity: 0.9
                topPadding: -10
            }
            Row {
                spacing: 12; topPadding: 10
                Text { text: root.getOSLogo(root.currentHostName); color: root.textColor; font.pixelSize: 22; visible: text !== ""; anchors.verticalCenter: parent.verticalCenter; anchors.verticalCenterOffset: -3 }
                Text { text: root.currentHostName.toUpperCase(); font.family: root.fontName; font.pixelSize: 22; color: root.textColor; opacity: 0.8; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }

    Timer { id: timeTimer; interval: 1000; running: true; repeat: true; onTriggered: root.timeStr = Qt.formatTime(new Date(), "HH:mm") }
}
