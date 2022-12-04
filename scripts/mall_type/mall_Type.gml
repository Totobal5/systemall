// Feather ignore all

/// @desc	Un tipo es como debe funcionar los componentes guardados (MallStorage) entre sí.
///			Esto sirve para diferenciar clases, especies o razas en distintos rpg (Humanos distintos a Orcos por ejemplo)
/// @param	{String} typeKey
/// @return {Struct.MallType}
function MallType(_key) : MallMod(_key) constructor 
{
	bonus = 0
	type  = MALL_NUMTYPE.REAL;
	
	/// @return {Struct.MallType}
	static set = function(_bonus, _numtype)
	{
		bonus = _bonus;
		type  = _numType;
		return self;
	}
}

/// @param {String} typeKey	Llave del tipo
/// @desc	Crea uno o varios type mall
function mall_add_type(_KEY) 
{
	static types = MallDatabase().types;
	static keys  = MallDatabase().typesKeys;
	
	var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(types, _key) ) {
			types[$ _key] = new MallType(_key);
			array_push(keys, _key);
			if (MALL_TRACE) {show_debug_message("MallRPG (addType): {0} added", _key); }
		}
		
		i = i + 1;
	}
}

/// @param {String} typeKey
function mall_exists_type(_KEY)
{
	static types = MallDatabase().types;
	return (variable_struct_exists(types, _KEY) );
}

/// @param {String} typeKey
/// @returns {Struct.MallType}
function mall_get_type(_KEY) 
{
	static types = MallDatabase().types;
    return (types[$ _KEY] ); 
}

/// @desc Devuelve un array con las llaves de todos los tipos creados
/// @return {Array<String>}
function mall_get_type_keys(_copy=false) 
{
	static keys = MallDatabase().typesKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}