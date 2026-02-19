import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 400
    height: 400

    property color accentColor: "#D71921"
    property color textColor: "white"
    property string fontName: "serif" 
    property bool isLoggingIn: false
    
    // API for parent Main.qml
    property int userIndex: 0
    property int sessionIndex: 0
    signal userSelected(int index)
    signal sessionSelected(int index)

    function cleanName(name) {
        if (!name) return ""
        var lastSlash = name.lastIndexOf("/")
        var base = (lastSlash !== -1) ? name.substring(lastSlash + 1) : name
        return base.replace(".desktop", "").replace(/[-_]/g, " ").replace(/\w\S*/g, function(txt){
            return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        });
    }

    // REACTIVE NAME BINDINGS
    property string activeUserName: {
        try {
            if (userModel && userModel.count > 0) {
                var idx = userModel.index(root.userIndex, 0)
                var n = userModel.data(idx, Qt.UserRole + 1) || userModel.data(idx, Qt.DisplayRole)
                if (n) return n
            }
        } catch(e) {}
        return sddm.lastUser ? sddm.lastUser : "USER"
    }
    
    property string activeSessionName: {
        try {
            if (sessionModel && sessionModel.count > 0) {
                var idx = sessionModel.index(root.sessionIndex, 0)
                var n = sessionModel.data(idx, Qt.UserRole + 4) || sessionModel.data(idx, Qt.DisplayRole)
                if (n) return cleanName(n)
            }
        } catch(e) {}
        return "SESSION"
    }

    function focusPassword() { passwordField.forceActiveFocus() }
    function reset() {
        passwordField.text = ""
        isLoggingIn = false
        userDropdown.open = false
        sessionDropdown.open = false
        errorShake.stop()
        card.x = (root.width - card.width) / 2
    }

    function triggerError() { isLoggingIn = false; errorShake.start() }

    SequentialAnimation {
        id: errorShake
        property int duration: 40; property int distance: 8
        NumberAnimation { target: card; property: "x"; to: card.x - errorShake.distance; duration: errorShake.duration; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "x"; to: card.x + errorShake.distance; duration: errorShake.duration; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "x"; to: card.x - errorShake.distance; duration: errorShake.duration; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "x"; to: card.x + errorShake.distance; duration: errorShake.duration; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "x"; to: (root.width - card.width) / 2; duration: errorShake.duration; easing.type: Easing.OutCubic }
        onStarted: { card.border.color = root.accentColor; errorTimer.start() }
    }

    Timer { id: errorTimer; interval: 1000; onTriggered: card.border.color = Qt.rgba(255, 255, 255, 0.3) }

    function handleLogin() {
        if (passwordField.text === "" || isLoggingIn) { triggerError(); return }
        root.isLoggingIn = true
        sddm.login(root.activeUserName, passwordField.text, root.sessionIndex)
        loginTimeout.start()
    }

    Timer { id: loginTimeout; interval: 5000; onTriggered: root.isLoggingIn = false }

    Rectangle {
        id: card
        width: 340; height: 300
        x: (root.width - width) / 2; y: (root.height - height) / 2
        color: Qt.rgba(0, 0, 0, 0.55); radius: 32; border.color: Qt.rgba(255, 255, 255, 0.3); border.width: 1

        ColumnLayout {
            anchors.centerIn: parent; spacing: 20

            MouseArea {
                Layout.preferredWidth: 280; Layout.preferredHeight: 70
                onClicked: { userDropdown.open = !userDropdown.open; sessionDropdown.open = false }
                RowLayout {
                    anchors.centerIn: parent; spacing: 15
                    Rectangle {
                        width: 54; height: 54; radius: 27
                        color: Qt.rgba(255, 255, 255, 0.08)
                        border.color: Qt.rgba(255, 255, 255, 0.25); border.width: 1.5
                        
                        Text { 
                            anchors.centerIn: parent; anchors.verticalCenterOffset: 3
                            text: root.activeUserName.charAt(0).toUpperCase()
                            color: root.textColor; font.pixelSize: 26; font.family: root.fontName 
                        }

                        // Universal Circle Avatar (Works on Qt5 & Qt6 without plugins)
                        Canvas {
                            id: avatarCanvas
                            anchors.fill: parent
                            visible: avatarImage.status === Image.Ready
                            
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                // Create circular path
                                ctx.beginPath();
                                ctx.arc(width/2, height/2, width/2, 0, 2 * Math.PI);
                                ctx.closePath();
                                ctx.clip(); // Clip to circle
                                // Draw the image
                                ctx.drawImage(avatarImage, 0, 0, width, height);
                            }

                            Image {
                                id: avatarImage
                                source: "../assets/images/avatar.jpg"
                                visible: false
                                onStatusChanged: if (status === Image.Ready) avatarCanvas.requestPaint()
                            }
                        }
                    }
                    Text { text: root.activeUserName.toUpperCase(); color: root.textColor; font.pixelSize: 20; font.family: root.fontName }
                    Text { text: "▾"; color: root.textColor; font.pixelSize: 14; opacity: 0.5 }
                }
            }

            Item {
                Layout.preferredWidth: 280; Layout.preferredHeight: 50; Layout.alignment: Qt.AlignHCenter
                TextField {
                    id: passwordField; anchors.fill: parent; echoMode: TextInput.Password; color: root.textColor
                    font.pixelSize: 18; font.family: root.fontName; horizontalAlignment: TextInput.AlignHCenter
                    selectionColor: root.accentColor; enabled: !root.isLoggingIn
                    background: Rectangle { color: Qt.rgba(255, 255, 255, 0.05); radius: 14; border.color: passwordField.activeFocus ? root.accentColor : Qt.rgba(255, 255, 255, 0.2); border.width: 1 }
                    onAccepted: root.handleLogin()
                }
                Text { text: "ENTER PASSWORD"; font.family: root.fontName; font.pixelSize: 16; color: Qt.rgba(255, 255, 255, 0.5); anchors.centerIn: parent; visible: passwordField.text === ""; z: 5 }
            }

            RowLayout {
                Layout.preferredWidth: 280; Layout.alignment: Qt.AlignHCenter; spacing: 15
                MouseArea {
                    Layout.preferredWidth: 180; Layout.preferredHeight: 40
                    onClicked: { sessionDropdown.open = !sessionDropdown.open; userDropdown.open = false }
                    Rectangle {
                        anchors.fill: parent; color: Qt.rgba(255, 255, 255, 0.05); radius: 20; border.color: Qt.rgba(255, 255, 255, 0.15)
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: root.activeSessionName.toUpperCase(); font.family: root.fontName; font.pixelSize: 12; color: root.textColor; opacity: 0.7 }
                            Text { text: "▾"; color: root.textColor; font.pixelSize: 10; opacity: 0.4 }
                        }
                    }
                }
                Button {
                    id: loginButton; Layout.preferredWidth: 50; Layout.preferredHeight: 50; enabled: !root.isLoggingIn
                    background: Rectangle { color: root.isLoggingIn ? Qt.rgba(255, 255, 255, 0.1) : root.accentColor; radius: 25; scale: loginButton.pressed ? 0.9 : 1.0 }
                    contentItem: Item { Text { anchors.centerIn: parent; text: root.isLoggingIn ? "⋯" : "→"; color: "white"; font.pixelSize: 28 } }
                    onClicked: root.handleLogin()
                }
            }
        }

        // DROPDOWNS
        Rectangle {
            id: userDropdown; property bool open: false; visible: open; z: 100; width: parent.width - 20; height: Math.min(200, (userModel ? userModel.count : 0) * 50 + 20)
            anchors.top: parent.top; anchors.topMargin: 10; anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(0, 0, 0, 0.96); radius: 24; border.color: Qt.rgba(255, 255, 255, 0.15)
            ListView {
                id: userList; anchors.fill: parent; anchors.margins: 10; model: userModel; clip: true; focus: userDropdown.open
                currentIndex: root.userIndex; highlightFollowsCurrentItem: true
                highlight: Item { width: userList.width; height: 50; Rectangle { width: 6; height: 6; radius: 3; color: root.accentColor; anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter } }
                Keys.onUpPressed: decrementCurrentIndex(); Keys.onDownPressed: incrementCurrentIndex()
                Keys.onReturnPressed: { root.userSelected(currentIndex); userDropdown.open = false; root.focusPassword() }
                delegate: MouseArea {
                    width: userList.width; height: 50; hoverEnabled: true
                    onClicked: { root.userSelected(index); userDropdown.open = false; root.focusPassword() }
                    onEntered: userList.currentIndex = index
                    Text { anchors.centerIn: parent; text: (model.name || model.display || "USER").toUpperCase(); font.family: root.fontName; font.pixelSize: 16; color: userList.currentIndex === index ? root.accentColor : Qt.rgba(255, 255, 255, 0.6) }
                }
            }
        }

        Text {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 15; anchors.horizontalCenter: parent.horizontalCenter
            text: "NUM LOCK IS ON"; font.family: root.fontName; font.pixelSize: 10; font.letterSpacing: 1
            color: root.accentColor; opacity: 0.8; visible: keyboard.numLock
        }

        Rectangle {
            id: sessionDropdown; property bool open: false; visible: open; z: 100; width: parent.width - 20; height: Math.min(200, (sessionModel ? sessionModel.count : 0) * 50 + 20)
            anchors.bottom: parent.bottom; anchors.bottomMargin: 10; anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(0, 0, 0, 0.96); radius: 24; border.color: Qt.rgba(255, 255, 255, 0.15)
            ListView {
                id: sessionList; anchors.fill: parent; anchors.margins: 10; model: sessionModel; clip: true; focus: sessionDropdown.open
                currentIndex: root.sessionIndex; highlightFollowsCurrentItem: true
                highlight: Item { width: sessionList.width; height: 50; Rectangle { width: 6; height: 6; radius: 3; color: root.accentColor; anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter } }
                Keys.onUpPressed: decrementCurrentIndex(); Keys.onDownPressed: incrementCurrentIndex()
                Keys.onReturnPressed: { root.sessionSelected(currentIndex); sessionDropdown.open = false; root.focusPassword() }
                delegate: MouseArea {
                    width: sessionList.width; height: 50; hoverEnabled: true
                    onClicked: { root.sessionSelected(index); sessionDropdown.open = false; root.focusPassword() }
                    onEntered: sessionList.currentIndex = index
                    Text { anchors.centerIn: parent; text: cleanName(model.name || model.display || "SESSION").toUpperCase(); font.family: root.fontName; font.pixelSize: 14; color: sessionList.currentIndex === index ? root.accentColor : Qt.rgba(255, 255, 255, 0.6) }
                }
            }
        }
    }
}
