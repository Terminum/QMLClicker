import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Window {
    id: _window
    width: 640
    height: 480
    visible: true
    color: "lightgreen"
    title: qsTr("Hello World")

    property int score: 99;
    property int coef: 1;

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.alignment: Qt.AlignHCenter
            height: parent.height / 10
            id: _score
            text: _window.score
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            color: "blue"
            id: _clickerShape
            width: _window.width / 4
            height: _window.width / 4
            radius: _window.width / 4

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    _window.score = _window.score + _window.coef;
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                id: _pulOne
                property int cost: 500
                enabled: _window.score >= cost
                text: "auto +1"
                onClicked: {
                    timerComponent.createObject(_window, {interval: 1000})
                    _window.score -= cost
                }
            }
            Button {
                id: _pulFive
                property int cost: 1000
                enabled: _window.score >= cost
                text: "auto +5"
                onClicked: {
                    timerComponent.createObject(_window, {interval: 500})
                    _window.score -= cost
                }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                id: _multipleClickTwo
                property int cost: 100
                enabled: _window.score >= cost
                text: "x2"
                onClicked: {
                    _window.coef += 2
                    _window.score -= cost
                }

            }
            Button {
                id: _multipleClickFive
                property int cost: 500
                enabled: _window.score >= cost
                text: "x5"
                onClicked: {
                    _window.coef += 5
                    _window.score -= cost
                }
            }
        }
    }

    Component {
            id: timerComponent
            Timer {

                interval: 1000 // Интервал 1 секунда
                repeat: true
                running: true

                onTriggered: {
                    _window.score += coef
                }
            }
        }
}
