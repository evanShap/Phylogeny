import QtQuick 2.0
import "../Elements"
Item{
    id: root

    width: creepView.width
    height: creepView.height

    property int nTentacles: 0
    property int nSides: 0
    property bool isEndCreep: false
    property variant mutantsModel: generateMutantsModel()
    property bool active: true
    property variant leadTethers: []

    Behavior on x { NumberAnimation{ duration: .9 * animateInterval } }
    Behavior on y { NumberAnimation{ duration: .9 * animateInterval } }

    signal addMutantSignal( variant mutant )

    CreepView{
        id: creepView
        anchors.centerIn: parent
        nTentacles: root.nTentacles
        nSides: root.nSides
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
                nTentacles: mutantsModel[index].nTentacles
                nSides: mutantsModel[index].nSides
                x: 100*index + 50 - width/2
                y: 50 - height/2
                scale: .75
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
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XandYAxis
        onClicked: if(active) toggleState()
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: stage.width - width
        drag.maximumY: stage.height - height
    }

    transitions:[
        Transition {
            to: "mutants"
            ScriptAction{ script: mutantDrawer.visible = true }
            NumberAnimation { target: mutantDrawer; property: "opacity"; duration: 250; to: 1; easing.type: Easing.InOutQuad }
        },
        Transition {
            from: "mutants"
            NumberAnimation { target: mutantDrawer; property: "opacity"; duration: 250; to: 0; easing.type: Easing.InOutQuad }
            ScriptAction{ script: mutantDrawer.visible = false }
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

    function generateMutantsModel(){
        var _mutantsModel = new Array()
        var validTentacles = new Array()
        var validSides = new Array()
        if( nTentacles <= 0 ) validTentacles.push( 1 );
        else if( nTentacles >= 9 ) validTentacles.push( 8 );
        else{
            validTentacles.push( nTentacles -1 );
            validTentacles.push( nTentacles +1 );
        }
        if( nSides <= 3 ) validSides.push( 4 );
        else if( nSides >= 7 ) validSides.push( 6 );
        else{
            validSides.push( nSides -1 );
            validSides.push( nSides +1 );
        }
        for( var i=0; i<validTentacles.length; i++ ){
            var mutantData = {}
            mutantData["nTentacles"] = validTentacles[i];
            mutantData["nSides"] = nSides;
            _mutantsModel.push( mutantData );
        }
        for( var i=0; i<validSides.length; i++ ){
            var mutantData = {}
            mutantData["nTentacles"] = nTentacles;
            mutantData["nSides"] = validSides[i];
            _mutantsModel.push( mutantData );
        }
        return _mutantsModel;
    }
}
