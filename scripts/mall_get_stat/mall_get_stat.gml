/// @param {String} _key
/// @return {Struct.MallStat}
function mall_get_stat(_key) {
	return (mall_actual_group().__stats[$ _key] );
}