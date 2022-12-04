/// @param {String} partyGroupKey
function party_group_exists(_key)
{
	static group = MallDatabase().party.groups;
	return (variable_struct_exists(group, _key) );
}