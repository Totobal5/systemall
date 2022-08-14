/// @param	{String}	bag_key
/// @param	{String}	item_key
/// @return {Array}	Devuelve 
function pocket_bag_get_item(_KEY, _ITEM_KEY)
{
	var _bag = pocket_bag_get(_KEY);
	var i=0; repeat(array_length(_bag) )
	{
		var _item = _bag[i];
		if (_ITEM_KEY == _item[0] ) return _item;
		++i;
	}
	
	return undefined;
}