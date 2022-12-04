/// @param	{String}	bagKey
/// @param	{String}	itemKey
/// @return {Array}	Elimina el objeto en el bag 
function pocket_remove(_bagKey, _itemKey)
{
	static database = MallDatabase().pocket.bags;
	var _bag = database[$ _bagkey];
	return (_bag.remove(_itemKey) );
}