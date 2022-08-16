/// @return {Struct.PartyEntity}
function party_get(_KEY, _INDEX)
{
	// Feather ignore all
	if (_INDEX < 0) return (undefined);
	var _group = party_group_get(_KEY);
	return (array_length(_group.entitys) > _INDEX) ? 
		(_group.entitys[_INDEX] ) : 
		undefined;
}