/// @param {String} dark_key
/// @param {String} dark_type
/// @param {Struct.DarkCommand} _spell
function dark_add(_key, _type, _spell) 
{
	// Añadir llave
    if (!dark_exists(_key) ) 
	{
		global.__mall_dark_database[$ _key] = (_spell.setType(_type) ).setKey(_key);
    }
    
    return (_spell);
}