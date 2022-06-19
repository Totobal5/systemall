/// @param	{String}			pocket_key
/// @param	{Struct.PocketItem} pocket_item
/// @desc	Crea un objeto y lo agrega a la base de datos
/// @return {Struct.PocketItem}
function pocket_add(_key, _item) 
{
    if (!pocket_exists(_key) ) 
	{
        global.__mall_pocket_database[$ _key] = _item.setKey(_key);
    }
	
    return _item;    
}