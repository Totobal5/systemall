/// @desc Comprueba si el objeto existe en la base de datos
/// @param {String} pocketKey
function pocket_data_exists(_itemKey) 
{
	static data = MallDatabase.pocket.items;
    return (variable_struct_exists(data, _itemKey) );
}