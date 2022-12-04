/// @desc Devuelve un grupo de party
/// @param {String} party_group
/// @return {Struct.PartyGroup}
function party_group_get(_KEY)
{
	// Feather disable once GM1045
	static group = MallDatabase().party.groups;
	return (group[$ _KEY] );
}