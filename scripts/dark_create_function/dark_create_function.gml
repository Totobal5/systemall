// Feather ignore all
/// @desc Function Description
/// @param {string}   funKey   Description
/// @param {function} function Description
function dark_create_function(_key, _function)
{
	static database = MallDatabase().dark.commands;
	if (!variable_struct_exists(database, _key) ) {
		database[$ _key] = _function;
		if (MALL_DARK_TRACE) show_debug_message("MallRPG Dark: {0} creado", _key);
	}
}