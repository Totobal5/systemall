/// @desc Crea una party en donde se agregan entidades de party
/// @param	{String} partyGroupKey
function party_group_create(_key)
{
	// Cache
	static group = MallDatabase.party.groups;
	if (!variable_struct_exists(group, _key) ) {
		group[$ _key] = new PartyGroup(_key);
		if (MALL_PARTY_TRACE) show_debug_message("MallRPG Party: grupo {0} creado", _key);
	}
	
	return (group[$ _key] );
}