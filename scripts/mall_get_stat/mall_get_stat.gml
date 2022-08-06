/// @param	{String} stat_key
/// @desc	Devuelve la estructura de la estadistica
/// @return {Struct.MallStat}
function mall_get_stat(_KEY) 
{
	return (global.__mallStatsMaster[$ _KEY] );
}