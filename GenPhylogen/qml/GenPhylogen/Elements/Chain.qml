import QtQuick 2.0
import "CreepSpawner.js" as CreepSpawner

Item {
    id: root
    property variant creepTraits: []
    property variant endCreepData
    property variant begCreepData: creepTraits[ creepTraits.length - 1 ]
    property variant begCreepItem: CreepSpawner.creepItems[ CreepSpawner.creepItems.length - 1 ]

    signal addTetherSignal( variant tetherLead, variant tetherFollow )
    signal checkForAncestorSignal()

    Component.onCompleted: {
        var _creepTraits = new Array(1);
        _creepTraits[0] = {};
        _creepTraits[0]["nTentacles"] = endCreepData.nTentacles;
        _creepTraits[0]["nSides"] = endCreepData.nSides;
        _creepTraits[0]["x"] = endCreepData.x;
        _creepTraits[0]["y"] = endCreepData.y;
        _creepTraits[0]["isEndCreep"] = true;
        creepTraits = _creepTraits
        CreepSpawner.spawnCreep( creepTraits[0] );
    }

    function addCreep( mutant ){
        var _creepTraits = creepTraits;
        for( var i=0; i<_creepTraits.length; i++ ){
            _creepTraits[ i ].x = CreepSpawner.creepItems[i].x;
            _creepTraits[ i ].y = CreepSpawner.creepItems[i].y;
        }
        _creepTraits.push( mutant );
        CreepSpawner.spawnCreep( mutant );
        creepTraits = _creepTraits;
        checkForAncestorSignal();
    }
}
