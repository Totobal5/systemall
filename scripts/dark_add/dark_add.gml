/// @param {String} _key
/// @param {String} _type
/// @param {Struct.DarkSpell} _spell
function dark_add(_key, _type, _spell) {
    if (!dark_exists(_key) ) {
		// Añadir llave
		_spell.setKey(_key);
		global.__mall_dark_database[$ _key] = _spell.setType(_type);
    }
    
    return (_spell);
}