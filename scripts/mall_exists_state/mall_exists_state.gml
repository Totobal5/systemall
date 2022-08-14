/// @param {String}	state_key
function mall_exists_state(_STATE_KEY)
{
	return (variable_struct_exists(global.__mallStatesMaster, _STATE_KEY) );
}