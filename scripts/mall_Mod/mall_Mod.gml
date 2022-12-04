/// @desc	Donde se guarda la configuracion para los modificadores del proyecto
///			Se configuran: 
/// @param {String} modKey
/// @return {Struct.MallMod}
function MallMod(_modKey) : MallComponent(_modKey, false) constructor 
{
	// -- Eventos --
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventStart = function(_ENTITY, _FLAG="") {return ""};		// Funcion a usar cuando se inicia el estado

	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventTurnStart  = function(_ENTITY, _FLAG="") {return ""}	// Al iniciar turno
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventTurnFinish = function(_ENTITY, _FLAG="") {return ""}	// Al terminar turno
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventCombatStart  = function(_ENTITY, _FLAG="") {return ""; }	// Al intentar actuar inicio (todo lo que se indique que es combate)

	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventCombatFinish = function(_ENTITY, _FLAG="") {return ""}		// Al intentar actuar final(todo lo que se indique que es combate)
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventObjectStart = function(_ENTITY, _FLAG="") {return ""}		// Al intentar actuar inicio (todo lo que se indique que no es combate)
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventObjectFinish = function(_ENTITY, _FLAG="") {return ""}		// Al intentar actuar final  (todo lo que se indique que no es combate)	

	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}B
	eventFinish = function(_ENTITY, _FLAG="") {return ""};			// Funcion a usar cuando se finaliza el estado
	
	#region METHODS	

	/// @param	{Function}	start_event
	static setEventStart  = function(_EVENT)
	{
		eventStart = _EVENT;
		return self;
	}

	/// @param	{Function}	finish_event
	static setEventFinish = function(_EVENT)
	{
		eventFinish = _EVENT;
		return self;
	}

	/// @param	{Function}	turn_start_event
	static setEventTurnStart  = function(_EVENT)
	{
		eventTurnStart  = _EVENT;	// Al iniciar turno
		return self;
	}
	
	/// @param	{Function}	finish_turn_event
	static setEventTurnFinish = function(_EVENT)
	{
		eventTurnFinish = _EVENT;	// Al terminar turno
		return self;
	}

	/// @param	{Function}	combat_start_event
	static setEventCombatStart = function(_EVENT)
	{
		eventCombatStart = _EVENT;
		return self;
	}

	/// @param	{Function}	combat_finish_event
	static setEventCombatFinish = function(_EVENT)
	{
		eventCombatFinish = _EVENT;
		return self;
	}

	/// @param	{Function}	object_start_event
	static setEventObjectStart  = function(_EVENT)
	{
		eventObjectStart = _EVENT;
		return self;
	}

	/// @param	{Function}	object_finish_event
	static setEventObjectFinish = function(_EVENT)
	{
		eventObjectFinish = _EVENT;
		return self;
	}

	#endregion
}

/// @desc Crea un modificador
/// @param {String} modKey...
function mall_add_mod() 
{
	static mods = MallDatabase().mods;
	static keys = MallDatabase().modsKeys;
    var i=0; repeat(argument_count)
	{
		var _key = argument[i];
		if (!variable_struct_exists(mods, _key) ) {
			mods[$ _key] = new MallMod(_key);
			array_push(keys, _key);
			if (MALL_TRACE) {show_debug_message("MallRPG (addModify): {0} added", _key); }
		}

		i = i + 1;
	}
}

/// @param	{String}	modKey           Llave del modificador
/// @param	{String}	[displayKey]        
/// @returns {Struct.MallMod}
function mall_customize_mod(_modKey, _displayKey) 
{
    var _mod = mall_get_modify(_modKey);
	_mod.setDisplayKey(_displayKey);
	return (_mod);
}

/// @param {String} modKey
function mall_exists_modify(_modKey)
{
	static database = MallDatabase().mods;
	return (variable_struct_exists(database, _modKey) );
}

/// @desc Obtiene un modificador en el grupo actual
/// @param {String} modKey
/// @return {Struct.MallMod}
function mall_get_modify(_modKey)
{
	static database = MallDatabase().mods;
	return (database[$ _modKey] );
}

/// @desc Devuelve todos las llaves de elemento
/// @return {Array<String>}
function mall_get_modify_keys(_copy=false)
{
	static keys = MallDatabase().modsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}