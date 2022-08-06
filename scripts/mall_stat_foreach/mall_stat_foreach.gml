/// @desc Ejecuta un codigo por cada estadistica
/// @param {Function}	foreach_method	function(STAT, KEY, I, [ARGS)
/// @param {Any}		[arguments]
function mall_stat_foreach(_FUN, _PASS=[])
{
	var _stats = mall_get_stat_keys();
	var i=0; repeat(array_length(_stats) )
	{
		var _key = _stats[i];
		var _mall = global.__mallStatsMaster[$ _key];
		_FUN(_key, _mall, i, _PASS);
		i += 1;
	}
}