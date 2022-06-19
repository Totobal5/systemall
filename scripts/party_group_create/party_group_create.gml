/// @param party_group_key
/// @desc Crea una party en donde se agregan entidades de party
function party_group_create(_key)
{
	if (!global.__mall_party_groups.exists(_key) )
	{
		// Crear party
		global.__mall_party_groups.set(_key, []);	
	}
}