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
        var slot = extra.slot;
        
        var count = (is_array(slot) ) ? array_length(slot) : 1;
        
        var _nm1 = "fue", _nm2 = "def";
        
        #region Esto ya es personalizado a lo que YO quiero realizar con mis estados, estadisticas, etc (lol lmao)
		// -- Caster
		var _clvl = caster.stats.lvl;				
		var _cfue =	caster.StatAffect (_nm1, _cstat.Get(_nm1) );
			
		// -- Target	
		var _tlvl = targets.stats.lvl;
		var _tdef = targets.StatAffect(_nm2, _tstat.Get(_nm2) );

        var atack  = (_cfue * _clvl * 3);
		var damage = ((atack / 8) * base) / (_tdef + _tlvl * 2);
        
		// Aplicar daño
		targets.StatUse("ps", round(damage) );
        
		// Si el arma posee un efecto especial aplicarlo
		if (_tstat.Get("ps") > 0) {
			var _equip = caster.equip;
			
			if (count > 1) {
				var i = 0; repeat(array_length(slot) ) {
					var _in = slot[i];
					
				    if (_equip.IsOccupied(_in) ) {
				    	var _put	 = _equip.Get(_in);
				    	
						var _item	 = bag_item_get(_put.equipped );	 	
						var _special = _item .GetSpecial();
						
						if (!is_undefined(_special) ) {
							var _spell = dark_get(_special.spell).spell;
							var _extra = _special.arg;
							
							_spell(caster, targets, _extra);	
						}	  
				    }
				    
					++i;
				}
			} else {
			    if (_equip.IsOccupied(slot) ) {
					var _item	 = _equip.Get(slot);	 	
					var _special = _item .GetSpecial();
					
					if (!is_undefined(_special) ) {
						var _spell = _special.spell;
						var _extra = _special.arg;
						
						_spell(caster, targets, _extra);	
					}	  
			    }				
			}
		}

		return [
		    damage, 
		    _tstat.Get("ps"),
        ];

        #endregion
    }));
    
    dark_add("DARK.BATTLE.OBJECT", dark_create_spell("Objeto") );

    dark_add("DARK.WSPELL.HEAL1" , (dark_create_spell("Blanca", 30, true) ).SetSpell(function() {
        show_debug_message("DARK SPELL PRUEBA!");    
    }));
    
    /// @desc Aplica un estado a un objetivo.
    dark_add("DARK.GSPELL.BASIC" , (dark_create_spell("Verde") ).SetSpell(function(caster, targets, extra) {
    	var _porcent = extra.porcent;
    	var _state   = extra.state;
    	// var _msj     = extra.msj;
    	
    	var state  = (mall_get_state(_state) );
    	var stat   = (state.GetLinkStat(0) ).GetName();
    	
    	// Probabilidad de infectar
    	var _prob = targets.stats_final.Get(stat).nop;
    	
    	if (_prob < irandom(100) ) {
	    	var _txt  = state.GetTxt();
	    	var _prop = state.GetProcess();
			
			
			var _turnfinal = _prop.turnactive;
			var _rand      = irandom(_prob); // 80
			
			if (_rand < _prob) _turnfinal = max(2, _turnfinal * ( (100 - _rand) / 100) );
			
	    	var _effect  = (dark_create_effect(_txt, _state, _prop.start, _prop.ending, _prop.aument, round(_turnfinal), _prop.turniter, _prop.turnaument) )
	    	.SetProcess(_prop.updatestart, _prop.update, _prop.updateend);
	    		
	    	targets.control.AddControl(_effect);
    	
    	}
    	
    	// return _msj[0];
    }) );
    
    
    dark_add("DARK.GSPELL.VENENO", dark_create_spell("Verde").SetSpell(function(caster, targets, extra) {
    	var control 	= caster.control;		
    	var statsfinal	= caster.stats_final, ps = caster.stats.Get("ps");

    	// Si ha sido envenenado
    	var _exists = control.ControlExists("Envenenado");
    	
    	if (ps > 0 && _exists) {
    		var _rest = ps * extra / 100;
    		
    		caster.StatUse("ps", _rest, true); // Quitar un 20% de la vida base
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