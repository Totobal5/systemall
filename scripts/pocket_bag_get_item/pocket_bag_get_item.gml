/// @param	{String}	bag_key
/// @param	{String}	item_key
/// @return {Array}	Devuelve 
function pocket_bag_get_item(_key, _item_key)
{
	var _bag = pocket_bag_get(_key);
	var i=0; repeat(array_length(_bag) )
	{
		var _item = _bag[i];		
		if (_item_key == _item[0] ) return _item;	
		++i;
	}
	
	return undefined;
}