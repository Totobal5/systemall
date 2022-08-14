/// @desc Crea una party en donde se agregan entidades de party
/// @param	{String} party_group_key
function party_group_create(_KEY)
{
	var _partyGroup = undefined;
	if (!variable_struct_exists(global.__mallPartyGroups, _KEY) )
	{	
		var _partyGroup = {__order: [] };
		global.__mallPartyGroups[$ _KEY] = _partyGroup;
	}
	return (_partyGroup );
}