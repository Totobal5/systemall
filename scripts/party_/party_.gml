/// @param group_key
/// @param level
function party_create_player1(_group, _lvl = 1) {
	if (_group == undefined) _group = MALL_GROUP.__key;

    // Evitar niveles negativos
    if (_lvl < 1) _lvl = 1;
    
    var _name = "Player_1";
    
    // Crear componentes
    var _stats = new PartyStats(_group, _lvl);
    var _parts = new PartyParts(_group, _stats);
    
    var _control = new PartyControl(_group, false, true, _stats, _parts);
               
    _stats.SetBase("PS", 15, "PM", 15, "EXP", 25);
    _stats.SetBase("FUE", 51, "INT", 51, "DEF", 60, "ESP", 60);
            
    _stats.SetBase("FIRE.ATK", 51, "AQUA.ATK", 100, "WIND.ATK", 25, "EART.ATK", 25);
    
    _stats.SetCondition(function() {
        var _exp = Get("EXP");
        
        return (_exp.actual >= _exp.upper);
    });
    
    _stats.LevelUp(,true);
    
    var _entity = new PartyEntity("Jugador 1", _stats, _control, _parts);

    // Equipar arma
    _parts.Equip("MANO", "ESPADA.HIERRO");
    _stats.Print(); // Mostrar valores
	
	party_add(_name, _entity);
} 


/*

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
    
    
    mall_create_elements("FIRE", ".ATK", ".RES");
mall_create_elements("AQUA", ".ATK", ".RES");
mall_create_elements("WIND", ".ATK", ".RES");
mall_create_elements("EART", ".ATK", ".RES");

// -- Estados
mall_create_states("LIFE");
mall_create_states("VEN", ".RES");
mall_create_states("SIL", ".RES");
mall_create_states("STO", ".RES");
mall_create_states("MEL", ".RES");
