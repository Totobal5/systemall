/// @param {String}		group_key
/// @param {Function}	foreach_method	function(mall_part, part_name, i, [arguments])
/// @param {Any}		[arguments]
/// @desc Ejecuta un codigo por cada estadistica en el grupo
function mall_part_foreach(_group, _function, _pass=[])
{
	var _group  = mall_get_group(_group)
	var _states = mall_get_parts();
	
	var i=0; repeat(array_length(_states) )
	{
		var _part = _parts[i];
		var _mall = _group.getPart(_part);
		_function(_mall, _part, i, _pass);
		++i;
	}
}