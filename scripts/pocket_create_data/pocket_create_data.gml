/// @desc	Crea un objeto y lo agrega a la base de datos
/// @param	{Struct.PocketItem} pocketItem
/// @param	{String}            [displayKey]
/// @return {Struct.PocketItem}
function pocket_create_data(_item, _displayKey) 
{
	static data = MallDatabase.pocket.items;
	if (!variable_struct_exists(data, _item.key) ) {
		var _itemKey = _item.key;
		data[$ _itemKey] = _item.setDisplayKey(_displayKey ?? _itemKey);
	}
	return (_item );
}