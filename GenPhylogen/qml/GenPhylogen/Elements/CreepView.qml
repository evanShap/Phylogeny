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
            if( isEndCreep ) return component_glowEnd;
            else if( isMutant ) return component_glowMutant;
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
                radius: 75
                samples: 24
                color: "#F07070"
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
        tentacles.tentacleColor = "#E0706060"
        body.color = "#E0704444"
    }
}

