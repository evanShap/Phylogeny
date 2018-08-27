import QtQuick 2.4

Flickable {
    id: stage
    contentHeight: Math.max( stage.height , (currentLevel + 2) * levelSpacing )
    Behavior on contentHeight { NumberAnimation{ duration: 150 } }
    boundsBehavior: Flickable.StopAtBounds

    property int animateInterval: 35
    property variant tethers: []
    property variant traitDataModel: [
        { 'min': 0, 'max': 6, 'loops': false }, //color
        { 'min': 0, 'max': 4, 'loops': false },
        { 'min': 0, 'max': 4, 'loops': false }
    ]
    property int totalTraits: traitDataModel.length
    property real levelSpacing: 120
    property int currentLevel: 0
    property int totalMutations: 0
    property int activeColumns: creepModels.length
    property real activeColumnSpacing: stage.width / activeColumns

    property variant creepModels:[
        [ 0 , 3 , 0 ],
        [ 3 , 3 , 1 ],
        [ 2 , 0 , 2 ],
        [ 3 , 2 , 3 ],
        [ 3 , 1 , 4 ],
        [ 3 , 0 , 3 ],
        [ 3 , 1 , 3 ],
        [ 3 , 3 , 3 ],
    ]

    Canvas{
        id: tetherCanvas
        smooth: true; antialiasing: true;
        width: stage.width
        height: stage.height
        y: contentY
        property real contentOffsetY: contentHeight - stage.height - y;
        onPaint: {
            var ctx = tetherCanvas.getContext('2d');
            ctx.clearRect(0, 0, tetherCanvas.width, tetherCanvas.height);

            ctx.lineCap = "straight";
            ctx.lineJoin = "round";
            ctx.lineWidth = 17;
            ctx.strokeStyle = Qt.rgba( .8, .8, .8, .85);
            for( var i=0; i<tethers.length; i++ ){
                if( !tethers[i].lead || !tethers[i].follow ) continue;
                var upperX = tethers[i].lead.x + tethers[i].lead.width/2;
                var upperY = tethers[i].lead.y  + tethers[i].lead.height/2 + contentOffsetY;
                var lowerX = tethers[i].follow.x + tethers[i].follow.width/2;
                var lowerY = tethers[i].follow.y  + tethers[i].follow.height/2 + contentOffsetY;
                ctx.beginPath();
                ctx.moveTo( upperX , upperY );
                ctx.bezierCurveTo( upperX, upperY + levelSpacing/2, lowerX, upperY + levelSpacing/2, lowerX , lowerY );
                ctx.stroke();
            }
            ctx.lineWidth = 13;
            for( var i=0; i<tethers.length; i++ ){
                if( !tethers[i].lead || !tethers[i].follow ) continue;
                upperX = tethers[i].lead.x + tethers[i].lead.width/2;
                upperY = tethers[i].lead.y  + tethers[i].lead.height/2  + contentOffsetY;
                lowerX = tethers[i].follow.x + tethers[i].follow.width/2;
                lowerY = tethers[i].follow.y  + tethers[i].follow.height/2  + contentOffsetY;
                ctx.strokeStyle = tethers[i].follow.isMutant ? Qt.rgba(.4, 0, 0, .7) : Qt.rgba( .15, .15, .15, 1);
                ctx.beginPath();
                ctx.moveTo( upperX , upperY );
                ctx.bezierCurveTo( upperX, upperY + levelSpacing/2, lowerX, upperY + levelSpacing/2, lowerX , lowerY );
                ctx.stroke();
            }
        }
    }

    Repeater{
        id: chainRepeater
        model: creepModels
        anchors.fill: parent
        delegate:Chain{
            columnIndex: index
            endCreepData: creepModels[ index ]
            Component.onCompleted: {
                addTetherSignal.connect( stage.addTetherHandler )
                checkForAncestorSignal.connect( stage.checkForAncestor )
                updateCurrentLevelSignal.connect( stage.updateCurrentLevel )
                killCreepSignal.connect( stage.killCreepHandler )
            }
        }
    }

    Timer{
        id: animationTimer
        interval: animateInterval
        running: true
        repeat: true
        onTriggered: {
            updateTethers();
            tetherCanvas.requestPaint();
        }
    }

    function distanceBetween( obj1 , obj2 ){
        return Math.sqrt( (obj1.x - obj2.x )*(obj1.x - obj2.x ) + (obj1.y - obj2.y )*(obj1.y - obj2.y ));
    }

    function addTetherHandler( tetherLead , tetherFollow ){
        var _tethers = tethers.slice();
        var _nextTether = {};
        var leadIndices = tetherLead.leadTethers.slice()
        leadIndices.push( _tethers.length )
        tetherLead.leadTethers = leadIndices;
        _nextTether["lead"] = tetherLead;
        _nextTether["follow"] = tetherFollow;
        //        _nextTether[""]  TODO : add tether length values?
        _tethers.push( _nextTether );
        tethers = _tethers;
    }

    // update x positions of creeps based on tether physics
    function updateTethers(){
        for( var i=0; i<tethers.length; i++ ){
            if( !tethers[i].lead || !tethers[i].follow ) continue;
            var followCreep = tethers[i].follow;
            var leadCreep = tethers[i].lead;
            var dist = ( leadCreep.x - followCreep.x + followCreep.prefXOffset );
            if ( Math.abs( dist ) > 5 ){
                if( !followCreep.isDragging ) followCreep.x += (dist) ;
            }
        }
    }

    function checkForAncestor(){
        var creep1, creep2
        console.log("Chains", chainRepeater.count)
        for( var i=0; i<chainRepeater.count; i++ ){
            for( var j=0; j<i; j++){
                creep1 = chainRepeater.itemAt(i).begCreepItem;
                creep2 = chainRepeater.itemAt(j).begCreepItem;
                if( !creep1 || !creep2 ) continue;
                if( creep1 == creep2 ) continue;
                if( creep1.isBranchPoint || creep2.isBranchPoint ) continue;
                if(!creep1.active || !creep2.active) continue;
                console.log("creep1",i,creep1.traits)
                console.log("creep2",j,creep2.traits)
                if( haveSameTraits( chainRepeater.itemAt(i).begCreepData.traits , chainRepeater.itemAt(j).begCreepData.traits )){
                    mergeChains( chainRepeater.itemAt(i) , chainRepeater.itemAt(j) );
                }
            }
        }
    }
    // return true if 2 creep models have the same traits
    function haveSameTraits( creepModel1 , creepModel2 ){
        if( creepModel1.length !== creepModel2.length ) return false;
        for ( var i=0; i<creepModel1.length; i++ ){
            if( creepModel1[i] !== creepModel2[i]) return false;
        }
        return true;
    }

    // attaches chain 1 to head of chain 2, kills head of chain 1
    function mergeChains( chain1 , chain2 ){
        var leadChain = ( chain1.creepsInChain > chain2.creepsInChain ) ? chain1 : chain2;
        var replaceChain = ( chain1.creepsInChain > chain2.creepsInChain ) ? chain2 : chain1;
        var replaceCreep = replaceChain.begCreepItem;
        var leadCreep = leadChain.begCreepItem;
        leadChain.branchesInChain ++;
        replaceChain.branchesInChain ++;

        var _tethers = tethers.slice();

        for( var i=0; i<leadCreep.leadTethers.length; i++){
            if(leadCreep.x < replaceCreep.x)
                _tethers[leadCreep.leadTethers[i]].follow.prefXOffset = - .375* activeColumnSpacing * leadChain.branchesInChain;
            else
                _tethers[leadCreep.leadTethers[i]].follow.prefXOffset = .375* activeColumnSpacing * leadChain.branchesInChain;
        }

        var _leadTethers = leadCreep.leadTethers.slice();

        for( i=0; i<replaceCreep.leadTethers.length; i++ ){
            _tethers[replaceCreep.leadTethers[i]].lead = leadCreep;
            if(leadCreep.x < replaceCreep.x)
                _tethers[replaceCreep.leadTethers[i]].follow.prefXOffset = .375* activeColumnSpacing * replaceChain.branchesInChain;
            else
                _tethers[replaceCreep.leadTethers[i]].follow.prefXOffset = - .375* activeColumnSpacing * replaceChain.branchesInChain;
            _leadTethers.push( replaceCreep.leadTethers[i] );
        }
        leadCreep.leadTethers = _leadTethers;
        tethers = _tethers;

        leadChain.branchesInChain += ( replaceChain.branchesInChain - 1 )
        leadCreep.isBranchPoint = true;
        leadCreep.branchChain = replaceChain;
        leadCreep.x = .5 * ( replaceCreep.x + leadCreep.x )
        if( !replaceCreep.isEndCreep ){
            var _creepDataReplace = replaceChain.creepData
            _creepDataReplace.pop();
            replaceChain.creepData = _creepDataReplace;
            replaceChain.popCreep();
            replaceCreep.kill();
            replaceCreep.destroy();
        }
        else{
            addTetherHandler( leadCreep , replaceCreep );
            replaceCreep.deactivate();
            if( replaceCreep.x < leadCreep.x) replaceCreep.prefXOffset = - .375* activeColumnSpacing;
            else replaceCreep.prefXOffset = + .375* activeColumnSpacing;
        }
    }

    function killCreepHandler( creep ){
        var _tethers = tethers.slice();
        var _creepData = creep.parentChain.creepData;

        for ( var i=0; i<creep.leadTethers.length; i++ ){
            _tethers[creep.leadTethers[i]].lead = undefined;
            _tethers[creep.leadTethers[i]].follow = undefined;
        }
        tethers = _tethers;
        _creepData.pop();
        creep.parentChain.creepData = _creepData;
        creep.parentChain.popCreep();
        if( creep.parentChain.begCreepItem.isMutant ){
            creep.parentChain.begCreepItem.isMutant = false;
            totalMutations--;
        }
        creep.parentChain.begCreepItem.activate();
        creep.parentChain.begCreepItem.prefXOffset = 0;
        creep.parentChain.branchesInChain--;
        if( creep.isBranchPoint ){
            creep.isBranchPoint = false;
            creep.branchChain.begCreepItem.activate();
            creep.branchChain.begCreepItem.prefXOffset = 0;
            creep.branchChain.branchesInChain--;
        }
        creep.kill();
        creep.destroy();
    }

    // updates the generation tracker
    function updateCurrentLevel(){
        var _currentLevel = 0;
        for ( var i=0; i<creepModels.length; i++ ){
            if( !chainRepeater.itemAt(i) ) return 0;
            if( chainRepeater.itemAt(i).creepsInChain - 1 > _currentLevel)
                _currentLevel = chainRepeater.itemAt(i).creepsInChain - 1;
        }
        currentLevel =  _currentLevel;
    }
}
