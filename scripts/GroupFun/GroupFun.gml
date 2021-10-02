global._GROUP_PLAYER = ds_list_create();

#macro GROUP global._GROUP_PLAYER

/// @param {group_create} group_id
function group_add(_group) {
    var i = 0; repeat(group_get_count() ) {
        var in = group_get(i);
        
        if (in.name == _group.name) return in;
        
        ++i;
    }  
    
    ds_list_add(GROUP, _group);
}

/// @param {number} index
function group_get(_index) {
    return (GROUP[| _index] );
}

/// @returns {number}
function group_get_count() {
    return (ds_list_size(GROUP) );
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


function group_create_enemyparent(_lvl = 1, _customname = "generic") {
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
    _psj.EquipPut("Mano der.", "ARM.ESPADA_VENENO");
    
    return _psj;    
}