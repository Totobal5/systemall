function mall_database()
{
	mall_add_type("ALL", "BOSS");
	mall_add_stat ("PS", "PM", "EXP", "PODER", "FUERZA", "DEFENSA", "ESPECIAL", "VELOCIDAD", "CRITICAL");
	mall_add_state("VIVO", "VENENO", "QUEMADO", "CONGELADO", "DORMIDO");
	
	mall_add_equipment("ARMA", "ARMADURA", "PANTALONES");
	
	#region Stats
	var _oneMethod = function(_FLAG) {
		/// @self {Struct.__PartyStatsAtom}
		var _text = lexicon_text(__displayKey);
		switch (_FLAG)
		{
			default:
				return (_text + ": " + string(actual) + " / " + string(peak) ); 
			break;
		}
	}
	
	mall_customize_stat("PS", 0, MALL_NUMTYPE.REAL, 0, 9999, "GUI.PS", _oneMethod).
	setEventLevel(function(entity, atom, level) {
		return ( (atom.base * level) div 2) + (level + 10);
	}, 0, 100);
	
	mall_customize_stat("PM",  "PS", true, false, true).setValueLimits(0, 999).setDisplay("GUI.PM");

	mall_customize_stat("EXP", "PM", true).setValueLimits(0, 99999).setDisplay("GUI.EXP").
	setEventLevel(function(entity, atom, level) {
		return (atom.base * level * 7) + (level * 2) + 60;
	}, 0, 100);

	var _twoMethod = function(_FLAG) {
		/// @self {Struct.__PartyStatsAtom}
		var _text = lexicon_text(__displayKey);
		switch (_FLAG)
		{
			default:
				return (_text + ": " + string(actual) ); 
			break;
		}
	}
	
	mall_customize_stat("FUERZA", 0, MALL_NUMTYPE.REAL, 0, 999, "GUI.FUE", _twoMethod).
	setEventLevel(function(entity, atom, level) {
		return ( (atom.base * level) div 15) + 5;
	}, 0, 100);
	
	mall_customize_stat("DEFENSA"  , "FUERZA", true, true, true).setDisplay("GUI.DEF");
	mall_customize_stat("ESPECIAL" , "FUERZA", true, true, true).setDisplay("GUI.ESP");
	mall_customize_stat("VELOCIDAD", "FUERZA", true, true, true).setDisplay("GUI.VEL");
	
	mall_customize_stat("CRITICAL", 0, MALL_NUMTYPE.PERCENT, 0, 200, "GUI.CRITICAL", function(_FLAG) {
		/// @self {Struct.__PartyStatsAtom}
		var _text = lexicon_text(__displayKey);
		switch (_FLAG)
		{
			default:
				return (_text + ": " + string(actual) + "%"); 
			break;
		}		
	});
	mall_customize_stat("PODER",    0, MALL_NUMTYPE.PERCENT, 0, 200, "GUI.PODER",    function(_FLAG) {
		/// @self {Struct.__PartyStatsAtom}
		var _text = lexicon_text(__displayKey);
		switch (_FLAG)
		{
			default:
				return (_text + ": " + string(actual) + "%"); 
			break;
		}		
	});

	#endregion
	
	#region State
	mall_customize_state("VIVO", true, 100, 1, false, "GUI.VIVO", function(_FLAG) {
		if (!__init) {return (lexicon_text(__displayKey + ".ACTIVE") ); } 
		else		 {return (lexicon_text(__displayKey + ".DESACTIVE") ); }
	});
	
	mall_customize_state("VENENO"	, true, 20, -1, true, "GUI.VENENO"	,  function(_FLAG) {}).addMessage("veneno",		"GUI.VENENO.MSG").
	setEventTurnStart(function(entity, flag) {
		var _statsControl = entity.getStats();
		var _sub = _statsControl.add("PS", -30, MALL_NUMTYPE.PERCENT, 2);
		return (lexicon_text(__message[$ "veneno"], entity.__key, _sub) );
	});
	
	mall_customize_state("QUEMADO"	, true, 42, -1, true, "GUI.QUEMADO"	,  function(_FLAG) {}).addMessage("quemado",	"GUI.QUEMADO.MSG").
	setEventTurnStart(function(entity, flag) {
		var _statsControl = entity.getStats();
		var _sub = _statsControl.add("PS", -10, MALL_NUMTYPE.PERCENT, 2); 
		return (lexicon_text(__message[$ "quemado"], entity.__key, _sub) );
	});
	
	mall_customize_state("CONGELADO", true, 10, -1, true, "GUI.CONGELADO", function(_FLAG) {}).addMessage("congelado",	"GUI.CONGELADO.MSG").
	setEventTurnStart(function(entity, flag) {
		entity.__pass = true;
		return (lexicon_text(__message[$ "congelado"], entity.__key) );
	});
	
	mall_customize_state("DORMIDO", true, 25, -1, true, "GUI.DORMIDO", function(_FLAG) {}).addMessage("dormido", "GUI.DORMIDO.MSG").
	setEventTurnStart(function(entity, flag) {
		entity.__pass = true;
		return (lexicon_text(__message[$ "dormido"], entity.__key) );
	});	
	
	
	#endregion
	
	#region Equipment
	mall_customize_equipment("ARMA"		,	"GUI.ARMA"		,	function(_FLAG) {
		return (lexicon_text(__displayKey) + ": " + equipped);
	})
	
	mall_customize_equipment("ARMADURA"	,	"GUI.ARMADURA"	,	function(_FLAG) {
		return (lexicon_text(__displayKey) + ": " + equipped);
	})

	mall_customize_equipment("PANTALONES",	"GUI.PANTALONES",	function(_FLAG) {
		return (lexicon_text(__displayKey) + ": " + equipped);
	})

	#endregion
}