/// @desc Limpia la lista de entidades de este grupo
/// @param {String} partyGroupKey
function party_clean(_groupKey) 
{
	var _party = party_group_get(_groupKey);
	return (_party.clean() );
}