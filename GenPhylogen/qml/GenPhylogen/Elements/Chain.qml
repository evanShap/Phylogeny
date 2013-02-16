import QtQuick 2.0
import "CreepSpawner.js" as CreepSpawner

Item {
    id: root
    property variant creepTraits: [0]
    property int creepsInChain: creepTraits.length
    onCreepsInChainChanged: updateCurrentLevelSignal()
    property variant endCreepData
    property variant begCreepData: creepTraits[ creepTraits.length - 1 ]
    property variant begCreepItem: CreepSpawner.creepItems[ CreepSpawner.creepItems.length - 1 ]
    property int columnIndex: 0
    property int branchesInChain: 0

    signal addTetherSignal( variant tetherLead, variant tetherFollow )
    signal checkForAncestorSignal()
    signal updateCurrentLevelSignal()

    Component.onCompleted: {
        // bs to allow dynamic manipulation of qml variant array element
        var _creepTraits = creepTraits;
        _creepTraits[0] = {};
        //
        _creepTraits[0]["nTentacles"] = endCreepData.nTentacles;
        _creepTraits[0]["nSides"] = endCreepData.nSides;
        _creepTraits[0]["x"] = stage.width / activeColumns * ( columnIndex + .5 );
        _creepTraits[0]["y"] = stage.height - ( creepsInChain ) * levelSpacing;
        _creepTraits[0]["isEndCreep"] = true;        
        creepTraits = _creepTraits
        CreepSpawner.spawnCreep( creepTraits[0] );
    }

    function addCreep( mutant ){
        // bs to allow dynamic manipulation of qml variant array element
        var _creepTraits = creepTraits;
        _creepTraits.push( mutant );
        creepTraits = _creepTraits;
        //
        _creepTraits[ _creepTraits.length-1 ].x =begCreepItem.x
        _creepTraits[ _creepTraits.length-1 ].y = stage.height - ( creepsInChain ) * levelSpacing;
        CreepSpawner.spawnCreep( mutant );        
        checkForAncestorSignal();
    }
}
