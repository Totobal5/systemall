/// @param	{String} state_key
/// @desc	Devuelve los prefijos del estado
/// @return {Array<String>}
function mall_get_state_prefix(_key)
{
	return (global.__mall_states_prefix[$ _key] );
}