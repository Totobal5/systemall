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


function dark_create_effect(_name, _type, _start, _end, _aument, _turnactive, _turniter, _turnaument = 1) {
    return (new __dark_class_effect(_name, _type, _start, _end, _aument, _turnactive, _turniter, _turnaument) );
}

/// @param key
/// @returns {__dark_class_spell}
function dark_get(_key) {
    return (DARK[? _key] );
}

function dark_get_spell(_key) {
	return (DARK[? _key].spell);
}

/// @param key
/// @returns {bool}
function dark_exists(_key) {
    return (ds_map_exists(DARK, _key) );
}

/// @desc Con este codigo se crean todos los hechizos
function dark_init() {
    dark_add("DARK.BATTLE.ATACK" , dark_create_spell("Ataque").SetSpell(function(caster, targets, extra) {
        var _cstat = caster .stats_final;
        var _tstat = targets.stats_final;
        
        // extra = {base, slot};
        var base = extra.base;
        var slot = extra.slot, count;
        
        //	Primer Slot es el primario y el que se encarga de comprobar los links!
        if (!is_array(slot) ) slot = [slot];
    	count = array_length(slot);

    	//////////////////////////////////////////////////////

		// -- Caster
		var _clvl = caster.stats.lvl;				
		var _cfue =	caster.StatAffect ("fue");
			
		// -- Target	
		var _tlvl = targets.stats.lvl;
		var _tdef = targets.StatAffect("def");
		
		// Asegurarse que ambos poseen salud
		if (_tstat.Above("ps") && (_cstat.Above("ps") ) ) {
			var _cequip = caster.equip;
			var _aslot, _equipped, _lslot = noone;

			for (var i = 0; i < count; i++) {
				_aslot		= slot[i];
				_equipped	= _cequip.Get(_aslot);
				
				// Si es linkeado no atacar!
				var _insidelink = _equipped.fromlink_name;
				if (_insidelink == _lslot) continue;
				
				// Obtener variables del slot
				var _power = _equipped.get_power(); // Obtener poder del arma

				var targetpart = 8 * count * (_tdef + _tlvl * 2);
				var damage = (((_clvl * count) + (base * 3) + _cfue) * base) div targetpart;
				
				var item = _equipped.get_item();
				
				///// {(cint+clvl*Count+Base*2)*Base}/{8*Count*(tesp+tlvl*2)}
				
				//////////////////////////////////////////////////////
				targets.StatUse("ps", round(damage * _power) );
				
				if (item != noone) {
					var _special = item.GetSpecial();
					
					if (!is_undefined(_special) ) {
						var _spell = dark_get_spell(_special.spell);
						var _extra = _special.arg;
						
						_spell(caster, targets, _extra);	
					}					
				}
				
				// Guardar
				_lslot = _aslot;
				
				show_debug_message("DARK.BATTLE.ATACK - Damage caused: " + string(damage) );
			}
		}
    }));
    
    dark_add("DARK.BATTLE.OBJECT", dark_create_spell("Objeto") );

    dark_add("DARK.WSPELL.HEAL1" , (dark_create_spell("Blanca", 30, true) ).SetSpell(function(caster, targets, extra) {
    	var consume = extra.consume;
    	var include = extra.include;
		
		var cstats		= caster.stats_final;
		var stat_affect = caster.StatAffect;
		
		var clvl = caster.lvl;
		var cint = stat_affect("int");
		
		var restore = ((clvl + cint * 9) * clvl) div 3200;
		
		if (cstats.Above("pm", consume) ) {
				
		}
    }) );
    
    /// @desc Aplica un estado a un objetivo.
    dark_add("DARK.GSPELL.BASIC" , (dark_create_spell("Verde") ).SetSpell(function(caster, targets, extra) {
    	var _chance = extra.chance, _state = extra.state;
    	
    	var state  = (mall_get_state(_state) );
    	var stat   = (state.GetLinkStat(0) ).GetName();
    	
    	// Probabilidad de infectar
    	var _prob = targets.stats_final.Get(stat).nop;
    	
    	if (percent_chance(_chance) ) {
	    	var _txt  = state.GetTxt();
	    	var _prop = state.GetProcess();

			var _turnfinal	= _prop.turnactive;

			_turnfinal = max(2, _turnfinal * percent_between(_prob) );
			
	    	var _effect  = (dark_create_effect(_txt, _state, _prop.start, _prop.ending, _prop.aument, round(_turnfinal), _prop.turniter, _prop.turnaument) )
	    	.SetProcess(_prop.updatestart, _prop.update, _prop.updateend);

	    	targets.control.AddControl(_effect);
    	}
    }) );
    
    
    dark_add("DARK.GSPELL.VENENO", dark_create_spell("Verde").SetSpell(function(caster, targets, extra) {
    	var control 	= caster.control;		
    	var statsfinal	= caster.stats_final, ps = caster.stats.Get("ps_max");

    	// Si ha sido envenenado
    	var _exists = control.ControlExists("Envenenado");
    	
    	if (ps > 0 && _exists) {
    		var _rest = ps * extra / 100;
    		
    		caster.StatUse("ps", _rest, true); // Quitar un 20% de la vida base
    		show_debug_message("DARK.GSPELL.VENENO - Damage caused: " + string(_rest) );
    	}
    	
		return (statsfinal.Above("ps") );    	    		
    }) );
    
    dark_add("DARK.GSPELL.MELANCOLIA", dark_create_spell("Verde").SetSpell(function(caster, targets, extra) {
    	var control 	= caster.control;		
    	var statsfinal	= caster.stats_final, pm = caster.stats.Get("pm");
    	
    	// Si ha sido envenenado
    	var _exists = control.ControlExists("Melancolico");
    	
    	if (pm > 0 && _exists) {
    		var _rest = pm * extra / 100;
    		
    		caster.StatUse("pm", _rest, true); // Quitar un 20% del pm base
    	}
    	
		return (statsfinal.Above("pm") );    	
	}) );
        
    dark_add("DARK.GSPELL.QUEMADURA", dark_create_spell("Verde").SetSpell(function(caster, targets, extra) {
    	var control 	= caster.control;		
    	var statsfinal	= caster.stats_final, ps = caster.stats.Get("ps");
    	
    	// Si ha sido envenenado
    	var _exists = control.ControlExists("Quemado");
    	
    	if (ps > 0 && _exists) {
    		var _rest = ps * extra / 100;
    		
    		caster.StatUse("ps", _rest, true); // Quitar un 20% del pm base
    	}
    	
		return (statsfinal.Above("ps") );    	
	}) );    
    
    
    
    
}