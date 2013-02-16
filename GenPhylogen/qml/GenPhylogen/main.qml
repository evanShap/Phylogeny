import QtQuick 2.0
import "Elements"
Rectangle {
    id: stage
    width: 1024
    height: 768
    color: "#181818"

    property int animateInterval: 75
    property variant tethers: []
    property variant creepModels: creepModels
    property real levelSpacing: 120
    property int currentLevel: 0

    property int activeColumns: creepModels.count
    property real activeColumnSpacing: stage.width / activeColumns

    ListModel{
        id: creepModels
        ListElement{nTentacles: 3; nSides: 3}//; x: 300; y: 200}
        ListElement{nTentacles: 5; nSides: 4}//; x: 700; y: 500}
        ListElement{nTentacles: 7; nSides: 5}//; x: 200; y: 600}
    }

    Canvas{
        id: tetherCanvas
        smooth: true; antialiasing: true;
        anchors.fill: parent
        onPaint: {
            var ctx = tetherCanvas.getContext('2d');
            ctx.clearRect(0, 0, tetherCanvas.width, tetherCanvas.height);

            ctx.lineCap = "straight";
            ctx.lineJoin = "round";
            ctx.lineWidth = 6;

            for( var i=0; i<tethers.length; i++ ){
                ctx.strokeStyle = tethers[i].follow.isMutant ? Qt.rgba(.94, 0, 0, .4) : Qt.rgba(.63, .94, .88, .4);
                ctx.beginPath();
                ctx.moveTo( tethers[i].lead.x + tethers[i].lead.width/2 , tethers[i].lead.y  + tethers[i].lead.height/2 );
                ctx.lineTo( tethers[i].follow.x + tethers[i].follow.width/2 , tethers[i].follow.y  + tethers[i].follow.height/2 );
                ctx.stroke();
            }
        }
        onPainted: {requestPaint()}
    }

    Repeater{
        id: chainRepeater
        model: creepModels
        delegate:Chain{
            columnIndex: index
            endCreepData: model
            Component.onCompleted: {
                addTetherSignal.connect( stage.addTetherHandler )
                checkForAncestorSignal.connect( stage.checkForAncestor )
                updateCurrentLevelSignal.connect( stage.updateCurrentLevel )
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
        }
    }

    function distanceBetween( obj1 , obj2 ){
        return Math.sqrt( (obj1.x - obj2.x )*(obj1.x - obj2.x ) + (obj1.y - obj2.y )*(obj1.y - obj2.y ));
    }

    function addTetherHandler( tetherLead , tetherFollow ){
        var _tethers = tethers;
        var _nextTether = {};
        var leadIndices = tetherLead.leadTethers
        leadIndices.push( _tethers.length )
        tetherLead.leadTethers = leadIndices;
        _nextTether["lead"] = tetherLead;
        _nextTether["follow"] = tetherFollow;
//        _nextTether[""]
        _tethers.push( _nextTether );
        tethers = _tethers;
    }

    function updateTethers(){
        for( var i=0; i<tethers.length; i++ ){
            var followCreep = tethers[i].follow;
            var leadCreep = tethers[i].lead;
            var dist = ( leadCreep.x - followCreep.x + followCreep.prefXOffset );
            if ( Math.abs( dist ) > 5 ){
                followCreep.x += .4 * (dist);
            }
        }
    }
    function checkForAncestor(){
        var creep1
        var creep2
        for( var i=0; i<chainRepeater.count; i++ ){
            for( var j=0; j<i; j++){
                creep1 = chainRepeater.itemAt(i).begCreepItem;
                creep2 = chainRepeater.itemAt(j).begCreepItem;
                if( chainRepeater.itemAt(i).creepsInChain != chainRepeater.itemAt(j).creepsInChain ){}
                else if( creep1 == creep2 ){}
                else if(!creep1.active || !creep2.active){}
                else if( haveSameTraits( chainRepeater.itemAt(i).begCreepData , chainRepeater.itemAt(j).begCreepData ))
                    mergeChains( chainRepeater.itemAt(i) , chainRepeater.itemAt(j) );
            }
        }
    }
    function haveSameTraits( creepModel1 , creepModel2 ){
        if(creepModel1.nTentacles != creepModel2.nTentacles) return false;
        if(creepModel1.nSides != creepModel2.nSides) return false;
        console.log("**** found match! " + creepModel1.nTentacles + ", " + creepModel2.nTentacles)
        return true;
    }
    function mergeChains( chain1 , chain2 ){
        var leadCreep1 = chain1.begCreepItem;
        var leadCreep2 = chain2.begCreepItem;
        if( leadCreep1.isEndCreep ) leadCreep2.isEndCreep = true;
        else if( leadCreep2.isEndCreep ) leadCreep1.isEndCreep = true;
        if(leadCreep1.leadTethers.length > 0){
            var _tethers = tethers;
            for( var i=0; i<leadCreep1.leadTethers.length; i++){
                _tethers[leadCreep1.leadTethers[i]].lead = leadCreep2;
                _tethers[leadCreep1.leadTethers[i]].follow.prefXOffset = activeColumnSpacing / 2;
            }
            for( var i=0; i<leadCreep2.leadTethers.length; i++){
                _tethers[leadCreep2.leadTethers[i]].follow.prefXOffset = - activeColumnSpacing / 2;
            }

            tethers = _tethers;
        }
        leadCreep1.kill();
        //        chain1.begCreepItem = leadCreep2;
        //        leadCreep1.destroy();
    }

    function updateCurrentLevel(){
        var _currentLevel = 0;
        for ( var i=0; i<creepModels.count; i++ ){
            if( !chainRepeater.itemAt(i) ) return 0;
            if( chainRepeater.itemAt(i).creepsInChain - 1 > _currentLevel)
                _currentLevel = chainRepeater.itemAt(i).creepsInChain - 1;
        }
        currentLevel =  _currentLevel;
    }
}