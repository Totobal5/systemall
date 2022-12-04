/// @desc	Crea un objeto y lo agrega a la base de datos
/// @param	{Struct.PocketItem} pocketItem
/// @param	{String}            [displayKey]
/// @return {Struct.PocketItem}
function pocket_data_create(_item, _displayKey) 
{
	static data = MallDatabase().pocket.items;
	if (!variable_struct_exists(data, _item.key) ) {
		data[$ _item.key] = _item.setDisplayKey(_displayKey);
	}
	return (_item );
}