import QtQuick 2.0
import "Elements"
Flickable {
    id: stage
    width: 1024
    height: 768
    contentHeight: Math.max( stage.height , (currentLevel + 2) * levelSpacing )
    Behavior on contentHeight { NumberAnimation{ duration: 150 } }
    boundsBehavior: Flickable.StopAtBounds

    property int animateInterval: 75
    property variant tethers: []
    property variant traitDataModel: traitDataModel
    property int totalTraits: traitDataModel.count
    property real levelSpacing: 120
    property int currentLevel: 0
    property int totalMutations: 0
    property int activeColumns: creepModels.length
    property real activeColumnSpacing: stage.width / activeColumns

    ListModel{
        id: traitDataModel
        ListElement{min: 0; max: 6; loops: false} //tentacles
        ListElement{min: 0; max: 4; loops: false} //lines
        ListElement{min: 0; max: 4; loops: false} //color
    }
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
    Rectangle{
        id: background
        anchors.fill: parent
        color: "#282828"
    }

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
                var upperX = tethers[i].lead.x + tethers[i].lead.width/2;
                var upperY = tethers[i].lead.y  + tethers[i].lead.height/2 + contentOffsetY;
                var lowerX = tethers[i].follow.x + tethers[i].follow.width/2;
                var lowerY = tethers[i].follow.y  + tethers[i].follow.height/2 + contentOffsetY;
                ctx.beginPath();
                ctx.moveTo( upperX , upperY );
                ctx.bezierCurveTo( upperX, upperY + levelSpacing/2, lowerX, lowerY - levelSpacing/2, lowerX , lowerY );
                ctx.stroke();
            }
            ctx.lineWidth = 13;
            for( var i=0; i<tethers.length; i++ ){
                upperX = tethers[i].lead.x + tethers[i].lead.width/2;
                upperY = tethers[i].lead.y  + tethers[i].lead.height/2  + contentOffsetY;
                lowerX = tethers[i].follow.x + tethers[i].follow.width/2;
                lowerY = tethers[i].follow.y  + tethers[i].follow.height/2  + contentOffsetY;
                ctx.strokeStyle = tethers[i].follow.isMutant ? Qt.rgba(.4, 0, 0, .7) : Qt.rgba( .15, .15, .15, 1);
                ctx.beginPath();
                ctx.moveTo( upperX , upperY );
                ctx.bezierCurveTo( upperX, upperY + levelSpacing/2, lowerX, lowerY - levelSpacing/2, lowerX , lowerY );
                ctx.stroke();
            }
        }
        onPainted: {requestPaint()}
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
            }
        }
    }

    Text{
        id: genText
        text: "GENERATIONS " + currentLevel
        color: "#B0D0D0"
        font.pointSize: 30
        font.family: "Courier"
        font.weight: Font.Black
        x: 20; y: 20
    }
    Text{
        id: mutText
        text: "MUTATIONS " + totalMutations
        color: "#B0D0D0"
        font.pointSize: 30
        font.family: "Courier"
        font.weight: Font.Black
        anchors { top: genText.bottom; left: genText.left }
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
//        _nextTether[""]  TODO : add tether length values?
        _tethers.push( _nextTether );
        tethers = _tethers;
    }

    // update x positions of creeps based on tether physics
    function updateTethers(){
        for( var i=0; i<tethers.length; i++ ){
            var followCreep = tethers[i].follow;
            var leadCreep = tethers[i].lead;
            var dist = ( leadCreep.x - followCreep.x + followCreep.prefXOffset );
            if ( Math.abs( dist ) > 5 ){
                if( !followCreep.isDragging ) followCreep.x += (dist) ;
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
                if( chainRepeater.itemAt(i).creepsInChain !== chainRepeater.itemAt(j).creepsInChain ){}
                else if( creep1 == creep2 ){}
                else if( creep1.isBranchPoint || creep2.isBranchPoint ){}
                else if(!creep1.active || !creep2.active){}
                else if( haveSameTraits( chainRepeater.itemAt(i).begCreepData.traits , chainRepeater.itemAt(j).begCreepData.traits ))
                    mergeChains( chainRepeater.itemAt(i) , chainRepeater.itemAt(j) );
            }
        }
    }
    // return true of 2 creep models have the same traits
    function haveSameTraits( creepModel1 , creepModel2 ){
        if( creepModel1.length !== creepModel2.length ) return false;
        for ( var i=0; i<creepModel1.length; i++ ){
            if( creepModel1[i] !== creepModel2[i]) return false;
        }        
        return true;
    }

    // attaches chain 1 to head of chain 2, kills head of chain 1
    function mergeChains( chain1 , chain2 ){
        var leadCreep1 = chain1.begCreepItem;
        var leadCreep2 = chain2.begCreepItem;
        if( leadCreep1.isEndCreep ) leadCreep2.isEndCreep = true;
        else if( leadCreep2.isEndCreep ) leadCreep1.isEndCreep = true;
        chain2.branchesInChain ++;
        chain1.branchesInChain ++;
        if(leadCreep1.leadTethers.length > 0){
            var _tethers = tethers;
            for( var i=0; i<leadCreep1.leadTethers.length; i++){
                _tethers[leadCreep1.leadTethers[i]].lead = leadCreep2;
                _tethers[leadCreep1.leadTethers[i]].follow.prefXOffset = .375* activeColumnSpacing * chain1.branchesInChain;
            }
            for( var i=0; i<leadCreep2.leadTethers.length; i++){
                _tethers[leadCreep2.leadTethers[i]].follow.prefXOffset = - .375* activeColumnSpacing * chain2.branchesInChain;
            }
            tethers = _tethers;
        }
        chain2.branchesInChain += ( chain1.branchesInChain - 1 )
        leadCreep2.isBranchPoint = true;
        leadCreep2.x = .5 * ( leadCreep1.x + leadCreep2.x )
        leadCreep1.kill();
    }

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
