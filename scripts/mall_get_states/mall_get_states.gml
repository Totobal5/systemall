/// @desc Devuelve todos las llaves de estado
/// @returns {Array<String>}
function mall_get_states() {
    return (global.__mall_states_master);
}

/// @desc Devuelve una copia de todas las llaves los estados creados
/// @return {Array<String>}
function mall_get_states_copy() {
	var _stats = mall_get_states();
	var _array = [];
	
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}