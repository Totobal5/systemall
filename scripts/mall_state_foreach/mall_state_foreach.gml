/// @desc Ejecuta un codigo por cada estado
/// @param {Function}	foreach_method	function(STATE, KEY, I, [ARGUMENTS])
/// @param {Any}		[arguments]
function mall_state_foreach(_FUN, _PASS=[])
{
	var _states = mall_get_state_keys();	
	var i=0; repeat(array_length(_states) )
	{
		var _key   = _states[i];
		var _state = global.__mallStatesMaster[$ _key];
		_FUN(_key, _state, i, _PASS);
		
		i += 1;
	}
}