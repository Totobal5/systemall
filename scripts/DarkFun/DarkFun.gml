global._DARK_COMMANDS = ds_map_create();

#macro DARK global._DARK_COMMANDS
#macro DARK_FUN function(caster, targets, extra)

/// @param {string} key
/// @param {__dark_class_spell} dark_id
/// @returns {__dark_class_spell}
function dark_add(_key, _dark_id) {
    if (!dark_exists(_key) ) {
        ds_map_add(DARK, _key, _dark_id.SetInformation(_key) );
    } 
    
    return DARK[? _key];
}

/// @param {string} dark_subtype
/// @param consume
/// @param include?
/// @param targets
/// @param {string} dark_key
/// @returns {__dark_class_spell}
function dark_create_spell(_subtype = "", _consume = 0, _include = true, _target = 1, _key = "") {
    return (new __dark_class_spell(_subtype, _consume, _include, _target, _key) );
}

/// @param {string} state_type
/// @param start_value
/// @param end_value
/// @param aument_value
/// @param turns_min
/// @param turns_max
/// @param {string} effect_name
/// @returns {__dark_class_effect}
function dark_create_effect(_type, _start, _end, _aument, _turnsmin, _turnsmax, _name) {
    return (new __dark_class_effect(_type, _start, _end, _aument, _turnsmin, _turnsmax, _name) );
}

/// @param key
/// @returns {__dark_class_spell}
function dark_get(_key) {
    return (DARK[? _key] );
}

/// @param key
/// @returns {bool}
function dark_exists(_key) {
    return (ds_map_exists(DARK, _key) );
}

/// @desc Con este codigo se crean todos los hechizos
function dark_init() {
    dark_add("DARK.BATTLE.ATACK" , dark_create_spell("Ataque").SetSpell(DARK_FUN {
        var _cstat = caster .stats_final;
        var _tstat = targets.stats_final;
        
        // extra = {base, slot};
        var base = extra.base;
        var slot = extra.slot;
        
        var _nm1 = "fue", _nm2 = "def";
        
        #region Esto ya es personalizado a lo que YO quiero realizar con mis estados, estadisticas, etc (lol lmao)
		// -- Caster
		var _clvl = caster.stats.lvl;				
		var _cfue =	caster.StatAffect (_nm1, _cstat.Get(_nm1) );
			
		// -- Target	
		var _tlvl = targets.stats.lvl;
		var _tdef = targets.StatAffect(_nm2, _tstat.Get(_nm2) );

        var atack  = (base / 8) * (_cfue * 2 + (_clvl * .3) );
		var damage = (atack * base) / (_tdef + _tlvl * 2);
        
		// Aplicar daño
		targets.StatUse("ps", round(damage) );
        
		// Si el arma posee un efecto especial aplicarlo
		if (_tstat.Get("ps") > 0) {
			var _equip = caster.equip;
			
		    if (_equip.IsOccupied(slot) ) {
		    
		    
		    
		    }
		}

		return [
		    damage, 
		    _tstat.Get("ps"),
        ];

        #endregion
    }));
    
    dark_add("DARK.BATTLE.OBJECT", dark_create_spell("Objeto") );
    
    dark_add("DARK.WSPELL.HEAL1" , (dark_create_spell("Blanca", 30, true) ).SetSpell(DARK_FUN {
        show_debug_message("DARK SPELL PRUEBA!");    
    }));
    
    dark_add("DARK.GSPELL.BASIC" , (dark_create_spell("Verde") ).SetSpell(DARK_FUN {
    	var _porcent = extra.porcent;
    	var _state   = extra.state;
    	var _msj     = extra.msj;
    	
    	var state  = (mall_get_stat(_state) );
    	
    	var _txt = state.GetTxt(), _proccess = state.GetProcesses()[$ "reduce"];
    	
    	var _start  = _proccess[0];	// Valor inicial
    	var _end    = _proccess[1];	// Valor final
		var _aument = _proccess[2]; // Cuanto aumenta el valor actual cada iteracion
		var _iter = _proccess[3];	// Cada cuantos turnos aumenta el valor
		
		var _turnmin = _proccess[4];
		var _turnmax = _proccess[5];
		
		/*    	
		  	->	start : 20%
			->	end   : 40%
			->	aument: 5%
			->	iter  : 2
			->  turnmin: 3
			->  turnmax: 8
		*/  
    	
    	var _effect  = (dark_create_effect(_state, _start, _end, _aument, _turnmin, _turnmax, _txt) );
    	var _control = targets.control; 
    	
    	_control.AddControl("state", _effect);
    	
    	return _msj[0];
    }) );
    
}