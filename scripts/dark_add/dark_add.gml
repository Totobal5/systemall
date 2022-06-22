/// @param {String}				command_key
/// @param {Struct.DarkCommand} command
function dark_add(_key, _command) 
{
	// Añadir llave
    if (!dark_exists(_key) ) 
	{
		global.__mall_dark_database[$ _key] = _command;
    }
    
    return (_command);
}