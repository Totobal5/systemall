global._GROUP_PLAYER = [];

#macro GROUP global._GROUP_PLAYER

/// @param {group_create} group_id
function group_add(_group) {
    if (group_search(_group.GetName() ) == noone) { 
        array_push(GROUP, _group);
    }
}

/// @param {group_create} group_id
/// @param insert_pos
function group_insert(_group, _insert) {
    array_insert(GROUP, _insert, _group);
    return _group;
}

/// @param {number} index
function group_get(_index) {
    return (GROUP[_index] );
}

/// @returns {number}
function group_length() {
    return (array_length(GROUP) );
}

/// @param access
/// @returns {group_create} Deleted
function group_delete(_access) {
    var _search = group_search(_access);
    
    if (is_string(_access) ) {
        var _search = group_search(_access, true);
        
        array_delete(GROUP, _search[1], 1);
        
        return _search[0];
    } else {
        var _search = group_get(_access);
        array_delete(GROUP, _access, 1);
        
        return _search;
    }
}

/// @param group_name
/// @param return_pos?
function group_search(_name, _both = false) {
    var i = 0; repeat(group_get() ) {
        var _found = group_get(i);
        
        if (_found.GetName() == _name) return (_both) ? [_found, i] : _found;
        ++i;
    }   
    
    return (noone);
}

/// @param group_name
function group_search_index(_name) {
    var i = 0; repeat(group_get() ) {
        var _found = group_get(i);
        
        if (_found.GetName() == _name) return i;
        ++i;
    }   
    
    return i;
}

/// @param select_pos
/// @param new_pos
/// @desc Mueve de posicion en el grupo
function group_move(_selectpos, _newpos) {
    var _val = group_get(_selectpos);
    
    group_delete(_selectpos);
    group_insert(_val, _newpos);
}

/// @param level
/// @returns {group_create}
function group_create_player1(_lvl = 1) {
    gc_collect();
    
    var _stats = (new __group_class_stats(_lvl) ).
    SetBase("ps_max", 15, "pm_max", 15, "exp_max", 25).
    SetBase("fue"   , 51, "int"   , 51, "def"    , 51, "esp", 51, "vel", 51).
    SetBase("fuego_atak", 51, "polucion_atak", 51).
    SetBase(       
        "fuego_rest"     , Data("0%"),
        "polucion_rest"  , Data("0%"),
        
        "vivo_rest"      , Data("0%") ,
        "veneno_rest"    , Data("0%") ,
        "quemadura_rest" , Data("0%") ,
        "melancolia_rest", Data("0%")
    );

    _stats.SetLevelInit(function(context) {
        var _exp = context.Get("exp"), _exp_max = context.Get("exp_max");      
        
        return (_exp >= _exp_max);
    });
    _stats.SetLevelEnd (function(context) {});
    _stats.LevelUp(_lvl, true);
    
    var _control = (new __group_class_control(false, true) );
    
    var _equip = (new __group_class_equip() );
    _equip.SetCapable("Mano der.", ["Espadas", "Arcos", "Escudos"]);
    _equip.SetCapable("Mano izq.", ["Espadas"] );
    
    var _psj = (new group_create("Player1", _stats, _control, _equip) );
    
    group_add(_psj);
    
    return (_psj );
}

///
function group_update_position(_posmethod) {
    if (_posmethod == undefined) _posmethod = function(vec2, i) {
        switch (group_get_count() ) {
            case 1: vec2.SetXY(320, 240); break;
        }
    }
    
    var i = 0; repeat(group_length() ) {
        var group = group_get(i); /// @is {group_create}
        
        _posmethod(group.render_pos, i);
        
        ++i;
    }    
}


#region Plantillas

/// @param level
/// @returns {group_create}
function group_create_player2(_lvl = 1) {
    gc_collect();
    
    var _stats = (new __group_class_stats(_lvl) ).
    SetBase("ps_max", 15, "pm_max", 15, "exp_max", 25).
    SetBase("fue"   , 51, "int"   , 51, "def"    , 51, "esp", 51, "vel", 51).
    SetBase("fuego_atak", 51, "polucion_atak", 51).
    SetBase(       
        "fuego_rest"     , Data("0%"),
        "polucion_rest"  , Data("0%"),
        
        "vivo_rest"      , Data("0%")  ,
        "veneno_rest"    , Data("25%") ,
        "quemadura_rest" , Data("25%") ,
        "melancolia_rest", Data("25%")
    );

    _stats.SetLevelInit(function(context) {
        var _exp = context.Get("exp"), _exp_max = context.Get("exp_max");      
        
        return (_exp >= _exp_max);
    });
    _stats.SetLevelEnd (function(context) {});
    _stats.LevelUp(_lvl, true);

    var _control = (new __group_class_control(false, true) );
    
    var _equip = (new __group_class_equip() );
    _equip.SetCapable("Mano der.", ["Espadas", "Arcos", "Escudos"]);
    _equip.SetCapable("Mano izq.", ["Espadas"] );
    _equip.Link("Mano der.", "Mano izq.");
    _equip.Link("Mano izq.", "Mano der."); 
    
    var _psj = (new group_create("Player2", _stats, _control, _equip) );
    
    group_add(_psj);
    
    return (_psj );
}

function group_create_enemyparent(_lvl = 1, _customgroup = WATE_GROUPS.ENEMS, _customname = "generic") {
    gc_collect();
    
    var _stats = (new __group_class_stats(_lvl) ).
    SetBase("ps_max", 15, "pm_max", 15, "exp_max", 25).
    SetBase("fue"   , 51, "int"   , 51, "def"    , 51, "esp", 51, "vel", 51).
    SetBase("fuego_atak", 51, "polucion_atak", 51).
    SetBase(       
        "fuego_rest"     , Data("0%"),
        "polucion_rest"  , Data("0%"),
        
        "vivo_rest"      , Data("0%")  ,
        "veneno_rest"    , Data("25%") ,
        "quemadura_rest" , Data("25%") ,
        "melancolia_rest", Data("25%")
    );
    
    _stats.SetLevelInit(function(context) {
        var _exp = context.Get("exp"), _exp_max = context.Get("exp_max");      
        
        return (_exp >= _exp_max);        
    });
    
    _stats.SetLevelEnd (function(context) {});
    _stats.LevelUp(_lvl, true);

    var _control = (new __group_class_control(false, true) );
    
    var _equip = (new __group_class_equip() );
    _equip.SetCapable("Mano der.", ["Espadas", "Arcos", "Escudos"]);
    _equip.SetCapable("Mano izq.", ["Espadas"] );
    _equip.Link("Mano der.", "Mano izq.");
    _equip.Link("Mano izq.", "Mano der."); 
    
    var _psj = (new group_create(_customname, _stats, _control, _equip) );
    _psj.EquipPut   ("Mano der.", "ARM.ESPADA_VENENO");
    _psj.BattleGroup(_customgroup);
    
    
    return _psj;    
}


#endregion