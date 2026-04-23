import QtQuick 2.15

Rectangle {
    id: card
    height: 78
    radius: 14

    property string label:     ""
    property int    cost:      0
    property bool   canAfford: false
    property int    count:     0

    signal buy()

    color:        canAfford ? "#1C1A2E" : "#131319"
    border.color: canAfford ? "#7C3AED" : "#27272A"
    border.width: 1.5

    Column {
        anchors.centerIn: parent
        spacing: 5
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  card.label
            color: card.canAfford ? "#E9D5FF" : "#52525B"
            font.pixelSize: 14
            font.bold:      true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  card.cost + " очков"
            color: card.canAfford ? "#A78BFA" : "#3F3F46"
            font.pixelSize: 12
        }
    }

    // Purchase-count badge
    Rectangle {
        visible: card.count > 0
        anchors.top:         parent.top
        anchors.right:       parent.right
        anchors.topMargin:   6
        anchors.rightMargin: 6
        width: 22; height: 22; radius: 11
        color: "#7C3AED"
        Text {
            anchors.centerIn: parent
            text:  card.count
            color: "#F8F8FF"
            font.pixelSize: 11
            font.bold:      true
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: card.canAfford
        onClicked: card.buy()
        Rectangle {
            anchors.fill: parent
            radius:  parent.parent.radius
            color:   "white"
            opacity: parent.pressed ? 0.06 : 0
        }
    }
}
