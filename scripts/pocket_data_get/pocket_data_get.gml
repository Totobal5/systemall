/// @desc Obtiene la informacion del objeto desde la base de datos
/// @param {String} itemKey
/// @return {Struct.PocketItem}
function pocket_data_get(_itemKey) 
{
	static data = MallDatabase.pocket.items;
	return (data[$ _itemKey] );
}