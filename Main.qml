import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "components"

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "black"
    focus: true

    // State Management
    property bool isUnlocked: false
    property color finalClockColor: "transparent" 
    property bool readyToReveal: false 
    
    // MASTER INDICES
    property int userIdx: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIdx: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    Component.onCompleted: {
        if (userModel.lastIndex >= 0) userIdx = userModel.lastIndex
        if (sessionModel.lastIndex >= 0) sessionIdx = sessionModel.lastIndex
    }

    FontLoader { id: ndotFont; source: "assets/fonts/Ndot-57-Aligned.ttf"; }
    property string globalFont: ndotFont.status == FontLoader.Ready ? ndotFont.name : "monospace"

    Image {
        id: bg
        anchors.fill: parent
        source: config.background || "assets/images/background.jpg"
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: if (status == Image.Ready) brightnessTimer.start()
    }

    Timer { id: brightnessTimer; interval: 800; onTriggered: brightnessCanvas.requestPaint() }

    Canvas {
        id: brightnessCanvas
        width: 20; height: 20; visible: false
        renderTarget: Canvas.Image 
        onPaint: {
            var ctx = getContext("2d")
            ctx.drawImage(bg, 0, 0, width, height)
            var data = ctx.getImageData(0, 0, width, height).data
            var r = 0, g = 0, b = 0
            for (var i = 0; i < data.length; i += 4) { r += data[i]; g += data[i+1]; b += data[i+2] }
            var luminance = (0.299 * (r/(data.length/4)) + 0.587 * (g/(data.length/4)) + 0.114 * (b/(data.length/4))) / 255
            
            // 1. STEP ONE: CALCULATE AND ASSIGN COLOR
            container.finalClockColor = (luminance > 0.5) ? "black" : "white"
            console.log("Calculated Color: " + container.finalClockColor)
            
            // 2. STEP TWO: WAIT FOR PROPERTY TO SETTLE BEFORE REVEAL
            revealTimer.start()
        }
    }

    Timer {
        id: revealTimer
        interval: 800 // Increased delay for a more cinematic reveal
        onTriggered: container.readyToReveal = true
    }

    Rectangle {
        anchors.fill: parent; color: "black"; opacity: container.isUnlocked ? 0.45 : 0.15
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    MouseArea { anchors.fill: parent; onClicked: container.isUnlocked = true; enabled: !container.isUnlocked }
    Keys.onPressed: if (!container.isUnlocked) { container.isUnlocked = true; event.accepted = true; }

    // THE CLOCK
    Clock {
        id: clock
        anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 80
        fontName: container.globalFont
        textColor: container.finalClockColor
        
        visible: container.readyToReveal
        opacity: visible ? (container.isUnlocked ? 0.4 : 1.0) : 0.0
        
        Behavior on opacity { 
            NumberAnimation { 
                duration: 1200; 
                easing.type: Easing.OutQuint 
            } 
        }
        Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    }

    LoginPanel {
        id: loginPanel
        anchors.centerIn: parent; width: 400
        fontName: container.globalFont; textColor: "white"
        userIndex: container.userIdx; sessionIndex: container.sessionIdx
        onUserSelected: container.userIdx = index; onSessionSelected: container.sessionIdx = index
        opacity: container.isUnlocked ? 1.0 : 0.0; visible: opacity > 0; scale: container.isUnlocked ? 1.0 : 0.95
        Behavior on opacity { NumberAnimation { duration: 350 } }
        Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
        onVisibleChanged: if (visible) focusTimer.start(); else loginPanel.reset()
    }
    
    Connections { target: sddm; function onLoginFailed() { loginPanel.triggerError() } }
    Timer { id: focusTimer; interval: 100; onTriggered: loginPanel.focusPassword() }

    PowerMenu {
        id: powerMenu
        anchors.bottom: parent.bottom; anchors.right: parent.right; anchors.margins: 50
        fontName: container.globalFont; textColor: "white"
        opacity: container.isUnlocked ? 0.5 : 1.0; Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    Text {
        text: "PRESS ANY KEY TO UNLOCK"; font.family: container.globalFont; font.pixelSize: 14; font.letterSpacing: 1
        color: "white"
        visible: container.readyToReveal
        opacity: visible ? (container.isUnlocked ? 0.0 : 0.6) : 0.0
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 40
        Behavior on opacity { NumberAnimation { duration: 1000 } }
    }

    Keys.onEscapePressed: { container.isUnlocked = false; container.focus = true; }
}
