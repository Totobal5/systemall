/// @return {Struct.PartyEntity}
function party_get(_key, _index)
{
	if (_index < 0) return (undefined);
	var _group = party_group_get(_key);
	return (_group[_index] );
}