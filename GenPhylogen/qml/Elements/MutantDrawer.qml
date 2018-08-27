import QtQuick 2.4
import "qrc:/Elements/qml/Elements"

Loader{
    id: root
    sourceComponent: undefined

    property variant mutantsModel
    property variant parentChain
    property bool showKiller: false

    state: "hidden"

    signal addMutantSignal( variant mutant )
    signal killCreepSignal()

    function toggleMutants(){
        if( state == "hidden" ) showMutants();
        else hideMutants();
    }

    function showMutants(){        
        showMutantsAnimation.start();
    }

    function hideMutants(){
        hideMutantsAnimation.start();
    }

    SequentialAnimation{
        id: showMutantsAnimation
        ScriptAction{ script:{
                root.state = "shown";
                parentChain.z = 1;
                root.showKiller = ( parentChain.creepsInChain > 1 );
                root.sourceComponent = mutant_component;
            }
        }
    }

    SequentialAnimation{
        id: hideMutantsAnimation
        NumberAnimation { target: root.item; property: "opacity"; to: 0; duration: 300; easing.type: Easing.InOutQuad }
        ScriptAction { script: {
                root.state = "hidden";
                parentChain.z = 0;
                root.sourceComponent = undefined
            }
        }
    }

    Component{
        id: mutant_component
        Rectangle{
            id: mutantsDrawer
            opacity: 0
            NumberAnimation { target: mutantsDrawer; property: "opacity"; to: 1; duration: 300; running: true; easing.type: Easing.InOutQuad }
            smooth: true; antialiasing: true
            height: 75
            width: 100 * mutantsModel.length
            radius: 35
            color: "#D0181818"
            border.color: "#A0A0A0"
            border.width: 2
            Rectangle{
                id: creepKiller
                visible: root.showKiller
                smooth: true; antialiasing: true
                anchors{ horizontalCenter: mutantsDrawer.horizontalCenter; top: mutantsDrawer.bottom; topMargin: 100 }
                height: 75
                width: 75
                radius: 25
                color: "#D0181818"
                border.color: "#B07070"
                border.width: 2
                MouseArea{
                    anchors.fill: parent
                    onClicked: killCreepSignal();
                }
            }

            Repeater{
                id: mutantRepeater
                model: mutantsModel
                delegate: CreepView{
                    traits: mutantsModel[index].traits
                    x: 100*index + 50 - width/2
                    y: 0//50 - height/2
                    scale: .5
                    MouseArea{
                        anchors.fill:parent
                        onClicked:{
                            var mutantToAdd = mutantsModel[index];                            
                            mutantToAdd["x"] = parent.mapToItem(stage,0,0).x
                            mutantToAdd["y"] = parent.mapToItem(stage,0,0).y
                            addMutantSignal( mutantToAdd );
                            hideMutants();
                        }
                    }
                }
            }
        }
    }
}
