/// @param	{String}	bag_key		
/// @return {Array}
function pocket_bag_create(_key)
{
	if (!variable_struct_exists(global.__mall_pocket_bag, _key) )
	{
		var _array = []
		global.__mall_pocket_bag[$ _key] = _array;
		
		return (_array);
	}
}