/// @param	{String}	bag_key
/// @param	{String}	item_key
/// @return {Array}	Elimina el objeto en el bag 
function pocket_bag_delete_item(_key, _item_key)
{
	var _bag = pocket_bag_get(_key);
	var i=0; repeat(array_length(_bag) )
	{
		var _item = _bag[i];		
		if (_item_key == _item[0] ) break;	
		++i;
	}
	
	// Eliminar
	array_delete(_bag, i, 1);
	
	return undefined;	
}