/// @param {String}	group_key
/// @return {Real}
function party_group_size(_key)
{
	var _group = party_group_get(_key);
	return (array_length(_group) );
}