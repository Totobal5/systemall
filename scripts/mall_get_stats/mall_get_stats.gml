/// @return {Array<String>}
function mall_get_stats() {
	return (global.__mall_stats_master);
}

/// @return {Array<String>}
function mall_get_stats_copy() {
	var _stats = mall_get_stats();
	var _array = [];
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}