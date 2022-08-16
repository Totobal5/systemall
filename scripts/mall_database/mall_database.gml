function mall_database()
{
	// Feather ignore all
	mall_add_stat ("PS", "PM", "EXP", "PODER", "FUERZA", "DEFENSA", "ESPECIAL", "VELOCIDAD", "CRITICAL");
	mall_add_state("VIVO", "VENENO", "QUEMADO", "CONGELADO", "DORMIDO");
	mall_add_equipment("ARMA", "ARMADURA", "PANTALONES");
	
	mall_add_type("ALL", "BOSS");
	
	#region Stats
	var _p = function(_FLAG) {
		/// @self {Struct.__PartyStatsAtom}
		switch (_FLAG)
		{
			default: return (lexicon_text(displayKey, actual, peak) ); break;
		}
	}
	
	mall_customize_stat("PS", 0, MALL_NUMTYPE.REAL, 0, 9999, "GUI.PS", _p).setEventLevel(function(entity, atom, level) {
		return ( (atom.base * level) div 2) + (level + 10);
	}, 0, 100);
	mall_customize_stat("PM", "PS", true, false, true).setLimits(0, 999).setDisplay("GUI.PM");

	mall_customize_stat("EXP", 0, MALL_NUMTYPE.REAL, 0, 99999, "GUI.EXP", _p).iterToMin(1, true, -1).setEventLevel(function(entity, atom, level) {
		var _fExp = entity.getFlag(atom.key);
		switch (_fExp)
		{
			default:
				return	(atom.base * level * 7) + (level * 2) + 60; 
			break;
			
			case "Medium":
				return	(atom.base * level * 8) + (level * 2) + 60; 
			break;
			
			case   "Fast":
				return	(atom.base * level * 2) + (level * 2) + 60; 
			break;
			
			case   "Slow":
				return	(atom.base * level * 12) + (level * 2) + 60;	
			break;
		}

	}, 0, 100);

	var _t = function(_FLAG) {
		/// @context {Struct.__PartyStatsAtom}
		switch (_FLAG)
		{
			default: return (lexicon_text(displayKey, actual) ); break;
		}
	}
	var _s = function(entity, stat) {
		stat.actual = stat.control;
	}
	mall_customize_stat("FUERZA", 0, MALL_NUMTYPE.REAL, 0, 999, "GUI.FUE", _t).setEventLevel(function(entity, atom, level) {
		return ( (atom.base * level) div 15) + 5;
	}, 0, 100).setEventObjectFinish(_s);
	
	mall_customize_stat("DEFENSA"  , "FUERZA", true, true, true).setDisplay("GUI.DEF").setEventObjectFinish(_s);
	mall_customize_stat("ESPECIAL" , "FUERZA", true, true, true).setDisplay("GUI.ESP").setEventObjectFinish(_s);
	mall_customize_stat("VELOCIDAD", "FUERZA", true, true, true).setDisplay("GUI.VEL").setEventObjectFinish(_s);
	
	mall_customize_stat("CRITICAL", 0, MALL_NUMTYPE.PERCENT, 0, 200, "GUI.CRITICAL", _t).setEventLevel(function(entity, stat, flag) {
		var _vel = entity.get("VELOCIDAD");
		return (_vel.peak / 10);
	}, 0, 100).setEventObjectFinish(_s);;
	mall_customize_stat("PODER",    0, MALL_NUMTYPE.PERCENT, 0, 200, "GUI.PODER",	 _t).setEventObjectFinish(_s);;

	#endregion
	
	#region State
	mall_customize_state("VIVO"		, true, 100,  1, false, "GUI.VIVO"		, function(_FLAG) {
		if (!init)	{return (lexicon_text(displayKey + ".ACTIVE") ); } 
		else		{return (lexicon_text(displayKey + ".DESACTIVE") ); }
	});
	mall_customize_state("VENENO"	, true,  20, -1, true, "GUI.VENENO"		, function(_FLAG) {}).setEventTurnStart(function(entity, flag) {
		var _stats = entity.getStats();
		var _sub = _stats.add("PS", -30, MALL_NUMTYPE.PERCENT, 2);
		// enviar mensaje
		mall_message_send(lexicon_text("GUI.VENENO.MSG", entity.key, _sub) );
	});
	mall_customize_state("QUEMADO"	, true,  42, -1, true, "GUI.QUEMADO"	, function(_FLAG) {}).setEventTurnStart(function(entity, flag) {
		var _stats = entity.getStats();
		var _sub = _stats.add("PS", -10, MALL_NUMTYPE.PERCENT, 2); 
		
		// enviar mensaje
		mall_message_send(lexicon_text("GUI.QUEMADO.MSG", entity.key, _sub) );
	});
	mall_customize_state("CONGELADO", true,  10, -1, true, "GUI.CONGELADO"	, function(_FLAG) {}).setEventTurnStart(function(entity, flag) {
		entity.pass = true;
		// enviar mensaje
		mall_message_send(lexicon_text("GUI.CONGELADO.MSG", entity.key) );
	});
	mall_customize_state("DORMIDO"	, true,  25, -1, true, "GUI.DORMIDO"	, function(_FLAG) {}).setEventTurnStart(function(entity, flag) {
		entity.pass = true;
		mall_message_send(lexicon_text("GUI.DORMIDO.MSG", entity.key) );
	});	

	#endregion
	
	#region Equipment
	var _equipdisp = function(_FLAG) {
		return (lexicon_text(displayKey) + ": " + equipped);
	}
	
	mall_customize_equipment("ARMA",		"GUI.ARMA",			_equipdisp);
	mall_customize_equipment("ARMADURA",	"GUI.ARMADURA",		_equipdisp);
	mall_customize_equipment("PANTALONES",	"GUI.PANTALONES",	_equipdisp);
	
	#endregion
}