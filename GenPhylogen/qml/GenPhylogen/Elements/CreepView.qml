import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../Elements"

Item{
    id: root
    property int nTentacles: 0
    property int nSides: 0
    property bool isEndCreep: false

    width: 40
    height: 40
    transformOrigin: Item.Center
    rotation: 360 * Math.random()
    Behavior on scale { NumberAnimation{ duration: 250 } }

    Item{
        id: blurHolder
        visible: false
        anchors.centerIn: parent
        width: 300
        height: 300
        Repeater{
            id: tentacles
            anchors.centerIn: parent
            property color tentacleColor: "#F0E08080"
            Behavior on tentacleColor { ColorAnimation{ duration : 250 } }
            model: nTentacles
            delegate: Tentacle{
                tentacleColor: tentacles.tentacleColor
                bulkRotation: 137.5 * index
            }
        }
        Rectangle{
            id: body
            smooth: true; antialiasing: true
            anchors.centerIn: parent
            width: root.width
            height: root.height
            radius: width / 2
            color: "#E04444"
            Behavior on color { ColorAnimation{ duration : 250 } }
        }
    }

    Loader {
        id: loader_glow
        anchors.fill: blur
        sourceComponent:{
//            if( isEndCreep ) return component_glowEnd;
            if( isMutant ) return component_glowMutant;
            else return undefined;
        }
        Component {
            id: component_glowEnd
            Glow{
                id: glow
                source: blur
                radius: 75
                samples: 24
                color: "#A0F0E0"
            }
        }
        Component {
            id: component_glowMutant
            Glow{
                id: glow
                source: blur
                radius: 12
                samples: 16
                spread: .6
                color: "#FF4040"
            }
        }
    }

    GaussianBlur{
        id: blur
        source: blurHolder
        anchors.fill: blurHolder
        radius: 8
        samples: 8
    }

    Text {
        id: sideText
        transformOrigin: Item.Center
        rotation: -root.rotation
        anchors.centerIn: root
        font.pointSize: 24
        text: nSides
        color: "white"
    }

    function deactivate(){
        tentacles.tentacleColor = "#B0404040"
        body.color = "#B0404040"
        root.scale = .75
    }
}

