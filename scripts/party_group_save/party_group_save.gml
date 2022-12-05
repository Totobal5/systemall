/// @param {String} partyGroupKey
function party_group_save(_groupKey)
{
	var _party = party_group_get(_groupKey);
	return (_party.save() );
}
