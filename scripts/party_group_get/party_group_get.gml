/// @desc Devuelve un grupo de party
/// @param {string} groupKey
/// @return {Struct.PartyGroup}
function party_group_get(_KEY)
{
	// Feather disable once GM1045
	static group = MallDatabase.party.groups;
	return (group[$ _KEY] );
}

/// @desc Devuelve un grupo de party
/// @param {string} groupKey
function party_group_get_entities(_KEY)
{
	// Feather disable once GM1045
	static group = MallDatabase.party.groups;
	return (group[$ _KEY].getEntities() );
}