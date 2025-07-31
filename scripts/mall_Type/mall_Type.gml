/// @desc Añade un nuevo tipo al sistema.
/// @param {String} key
/// @param {Any}	value
function mall_create_type(_key, _value)
{
    if (mall_exists_type(_key) )
    {
		array_push(Systemall.__types[$ _key], _value);
		return __mall_print($"Advertencia: El tipo '{_key}' ya existe. El valor se añadirá al final.");
    }
	
	// Crear array y añadir a la lista de tipos.
	Systemall.__types[$ _key] = [_value];
	array_push(Systemall.__types_keys, _key);
}

/// @desc Comprueba si existe un tipo en el sistema.
/// @param {String} key
/// @return {Bool}
function mall_exists_type(_key)
{
	return struct_exists(Systemall.__types, _key);
}

/// @desc 
/// @param {String} key
/// @return {Any}
function mall_get_type(_key)
{
	return Systemall.__types[$ _key];	
}