/// @desc Devuelve todos las llaves de partes
/// @returns {Array<String>}
function mall_get_parts() {
	return (global.__mall_parts_master);
}

/// @desc Devuelve una copia de todas las llaves de las partes creadas
/// @return {Array<String>}
function mall_get_parts_copy() {
	var _stats = mall_get_parts();
	var _array = [];
	
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}