/// @param {Struct.DarkCommand, Function} command
/// @param {string}             [displayKey]
function dark_add(_darkCommand, _displayKey) 
{
	static database = MallDatabase().dark.commands;
	if (!variable_struct_exists(database, _darkCommand.key) ) {
		database[$ _darkCommand.key] = _darkCommand.setDisplayKey(_displayKey);
	}
	return (database[$ _darkCommand.key] );
}