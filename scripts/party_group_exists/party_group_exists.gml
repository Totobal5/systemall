function party_group_exists(_KEY)
{
	return (variable_struct_exists(global.__mallPartyGroups, _KEY) );
}