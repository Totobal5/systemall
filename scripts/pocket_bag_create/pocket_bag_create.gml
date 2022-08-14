/// @param	{String} bag_key
function pocket_bag_create(_KEY)
{
	if (!variable_struct_exists(global.__mallPocketBag, _KEY) )
	{
		var _bag = {order: [], items:{} };
		global.__mallPocketBag[$ _KEY] = _bag;
		
		return (_bag);
	}
}