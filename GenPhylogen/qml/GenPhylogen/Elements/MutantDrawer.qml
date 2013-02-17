import QtQuick 2.0
import "../Elements"

Loader{
    id: root
    sourceComponent: undefined

    property variant mutantsModel
    property variant parentChain

    state: "hidden"

    signal addMutantSignal( variant mutant )

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
            id: mutant
            opacity: 0
            NumberAnimation { target: mutant; property: "opacity"; to: 1; duration: 300; running: true; easing.type: Easing.InOutQuad }
            smooth: true; antialiasing: true
            height: 100
            width: 100 * mutantsModel.length
            radius: 35
            color: "#D0404040"
            border.color: "#A0F0E0"
            border.width: 2
            Repeater{
                id: mutantRepeater
                model: mutantsModel
                delegate: CreepView{
                    traits: mutantsModel[index].traits
                    x: 100*index + 50 - width/2
                    y: 50 - height/2
                    scale: .5
                    MouseArea{
                        anchors.fill:parent
                        onClicked:{
                            var mutantToAdd = mutantsModel[index];
                            mutantToAdd["x"] = parent.mapToItem(stage).x
                            mutantToAdd["y"] = parent.mapToItem(stage).y
                            addMutantSignal( mutantToAdd );
                            hideMutants();
                        }
                    }
                }
            }
        }
    }
}
