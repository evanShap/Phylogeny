import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../Elements"

Item{
    id: root
    property variant traits: [0,0]
    property int nTentacles: traits[0]
    property int nSides: traits[1]    
    property color bodyColor:{
        if ( traits[2] == 0 ) return "#E0303890"
        else if ( traits[2] == 1 ) return "#E03C2850"
        else if ( traits[2] == 2 ) return "#E0882830"
        else if ( traits[2] == 3 ) return "#E0B46430"
        else if ( traits[2] == 4 ) return "#E0E0C020"
    }

    property bool isEndCreep: false
    property bool isActive: true

    width: 75
    height: 75
    transformOrigin: Item.Center
    rotation: 360 * Math.random()
    scale: 1
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
            property color tentacleColor: Qt.rgba( bodyColor.r/3 + .15 , bodyColor.g/3 + .15 , bodyColor.b/3 + .15 , .75 )
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
            border.color: "#20A0A0A0"
            border.width: 4
            Behavior on color { ColorAnimation{ duration : 250 } }            
        }
    }    

    Loader {
        id: loader_glow
        anchors.fill: blur
        sourceComponent:{
            if( isActive ) return component_glowEnd;
//            else if( isMutant ) return component_glowMutant;
            else return component_glowNorm;
        }
        Component {
            id: component_glowEnd
            Glow{
                id: glow
                source: blur
                radius: 48
                samples: 16
                spread: .15
                color: bodyColor
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
                radius: 8
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
    Repeater{
        id: lineRepeater
        model: nSides
        delegate: Rectangle{
            smooth: true; antialiasing: true
            anchors {horizontalCenter: parent.horizontalCenter}
            width: parent.width/2 + Math.random()*parent.width/6
            height: body.width/2 * Math.pow(1/nSides, 1.4)
            radius: height/4
            y: body.height/(nSides) * (index+.25)
            color: "#B0FFFFFF"
        }
    }

    function deactivate(){
//        tentacles.tentacleColor = "#D0205050"
        body.opacity = .65
        tentacles.opacity = .65
        root.scale = .45
        isActive = false
    }
}

