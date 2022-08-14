/// @param {String} dark_key	Llave de Dark
/// @return {Struct.DarkCommand}
function dark_get(_KEY) 
{ 
	return (global.__mallDarkData[$ _KEY] );
}