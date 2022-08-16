/// @param {String}	party_group_key
/// @return {Real}
function party_group_size(_KEY)
{
	var _group = party_group_get(_KEY);
	return (array_length(_group.entitys) );
}