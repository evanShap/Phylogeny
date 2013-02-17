import QtQuick 2.0
import "../Elements"
Item{
    id: root

    width: creepView.width
    height: creepView.height

    property bool isEndCreep: false
    property variant mutantsModel: generateMutantsModel()
    property bool active: true
    property variant leadTethers: []
    property variant traits: []
    property real prefXOffset: 0
    property bool isMutant: false
    property bool isBranchPoint: false
    property bool isDragging: mouseArea.drag.active

    Behavior on x { NumberAnimation{ duration: .9 * animateInterval } }
    Behavior on y { NumberAnimation{ duration: .9 * animateInterval } }

    signal addMutantSignal( variant mutant )

    CreepView{
        id: creepView
        anchors.centerIn: parent
        traits: root.traits
        isEndCreep: root.isEndCreep
    }

    Rectangle{
        id: mutantDrawer
        visible: false
        opacity: 0
        smooth: true; antialiasing: true
        anchors{ bottom: root.top; bottomMargin: 10; horizontalCenter: root.horizontalCenter }
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
                        toggleState();
                    }
                }
            }
        }
    }

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAxis
        onClicked: if(active) toggleState()
        drag.minimumX: 0
        drag.maximumX: stage.width - width
        property bool dragActive: drag.active
        property real startDragX: 0
        onDragActiveChanged: {
            if( dragActive ) startDragX = root.x
            else if( !active ) prefXOffset += root.x - startDragX;
        }
    }

    transitions:[
        Transition {
            to: "mutants"
            ScriptAction{ script: {mutantDrawer.visible = true; root.parent.z=1} }
            NumberAnimation { target: mutantDrawer; property: "opacity"; duration: 250; to: 1; easing.type: Easing.InOutQuad }
        },
        Transition {
            from: "mutants"
            NumberAnimation { target: mutantDrawer; property: "opacity"; duration: 250; to: 0; easing.type: Easing.InOutQuad }
            ScriptAction{ script: {mutantDrawer.visible = false; root.parent.z=0;} }
        }
    ]

    function toggleState(){
        if( state == "mutants" ) state = "";
        else if( active ) state = "mutants";
    }

    function deactivate(){
        active = false;
        state = "";
        creepView.deactivate();
    }

    function kill(){
        deactivate();
        opacity = 0;
        visible = false;
    }

    function generateMutantsModel(){
        var _mutantsModel = []
        var validTraits = []

        for ( var i=0; i<traits.length; i++ ){
            validTraits[i] = [];

            // if we have model for trait limit and trait is at limit
            if( traitDataModel.get(i)){
                if( traits[i] == traitDataModel.get(i).min){
                    if( traitDataModel.get(i).loops ){
                        validTraits[i].push( traitDataModel.get(i).max );
                        if( traits[i]+1 < traitDataModel.get(i).max ) validTraits[i].push( traits[i]+1 );
                    }
                    else
                        validTraits[i].push( traits[i]+1 );
                }
                else if( traits[i] == traitDataModel.get(i).max){
                    if( traitDataModel.get(i).loops ){
                        validTraits[i].push( traitDataModel.get(i).min );
                        if( traits[i]-1 > traitDataModel.get(i).min ) validTraits[i].push( traits[i]-1 );
                    }
                    else
                        validTraits[i].push( traits[i]-1 );
                }
                else{
                    validTraits[i].push( traits[i]-1 );
                    validTraits[i].push( traits[i]+1 );
                }
            }

            // otherwise push incremented traits
            else{
                validTraits[i].push( traits[i]-1 );
                validTraits[i].push( traits[i]+1 );
            }
        }
        //add the non-mutated form
        var mutantData = {}
        var _mutantTraits = []
        mutantData["isMutator"] = false;
        mutantData["traits"] = traits;
        _mutantsModel.push( mutantData );

        //add all possible mutated forms
        for ( i=0; i<validTraits.length; i++ ){
            for ( var j=0; j<validTraits[i].length; j++ ){
                _mutantTraits = traits;
                _mutantTraits[i] = validTraits[i][j];
                mutantData = {}
                mutantData["isMutator"] = true;
                mutantData["traits"] = _mutantTraits;
                _mutantsModel.push( mutantData );
            }
        }
        return _mutantsModel;
    }
}
