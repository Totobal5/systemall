/// @param party_group_key
/// @desc Devuelve un grupo de party
/// @return {Array}
function party_group_get(_key)
{
	if (global.__mall_party_groups.exists(_key) )
	{
		// Crear party
		return (global.__mall_party_groups.get(_key) );	
	}
}