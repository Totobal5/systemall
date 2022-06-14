/// @desc Devuelve un array con las llaves de todos las estadisticas creadas
/// @return {Array<String>}
function mall_get_stats() {
	return (global.__mall_stats_master);
}

/// @desc Devuelve una copia de todas las llaves de las estadisticas creadas
/// @return {Array<String>}
function mall_get_stats_copy() {
	var _stats = mall_get_stats();
	var _array = [];
	
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}