import QtQuick 2.4
import QtQuick.Window 2.2
import "qrc:/Elements/qml/Elements"

Window {
    visible: true
    width: 1200
    height: 900
    Item {
        id: root
        anchors.fill: parent
        Rectangle{
            id: background
            anchors.fill: parent
            color: "#282828"
        }
        TreeStage{
            id: stage
            width: 1200
            height: 768
            anchors{ bottom: root.bottom }
        }

        Rectangle{
            id: topBackground
            smooth: true; antialiasing: true
            width: parent.width
            opacity: .75
            anchors{ top: parent.top; bottom: stage.top }
            border.width: 0
            border.color: "#A0A0A0"
            color: "#181818"
        }
        Rectangle{
            id: goal
            smooth: true; antialiasing: true
            width: 220
            height: width
            radius: width/2
            opacity: .75
            anchors{ top: topBackground.top; horizontalCenter: topBackground.horizontalCenter; topMargin: -30 }
            border.width: 0
            border.color: "#A0A0A0"
            color: "#181818"
        }
        CreepView{
            id: goalCreep
            traits: [3,3,3]
            anchors{ centerIn: goal }
        }

        Text{
            id: genText
            text: "GENERATIONS " + stage.currentLevel
            color: "#B0D0D0"
            font.pointSize: 30
            font.family: "Courier"
            font.weight: Font.Black
            x: 40; y: 40
        }

        Text{
            id: mutText
            text: "MUTATIONS " + stage.totalMutations
            color: "#B0D0D0"
            font.pointSize: 30
            font.family: "Courier"
            font.weight: Font.Black
            anchors { top: genText.bottom; left: genText.left }
        }
    }
}
