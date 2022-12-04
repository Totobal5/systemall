/// @desc	Donde se guarda la configuracion para los modificadores del proyecto
///			Se configuran: 
/// @param {String} modKey
/// @return {Struct.MallMod}
function MallMod(_modKey) : MallComponent(_modKey, false) constructor 
{
	// -- Eventos --
	/// @param {Any*} entity
	/// @param {Any*} [vars]
	static __dummy = function(_entity, _vars) {}
	
	/// @desc Funcion a usar cuando se inicia este componente
	/// @param {Any*}	entity
	/// @param {String}	[vars]
	funStart = __dummy;

	/// @desc Funcion a usar cuando termina este componente
	/// @param {Any*}	entity
	/// @param {String}	[vars]
	funEnd   = __dummy;
	
	/// @desc Funcion a ejecutar cuando inicia el turno
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	funTurnStart  = __dummy;

	/// @desc Funcion a ejecutar cuando finaliza el turno
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	funTurnEnd    = __dummy;
	
	/// @desc Al intentar actuar inicio (todo lo que se indique que es combate)
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	funCombatStart = __dummy;

	/// @desc Al intentar actuar final(todo lo que se indique que es combate)
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	funCombatEnd   = __dummy;
	
	/// @desc Al intentar actuar inicio (todo lo que se indique que no es combate)
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	funNoCombatStart = __dummy;
	
	/// @desc Al intentar actuar final  (todo lo que se indique que no es combate)
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	funNoCombatEnd   = __dummy;
	
	
	funEquipStart = __dummy;
	funEquipEnd   = __dummy;
	
	#region METHODS	

	/// @param	{Function} funStart   
	/// @param	{Function} [funStart] 
	/// @return {Struct.MallMod}
	static setSE = function(_funStart, _funEnd)
	{
		funStart = _funStart ?? funStart;
		funEnd   =   _funEnd ??   funEnd;
		return self;
	}

	/// @param	{Function} funTurnStart
	/// @param	{Function} [funTurnEnd]
	static setTurnSE = function(_funStart, _funEnd)
	{
		funTurnStart = _funStart ?? funTurnStart;
		funTurnEnd   =   _funEnd ?? funTurnEnd;
		return self;
	}


	/// @param	{Function} funCombatStart
	/// @param	{Function} [funCombatEnd]
	static setCombatSE = function(_funStart, _funEnd)
	{
		funCombatStart = _funStart ?? funCombatStart;
		funCombatEnd   =   _funEnd ??   funCombatEnd;
		return self;
	}


	/// @param	{Function} funNoCombatStart
	/// @param	{Function} [funNoCombatEnd]
	static setNoCombatSE = function(_funStart, _funEnd)
	{
		funNoCombatStart = _funStart ?? funNoCombatStart;
		funNoCombatEnd   =   _funEnd ??   funNoCombatEnd;
		return self;
	}
	
	
	/// @param	{Function} funEquipStart
	/// @param	{Function} [funEquipEnd]
	static setEquipSE = function(_funStart, _funEnd)
	{
		funEquipStart = _funStart ?? funEquipStart;
		funEquipEnd   =   _funEnd ??   funEquipEnd;
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
	// Feather disable GM1045
	static keys = MallDatabase().modsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}