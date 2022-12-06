// Feather ignore all
/// @param {string} functionKey
/// @return {function}
function dark_get_function(_key)
{
	static ret = function() {};
	static database = MallDatabase().dark.functions;
	return (database[$ _key] ?? ret);
}