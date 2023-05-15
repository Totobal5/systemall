/// @param {Struct.DarkCommand} command
/// @param {string}             [displayKey]
function dark_create_command(_darkCommand, _displayKey) 
{
	static database     = MallDatabase.dark.commands;
	static DebugMessage = MallDatabase.darkDebugMessage;
	
	var _key = _darkCommand.key;
	if (!variable_struct_exists(database, _key) ) {
		database[$ _key] = _darkCommand.setDisplayKey(_displayKey);
		if (MALL_DARK_TRACE) DebugMessage("(CreateCommand): " + _key + " creado");
	}
	return (_darkCommand);
}