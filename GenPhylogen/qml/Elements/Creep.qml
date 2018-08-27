import QtQuick 2.4
import "qrc:/Elements/qml/Elements"
Item{
    id: root

    width: creepView.width
    height: creepView.height

    property bool isEndCreep: false
    property variant mutantsModel: generateMutantsModel()
    property bool active: true
    property variant leadTethers: []
    property variant traits: []
    property variant parentChain
    property real prefXOffset: 0
    property bool isMutant: false
    property bool isBranchPoint: false
    property variant branchChain: undefined
    property bool isDragging: mouseArea.drag.active

    Behavior on x { NumberAnimation{ duration: .9 * animateInterval } }
    Behavior on y { NumberAnimation{ duration: .9 * animateInterval } }

    signal addMutantSignal( variant mutant )
    signal killCreepSignal( variant creep )

    // the visual rendering of the creep
    CreepView{
        id: creepView
        anchors.centerIn: parent
        traits: root.traits
        isEndCreep: root.isEndCreep
    }

    // the visual rendering of the valid mutated forms of the creep
    MutantDrawer {
        id: mutantDrawer
        mutantsModel: root.mutantsModel
        parentChain: root.parentChain
        anchors{ bottom: root.top; bottomMargin: 10; horizontalCenter: root.horizontalCenter }
        Component.onCompleted: {
            addMutantSignal.connect( root.addMutantSignal );
        }
        onKillCreepSignal: root.killCreepSignal( root );
    }

    // clickable area of the creep, opens/closes the mutant drawer
    MouseArea{
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAxis
        onClicked: if(active) mutantDrawer.toggleMutants();
        drag.minimumX: 0
        drag.maximumX: stage.width - width
        property bool dragActive: drag.active
        property real startDragX: 0
        onDragActiveChanged: {
            if( dragActive ) startDragX = root.x
            else if( !active ) prefXOffset += root.x - startDragX;
        }
    }

    // restore a deactivated creep
    function activate(){
        active = true;
        creepView.activate();
    }

    // makes the creepView smal and the creep un-clickable
    function deactivate(){
        active = false;        
        creepView.deactivate();
    }    

    // makes the creep invisible and unclickable
    function kill(){
        deactivate();
        opacity = 0;
        visible = false;
    }

    // creates an array of creepModels representing the valid mutations for the current creep
    function generateMutantsModel(){
        var _mutantsModel = []
        var validTraits = []
        // for each trait in the creep create an array to store valid mutations of that trait
        for ( var i=0; i<traits.length; i++ ){
            validTraits[i] = [];
            // if we have model for how trait bounds
            if( traitDataModel[i]){
                // if trait is at the minimum bound
                if( traits[i] == traitDataModel[i].min){
                    if( traitDataModel[i].loops ){
                        validTraits[i].push( traitDataModel[i].max );
                        if( traits[i]+1 < traitDataModel[i].max ) validTraits[i].push( traits[i]+1 );
                    }
                    else
                        validTraits[i].push( traits[i]+1 );
                }
                // if trait is at the maximum bound
                else if( traits[i] == traitDataModel[i].max){
                    if( traitDataModel[i].loops ){
                        validTraits[i].push( traitDataModel[i].min );
                        if( traits[i]-1 > traitDataModel[i].min ) validTraits[i].push( traits[i]-1 );
                    }
                    else
                        validTraits[i].push( traits[i]-1 );
                }
                // otherwise push incremented trait
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
        //add the non-mutated form to the mutants model
        var mutantData = {}
        var _mutantTraits = []
        mutantData["isMutator"] = false;
        mutantData["traits"] = traits.slice();
        _mutantsModel.push( mutantData );

        //add all possible mutated forms
        for ( i=0; i<validTraits.length; i++ ){
            for ( var j=0; j<validTraits[i].length; j++ ){
                _mutantTraits = traits.slice();
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
