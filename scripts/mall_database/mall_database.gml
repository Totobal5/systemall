/// @desc EN ESTE SCRIPT SE DEBE CREAR Y CUSTOMIZAR CADA ELEMENTO MALL
function mall_database()
{
	/* Ejemplo pokemon */
	mall_add_stat ("PS", "ATTACK", "DEFENSA", "ESPECIAL", "VELOCIDAD", "CRITICAL", "EXP");
	mall_add_state("VIVO", "VENENO", "CONGELADO", "PARALIZADO", "DORMIDO", "QUEMADO");
	mall_add_mod  ("FUEGO", "HIELO", "TIERRA", "ELECTRICO", "FANTASMA", "PSIQUICO", "INSECTO", "LUCHA", "NORMAL", "AGUA", "PLANTA");
	
	#region Stats
	var _ps = mall_customize_stat("PS", 1, 0, 0, 9999, true, "STATS.PS", function() {
		/// @self {Struct.__PartyStatsAtom}
		return (lexicon_text(displayKey) + ": " + string(valueActual) + " / " + string(valueMax) );
	}).
	setLevel(function(_LEVEL, _ATOM, _USER) {
		return _LEVEL + (10 + (_LEVEL / 100 * (_ATOM.base * 2) ) );
	});
	
	mall_customize_stat("FUERZA", 1, 0, 0, 999, true, "STATS.FUE", function() {
		/// @self {__PartyStatsAtom}
		return (lexicon_text(displayKey) + ": " + string(valueActual) );			
	}).
	setLevel(function(_LEVEL, _ATOM, _USER) {
		return 5 + (_LEVEL / 100 * (_ATOM.base*2) );	
	});
		
	mall_customize_stat("DEFENSA"  , "FUERZA", true, true, true);
	mall_customize_stat("ESPECIAL" , "FUERZA", true, true, true);
	mall_customize_stat("VELOCIDAD", "FUERZA", true, true, true);
	
	mall_customize_stat("CRITICAL", 0, 1, 0, 255, false).
	setLevel(function(_LEVEL, _ATOM, _USER) {
		var _speed = _USER.get("VELOCIDAD");
		return (_speed.valueMax / 2);	
	});
		
	mall_customize_stat("EXP", 0, 0, 0, 999999, true, "STATS.EXP", function() {
		return (lexicon_text(displayKey) + ": " + string(valueActual) + " / " + string(valueMax));
	}).
	// usa flag
	setLevel(function(_LEVEL, _ATOM, _USER) {
		switch (_ATOM.flag)	
		{
			case "Medium Slow":
			return (1.2 * power(_LEVEL, 3) ) - (15 * power(_LEVEL, 3) ) + (100 * _LEVEL) - 140;
			break;
		}
	});
		
	#endregion
	
	#region States	
	mall_customize_state("VIVO", true, 1, false);
	
	mall_customize_state("VENENO", false, 1, true, "STATE.VENENO", function() {return "VEN";} ).
	setUpdate("onStart", function(_STATS, _EQUIPMENT, _CONTROL, _USER)  {
		_STATS.add("PS", -5, 1, 4);	// el 5% de la vida maxima y la quita de la actual
	});
	
	mall_customize_state("CONGELADO",  false, 1, true, "STATE.CONGELADO",  function() {return "CON";} ).
	setStart(function(_STATS, _EQUIPMENT, _CONTROL, _USER) {
		_USER.__pass = true;
		_USER.__passReset = -1;
	}).
	setUpdate("onStart", function(_STATS, _EQUIPMENT, _CONTROL, _USER)  {
		var _random = irandom(100);
		if (_random > 50)
		{
			_USER.__pass = false;
			_USER.__passReset = 0;
			_USER.__passCount = 0;
		}
	});
	
	mall_customize_state("PARALIZADO", false, 1, true, "STATE.PARALIZADO", function() {return "PAR";} ).
	setUpdate("onCombat", function(_STATS, _EQUIPMENT, _CONTROL, _USER) {
		var _random = irandom(100);
		if (_random > 80)
		{
			_USER.__pass = true;
			_USER.__passReset = 1;	// Proximo turno puede actuar nuevamente
		}
	});
	
	mall_customize_state("DORMIDO",    false, 1, true, "STATE.DORMIDO",    function() {return "DOR";} ).
	setStart (function(_STATS, _EQUIPMENT, _CONTROL, _USER) {
		_USER.__pass = true;
		_USER.__passReset = -1;
	}).
	setUpdate("onCombat", function(_STATS, _EQUIPMENT, _CONTROL, _USER) {
		var _more   = 100 * ( (_USER.__turnControl - _CONTROL.__turnStart) / 14);
		var _random	= irandom(100);
		
		// Salir de dormido
		if (_random > (90 - _more) )
		{
			_USER.__pass = false;
			_USER.__passReset = 0;
			
			_CONTROL.__ready = true;
		}
	});

	mall_customize_state("QUEMADO",    false, 1, true, "STATE.QUEMADO",    function() {return "DOR";} ).
	setStart(function(_STATS, _EQUIPMENT, _CONTROL, _USER) {
	});
	
	#endregion
	
	mall_customize_mod("FUEGO").setOnAttack(function(_USER, _TARGET, _VALUE) {
		var _apply=1;
		var _mods =_TARGET.__mods;
		
		if (variable_struct_exists(_mods, "PLANTA") )	_apply += .5;
		if (variable_struct_exists(_mods, "INSECTO"))	_apply += .5;
		if (variable_struct_exists(_mods, "TIERRA") )	_apply -= .5;
		if (variable_struct_exists(_mods, "TIERRA") )	_apply -= .5;	
		
		return (_VALUE * _apply);
	});	
		
}