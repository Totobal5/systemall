/// @param {String}		group_key
/// @param {Function}	foreach_method	function(mall_stat, stat_name, i, [arguments])
/// @param {Any}		[arguments]
/// @desc Ejecuta un codigo por cada estadistica en el grupo
function mall_stat_foreach(_group, _function, _pass=[])
{
	var _group = mall_get_group(_group)
	var _stats = mall_get_stats();
	
	var i=0; repeat(array_length(_stats) )
	{
		var _stat = _stats[i];
		var _mall = _group.getStat(_stat);
		_function(_mall, _stat, i, _pass);
		++i;
	}
}