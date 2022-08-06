/// @param {Function}	foreach_method	function(MOD, KEY, I, [ARGUMENTS])
/// @param {Any}		[arguments]
/// @desc Ejecuta un codigo por cada modificador en el grupo
function mall_mod_foreach(_FUN, _PASS=[])
{
	var _mod = mall_get_mod_keys();
	var i=0; repeat(array_length(_mod) )
	{
		var _key  = _mod[i];
		var _mall = global.__mallModsMaster[$ _key];
		
		_FUN(_mall, _key, i, _PASS);
		i += 1;
	}
}