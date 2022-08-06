// Feather ignore all

/// @desc Devuelve todos las llaves de elemento
/// @return {Array<String>}
function mall_get_mod_keys()
{
	return (global.__mallElementsKeys);
}

/// @desc Devuelve una copia de todas las llaves los elemento creados
/// @return {Array<String>}
function mall_get_mod_keys_copy() 
{	
	var _keys  = mall_get_mod_keys();
	var _array = [];
	
	array_copy(_array, 0, _keys, 0, array_length(_keys) );
	return _array;
}