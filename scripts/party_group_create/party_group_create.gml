/// @desc Crea una party en donde se agregan entidades de party
/// @param	{String} partyGroupKey
function party_group_create(_key)
{
	// Cache
	static group = MallDatabase().party.groups;
	group[$ _key] ??= new PartyGroup(_key);
	return (group[$ _key] );
}