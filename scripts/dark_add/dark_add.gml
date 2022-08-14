/// @param {String}	dark_key
/// @param {Struct.DarkCommand} command
function dark_add(_KEY, _COMMAND) 
{
	// Añadir llave
    if (!dark_exists(_KEY) ) global.__mallDarkData[$ _KEY] = _COMMAND.setKey(_KEY);
    return (_COMMAND);
}