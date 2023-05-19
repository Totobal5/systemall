/// @desc   Donde se guarda la configuracion para los modificadores del proyecto
///         Se configuran: 
/// @param {String} modKey
/// @return {Struct.MallMod}
function MallMod(_modKey) : Mall(_modKey) constructor 
{
	static startAction = __dummy;
	static endAction   = __dummy;
	
	static turnAction = __dummy;
	static turnStart  = __dummy;
	static turnEnd    = __dummy;
	
	/// @desc Este evento se utiliza cuando se equipa un objeto
	static equip    = __dummy;
	static desequip = __dummy;
}

/// @desc Crea un modificador
/// @param {String} modKey...
function mall_create_mod() 
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