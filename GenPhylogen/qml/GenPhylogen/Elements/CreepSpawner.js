var newCreepComp
var newCreep
var creepItems = []

function spawnCreep( creepData ){
    if( creepData.isMutator ) creepItems[creepItems.length-1].isMutant = true;
    newCreepComp = Qt.createComponent("Creep.qml");
    newCreep = newCreepComp.createObject(root, {
                                             "nTentacles": creepData.nTentacles,
                                             "nSides": creepData.nSides,
                                             "x": creepData.x,
                                             "y": creepData.y,
                                             "isEndCreep": creepData.isEndCreep || false
                                         });
    newCreep.addMutantSignal.connect( addCreep );
    if(creepItems.length > 0){
        addTetherSignal( newCreep , creepItems[creepItems.length-1] );
        creepItems[creepItems.length-1].deactivate();
    }
    creepItems.push( newCreep );
    begCreepItem = creepItems[ creepItems.length - 1 ];
}


