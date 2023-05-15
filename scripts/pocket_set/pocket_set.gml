/// @desc Inserta un bag en el indice seleccionado. De la siguiente manera {key, count, index}
/// @param	{String}	bagKey
/// @param	{String}	itemKey
/// @param	{Real}		[count]		default=1
function pocket_set(_bagKey, _itemKey, _count=1, _index=0, _vars={})
{
	static database = MallDatabase.pocket.bags;
	var _bag = database[$ _bagKey];
	// No salir de los limites
	_count = clamp(_count, MALL_POCKET_BAG_MIN, MALL_POCKET_BAG_MAX);
	return (_bag.set(_itemKey, _count, _index, _vars) );
}