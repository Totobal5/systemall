/// @param	{String}	bag_key
/// @param	{String}	item_key
/// @param	{Real}		[count]		default=1
/// @desc Agrega un objeto a un al bag indicado. De la siguiente manera [ [item_key, count, index] ]
function pocket_bag_add(_KEY, _ITEM_KEY, _COUNT=1)
{
	var _item  = pocket_bag_get_item(_KEY, _ITEM_KEY);
	if (_item != undefined)
	{
		var _incount = _item[1];
		// Sacar el resto
		var _sum  = (_incount + _COUNT);
		var _rest = max(0, _sum - POCKET_BAG_MAX);
		
		// Añadir cuenta
		_item[1] = min(POCKET_BAG_MAX, _sum);
		
		// Se quito
		if (_item[1] <= POCKET_BAG_MIN)
		{
			var _bag = pocket_bag_get(_ITEM_KEY);
			// Eliminar array
			array_delete(_bag, _item[2], 1);
		}
	}
	// No existe
	else
	{
		// Añadir al bag
		var _bag = pocket_bag_get(_KEY);
		var _len = array_length(_bag);
		array_push(_bag, [
			_ITEM_KEY, 
			_COUNT, 
			_len
		]);
	}
}