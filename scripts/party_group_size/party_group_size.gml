/// @param {String}	groupKey
/// @return {Real}
function party_group_size(_KEY)
{
	var _group = party_group_get_entities(_KEY);
	return (array_length(_group) );
}