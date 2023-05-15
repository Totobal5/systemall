// Feather ignore all
/// @param {string} functionKey
/// @return {function}
function dark_get_function(_key)
{
	static database = MallDatabase.dark.functions;
	if (variable_struct_exists(database, _key) ) {
		return (database[$ _key]);
	}
	
	return undefined;
}