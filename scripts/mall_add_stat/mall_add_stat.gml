/// @desc Crear un (o varios) stats
/// @param {String} stat_key
/// @param ...
function mall_add_stat() 
{
    var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(global.__mallStatsMaster, _key) )
		{
			global.__mallStatsMaster[$ _key] = new MallStat(_key);
			array_push(global.__mallStatsKeys, _key);
		}

		i = i+1;
	}
}