/**
 * Devuelve un grupo de party
 * @param {String} party_group_key
 * @return {Struct.PartyGroup}
 */
function party_group_get(_KEY)
{
	return (global.__mallPartyGroups[$ _KEY] );
}