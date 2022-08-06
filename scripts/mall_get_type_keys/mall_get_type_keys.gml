// Feather ignore all

/// @desc Devuelve un array con las llaves de todos las estadisticas creadas
/// @return {Array<String>}
function mall_get_type_keys() 
{
	return (global.__mallTypesKeys);
}

/// @desc Devuelve una copia de todas las llaves de las estadisticas creadas
/// @return {Array<String>}
function mall_get_type_keys_copy() 
{
	var _type  = mall_get_type_keys();
	var _array = [];
	
	array_copy(_array, 0, _type, 0, array_length(_type) );
	return _array;
}