import QtQuick 2.4
import "CreepSpawner.js" as CreepSpawner

Item {
    id: root
//    color: "#40ffffff"
    width: stage.width
    height: stage.height
    anchors { bottom: parent.bottom }
    property variant creepData: [0]
    property int creepsInChain: creepData.length
    onCreepsInChainChanged: updateCurrentLevelSignal();
    property variant endCreepData
    property variant begCreepData: creepData[ creepData.length - 1 ]    
    property variant begCreepItem: CreepSpawner.creepItems[ CreepSpawner.creepItems.length - 1 ]
    property int columnIndex: 0
    property int branchesInChain: 0

    signal addTetherSignal( variant tetherLead, variant tetherFollow )
    signal killCreepSignal( variant creep )
    signal checkForAncestorSignal()
    signal updateCurrentLevelSignal()

    Component.onCompleted: {
        // bs to allow dynamic manipulation of qml variant array element
        var _creepData = creepData;
        _creepData[0] = {};
        //
        _creepData[0]["traits"] = endCreepData;
        _creepData[0]["x"] = stage.width / activeColumns * ( columnIndex ) + 37;
        _creepData[0]["y"] = stage.height - ( creepsInChain ) * levelSpacing - 20;
        _creepData[0]["isEndCreep"] = true;
        creepData = _creepData
        CreepSpawner.spawnCreep( creepData[0] );
    }

    function addCreep( mutant ){
        // bs to allow dynamic manipulation of qml variant array element
        var _creepData = creepData;
        _creepData.push( mutant );
        creepData = _creepData;
        //
        _creepData[ _creepData.length-1 ].x = begCreepItem.x
        _creepData[ _creepData.length-1 ].y = begCreepItem.y - levelSpacing;
        CreepSpawner.spawnCreep( mutant );        
        checkForAncestorSignal();
    }

    function popCreep(){
        CreepSpawner.popCreep();
    }
}
