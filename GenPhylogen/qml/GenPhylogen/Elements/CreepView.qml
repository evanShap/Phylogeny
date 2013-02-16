import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../Elements"

Item{
    id: root
    property variant traits: [0,0]
    property int nTentacles: traits[0]
    property int nSides: traits[1]
    property color bodyColor:{
        if ( traits[2] == 0 ) return "#193E75"
        else if ( traits[2] == 1 ) return "#721D8E"
        else if ( traits[2] == 2 ) return "#A32100"
        else if ( traits[2] == 3 ) return "#526614"
        else if ( traits[2] == 4 ) return "#00624A"
    }

    property bool isEndCreep: false
    property bool isActive: true

    width: 40
    height: 40
    transformOrigin: Item.Center
    rotation: 360 * Math.random()
    scale: 1.3
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
            property color tentacleColor: "#A0295048"
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
            color: bodyColor
            border.color: "#A0A0A0"
            border.width: 1
            Behavior on color { ColorAnimation{ duration : 250 } }
        }
    }

    Loader {
        id: loader_glow
        anchors.fill: blur
        sourceComponent:{
            if( isActive ) return component_glowEnd;
            else if( isMutant ) return component_glowMutant;
            else return component_glowNorm;
        }
        Component {
            id: component_glowEnd
            Glow{
                id: glow
                source: blur
                radius: 8
                samples: 8
                spread: .15
                color: "grey"
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
        Component {
            id: component_glowNorm
            Glow{
                id: glow
                source: blur
                radius: 12
                samples: 16
                spread: .6
                color: "#909090"
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
        tentacles.tentacleColor = "#D0205050"
        body.color = "#D0202020"
        root.scale = .75
        isActive = false
    }
}

