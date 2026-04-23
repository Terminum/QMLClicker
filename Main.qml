import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1

Window {
    id: root
    width: 400
    height: 700
    minimumWidth: 320
    minimumHeight: 520
    visible: true
    color: "#0A0A0F"
    title: qsTr("Clicker")

    // ── Persistent state ───────────────────────────────────
    Settings {
        id: save
        property real score:    0
        property real coef:     1.0
        property real autoRate: 0.0
        property int  s1Count:  0   // +0.5/click,  base 50,  ×1.5 each
        property int  s2Count:  0   // +1.0/click,  base 300, ×1.5 each
        property int  a1Count:  0   // auto +0.5/s, base 150, ×1.8 each
        property int  a2Count:  0   // auto +1.0/s, base 600, ×1.8 each
    }

    function s1Cost() { return Math.round(50  * Math.pow(1.5, save.s1Count)) }
    function s2Cost() { return Math.round(300 * Math.pow(1.5, save.s2Count)) }
    function a1Cost() { return Math.round(150 * Math.pow(1.8, save.a1Count)) }
    function a2Cost() { return Math.round(600 * Math.pow(1.8, save.a2Count)) }

    // ── Auto-clicker (10 ticks/sec for smooth display) ─────
    Timer {
        interval: 100
        repeat:   true
        running:  save.autoRate > 0
        onTriggered: save.score += save.autoRate / 10
    }

    // ── Score section ──────────────────────────────────────
    Column {
        id: scoreSection
        anchors.top:              parent.top
        anchors.topMargin:        52
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  "ОЧКИ"
            color: "#52525B"
            font.pixelSize:    11
            font.letterSpacing: 4
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (save.score >= 1000000) return (save.score / 1000000).toFixed(2) + "M"
                if (save.score >= 10000)   return (save.score / 1000).toFixed(1) + "K"
                if (save.score >= 1000)    return (save.score / 1000).toFixed(2) + "K"
                return save.score.toFixed(1)
            }
            color: "#FCD34D"
            font.pixelSize: 58
            font.bold:      true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                var s = "+" + save.coef.toFixed(1) + " за клик"
                if (save.autoRate > 0)
                    s += "  ·  +" + save.autoRate.toFixed(1) + "/сек"
                return s
            }
            color: "#52525B"
            font.pixelSize: 13
        }
    }

    // ── Clicker button ─────────────────────────────────────
    Item {
        anchors.top:    scoreSection.bottom
        anchors.bottom: upgradesSection.top
        anchors.left:   parent.left
        anchors.right:  parent.right

        Rectangle {
            id: clickBtn
            anchors.centerIn: parent
            property real sz: Math.min(parent.width * 0.54, parent.height * 0.80)
            width:  sz
            height: sz
            radius: sz / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#B89EFF" }
                GradientStop { position: 1.0; color: "#5B21B6" }
            }

            // Inner highlight ring
            Rectangle {
                anchors.centerIn: parent
                width:  parent.width  - 8
                height: parent.height - 8
                radius: parent.radius
                color:  "transparent"
                border.color: "#FFFFFF"
                border.width: 1
                opacity: 0.10
            }

            Behavior on scale {
                NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                onPressed:  clickBtn.scale = 0.93
                onReleased: clickBtn.scale = 1.0
                onClicked: {
                    save.score += save.coef
                    var pt = clickBtn.mapToItem(root.contentItem,
                                               clickBtn.width / 2, 16)
                    floatingTextComp.createObject(root,
                        { x: pt.x - 16, y: pt.y })
                }
            }
        }
    }

    // ── Upgrades section ───────────────────────────────────
    Column {
        id: upgradesSection
        anchors.bottom:       parent.bottom
        anchors.bottomMargin: 40
        anchors.left:         parent.left
        anchors.right:        parent.right
        anchors.leftMargin:   20
        anchors.rightMargin:  20
        spacing: 10

        Text {
            width:               parent.width
            horizontalAlignment: Text.AlignHCenter
            text:                "УЛУЧШЕНИЯ"
            color:               "#52525B"
            font.pixelSize:      11
            font.letterSpacing:  4
        }

        // Click-power row
        Row {
            width:   parent.width
            spacing: 10
            UpgradeButton { width: (parent.width - 10) / 2
                label:     "+0.5 за клик"
                cost:      s1Cost()
                count:     save.s1Count
                canAfford: save.score >= s1Cost()
                onBuy: { save.score -= s1Cost(); save.coef += 0.5; save.s1Count++ }
            }
            UpgradeButton { width: (parent.width - 10) / 2
                label:     "+1.0 за клик"
                cost:      s2Cost()
                count:     save.s2Count
                canAfford: save.score >= s2Cost()
                onBuy: { save.score -= s2Cost(); save.coef += 1.0; save.s2Count++ }
            }
        }

        // Auto-clicker row
        Row {
            width:   parent.width
            spacing: 10
            UpgradeButton { width: (parent.width - 10) / 2
                label:     "Авто +0.5/сек"
                cost:      a1Cost()
                count:     save.a1Count
                canAfford: save.score >= a1Cost()
                onBuy: { save.score -= a1Cost(); save.autoRate += 0.5; save.a1Count++ }
            }
            UpgradeButton { width: (parent.width - 10) / 2
                label:     "Авто +1.0/сек"
                cost:      a2Cost()
                count:     save.a2Count
                canAfford: save.score >= a2Cost()
                onBuy: { save.score -= a2Cost(); save.autoRate += 1.0; save.a2Count++ }
            }
        }
    }

    // ── Floating "+N" text ─────────────────────────────────
    Component {
        id: floatingTextComp
        Text {
            id: ft
            text:  "+" + save.coef.toFixed(1)
            color: "#C4B5FD"
            font.pixelSize: 20
            font.bold:      true
            opacity: 1.0
            z: 100
            ParallelAnimation {
                running: true
                NumberAnimation {
                    target: ft; property: "y"
                    to: ft.y - 70
                    duration: 900; easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ft; property: "opacity"
                    from: 1.0; to: 0.0; duration: 900
                }
                onStopped: ft.destroy()
            }
        }
    }
}
