/// @param key
/// @param {Struct.PocketItem} pocket_item
/// @desc Crea un objeto y lo agrega a la base de datos
/// @return {Struct.PocketItem}
function pocket_item_add(_key, _item) {
    if (!pocket_item_exists(_key) ) {
		_item.setKey(_key);  
		_item.setDisplay();
		
        global.__mall_pocket_database[$ _key] = _item;
        return (_item);
    } else {
        show_error("POCKET: ITEM" + string(_key) + "YA EXISTE", true);
    }    
    
    return _item;    
}