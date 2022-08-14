/// @desc Ejecuta un codigo por cada modificador en el grupo
/// @param {Function}	foreach_method	function(MODIFY, KEY, I, [ARGUMENTS])
/// @param {Any}		[arguments]
function mall_modify_foreach(_FUN, _PASS=[])
{
	var _mod = mall_get_modify_keys();
	var i=0; repeat(array_length(_mod) )
	{
		var _key  = _mod[i];
		var _mall = global.__mallModifyMaster[$ _key];
		
		_FUN(_mall, _key, i, _PASS);
		i += 1;
	}
}