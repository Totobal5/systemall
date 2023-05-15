/// @desc	Donde se guarda la configuracion para los modificadores del proyecto
///			Se configuran: 
/// @param {String} modKey
/// @return {Struct.MallMod}
function MallMod(_modKey) : MallComponent(_modKey, false) constructor 
{
	// -- Eventos --
	/// @ignore
	funStart = "";
	/// @ignore
	funEnd   = "";
	
	/// @ignore
	funEquip    = "";
	/// @ignore
	funDesequip = "";
	/// @ignore
	funTurnStart = "";
	/// @ignore
	funTurnEnd   = "";
	
	#region METHODS	

	/// @param	{String} [funStart]   
	/// @param	{String} [funEnd]       
	/// @return {Struct.MallMod}
	static setFunSE = function(_funS, _funE)
	{
		funStart = _funS;
		funEnd   = _funE;
		return self;
	}

	/// @param	{String} funEquip
	static setFunEquip    = function(_fun)
	{
		funEquip = _fun;
		return self;
	}
	
	/// @param	{String} funDesequip
	/// @desc funcion a ejecutar cuando se equip
	static setFunDesequip = function(_fun) 
	{
		funDesequip = _fun;
		return self;
	}

	/// @param	{String} [funStart]   
	/// @param	{String} [funEnd]     
	static setFunTurn = function(_funS, _funE)
	{
		funTurnStart = _funS ?? funTurnStart;
		funTurnEnd   = _funE ??   funTurnEnd;
		return self;
	}
	
	
	#region Funciones
	/// @param {struct.PartyEntity} partyEntity	
	exStart = function(_entity)
	{
		static fun = dark_get_function(funStart) ?? function(_entity) {} 
		return (fun(_entity) );
	}

	/// @param {struct.PartyEntity} partyEntity
	exEnd   = function(_entity)
	{
		static fun = dark_get_function(funEnd)   ?? function(_entity) {};
		return (fun(_entity) );
	}
	
	/// @param {struct.PartyEntity} partyEntity
	exEquip    = function(_entity)
	{
		static fun = dark_get_function(funEquip)    ?? function(_entity) {};
		return (fun(_entity) );
	}

	/// @param {struct.PartyEntity} partyEntity
	exDesequip = function(_entity)
	{
		static fun = dark_get_function(funDesequip) ?? function(_entity) {};
		return (fun(_entity) );
	}
	
	
	#endregion
	
	
	#endregion
}

/// @desc Crea un modificador
/// @param {String} modKey...
function mall_add_mod() 
{
	static mods = MallDatabase.mods;
	static keys = MallDatabase.modsKeys;
	static DebugMessage = MallDatabase.modsDebugMessage;
    var i=0; repeat(argument_count)
	{
		var _key = argument[i];
		if (!variable_struct_exists(mods, _key) ) {
			mods[$ _key] = new MallMod(_key);
			array_push(keys, _key);
			// Mostrar mensaje
			if (MALL_TRACE) DebugMessage("(AddModify): " + _key + " added");
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
	static database = MallDatabase.mods;
	return (variable_struct_exists(database, _modKey) );
}

/// @desc Obtiene un modificador en el grupo actual
/// @param {String} modKey
/// @return {Struct.MallMod}
function mall_get_modify(_modKey)
{
	static database = MallDatabase.mods;
	// Feather ignore GM1028
	return (database[$ _modKey] );
}

/// @desc Devuelve todos las llaves de elemento
/// @return {Array<String>}
function mall_get_modify_keys(_copy=false)
{
	// Feather disable GM1045
	static keys = MallDatabase.modsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}