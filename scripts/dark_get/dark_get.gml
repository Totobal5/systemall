/// @param {String} darkKey
/// @return {Struct.DarkCommand}
function dark_get(_darkKey) 
{ 
	static database = MallDatabase().dark.commands;
	return (database[$ _darkKey] );
}