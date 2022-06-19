/// @param {String}		group_key
/// @param {Function}	foreach_method	function(mall_state, state_name, i, [arguments])
/// @param {Any}		[arguments]
/// @desc Ejecuta un codigo por cada estadistica en el grupo
function mall_state_foreach(_group, _function, _pass=[])
{
	var _group  = mall_get_group(_group)
	var _states = mall_get_states();
	
	var i=0; repeat(array_length(_states) )
	{
		var _state = _states[i];
		var _mall = _group.getState(_state);
		_function(_mall, _state, i, _pass);
		++i;
	}
}