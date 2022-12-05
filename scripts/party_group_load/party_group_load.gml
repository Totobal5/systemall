/// @param {String} partyGroupKey
/// @param {Struct} loadStruct
function party_load(_groupKey, _loadStruct)
{
	var _party = party_group_get(_groupKey);
	return (_party.load(_loadStruct) );
}