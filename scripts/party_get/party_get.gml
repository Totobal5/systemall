/// @param {String} party_group
/// @param {Real} [party_index]=0
/// @return {Struct.PartyEntity}
function party_get(_key, _index=0)
{
	var _group = party_group_get(_key);
	if (!is_undefined(_group) ) {
		return _group.get(_index);
	}
	
	// Feather disable once GM1045
	return undefined;
}