/// @desc Devuelve todos las llaves de elemento
/// @return {Array}
function mall_get_elements(){
	return (global.__mall_elements_master);
}

/// @desc Devuelve una copia de todas las llaves los elemento creados
/// @return {Array<String>}
function mall_get_states_copy() {
	var _stats = mall_get_elements();
	var _array = [];
	
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}