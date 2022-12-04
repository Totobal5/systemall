/// @param	{String}	bagKey
/// @param	{String}	itemKey
/// @return {Array}	Elimina el objeto en el bag 
function pocket_remove(_bagKey, _itemKey)
{
	var bag  = pocket_get(_bagKey);
	return (bag.remove(_itemKey) );
}