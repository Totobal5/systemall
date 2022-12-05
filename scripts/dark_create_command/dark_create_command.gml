/// @param {Struct.DarkCommand} command
/// @param {string}             [displayKey]
function dark_create_command(_darkCommand, _displayKey) 
{
	static database = MallDatabase().dark.commands;
	var _key = _darkCommand.key;
	if (!variable_struct_exists(database, _key) ) {
		database[$ _key] = _darkCommand.setDisplayKey(_displayKey);
		if (MALL_DARK_TRACE) show_debug_message("MallRPG Dark: {0} creado", _key);
	}
	return (_darkCommand);
}