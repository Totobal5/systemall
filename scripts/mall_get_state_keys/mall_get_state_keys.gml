// Feather ignore all

/// @desc Devuelve todos las llaves de estado
/// @returns {Array<String>}
function mall_get_state_keys()
{
    return (global.__mallStatesKeys);
}

/// @desc Devuelve una copia de todas las llaves los estados creados
/// @return {Array<String>}
function mall_get_state_keys_copy() 
{
	var _stats = mall_get_state_keys();
	var _array = [];
	
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}