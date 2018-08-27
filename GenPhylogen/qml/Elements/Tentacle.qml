import QtQuick 2.4

Item{
    id: root
    property real wobblePeriod: Math.random()*1200 + 1800
    property real tentacleWobbleAngle: Math.random()*2 + 2
    property real tentacleWidth: 34
    property real tentacleLength: 67
    property real tentacleLengthDev: Math.random()*2 + 2
    property real bulkRotation
    property color tentacleColor: "#F0E08080"

    width: childrenRect.width
    height: childrenRect.height
    transformOrigin: Item.Bottom
    anchors {bottom: parent.verticalCenter; horizontalCenter: parent.horizontalCenter}

    SequentialAnimation{
        running: true
        loops: Animation.Infinite
        ParallelAnimation{
            NumberAnimation { target: root; property: "rotation"; duration: wobblePeriod/2; from: bulkRotation -tentacleWobbleAngle; to: bulkRotation +tentacleWobbleAngle; easing.type: Easing.InOutSine }
            NumberAnimation { target: shaft; property: "height"; duration: wobblePeriod/2; to: tentacleLength -tentacleLengthDev; easing.type: Easing.InOutSine }
        }
        ParallelAnimation{
            NumberAnimation { target: root; property: "rotation"; duration: wobblePeriod/2; from: bulkRotation +tentacleWobbleAngle; to: bulkRotation -tentacleWobbleAngle; easing.type: Easing.InOutSine }
            NumberAnimation { target: shaft; property: "height"; duration: wobblePeriod/2; to: tentacleLength +tentacleLengthDev; easing.type: Easing.InOutSine }
        }
    }
    Rectangle{
        id: ball
        smooth: true; antialiasing: true
        width: tentacleWidth * 1.25
        height: width
        radius: width/2
        color: {
            var color = Qt.rgba(tentacleColor.r,tentacleColor.g,tentacleColor.b,.94)
            return color
        }
        border.color: "#24FFFFFF"
        border.width: 2
        z: 1
    }
    Rectangle{
        id: shaft
        anchors { top: ball.verticalCenter; horizontalCenter: ball.horizontalCenter }
        smooth: true; antialiasing: true
        width: tentacleWidth
        height: tentacleLength
        radius: width/2
        color: tentacleColor
        border.color: "#18FFFFFF"
        border.width: 1
    }
}
