/// @param	{String} stat_key
/// @desc	Devuelve la estructura de la estadistica
/// @return {Struct.MallStat}
function mall_get_stat(_key) 
{
	return (mall_group_get_actual().__stats[$ _key] );
}