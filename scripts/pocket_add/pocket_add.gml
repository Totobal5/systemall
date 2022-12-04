/// @desc Agrega un objeto a un al bag indicado. Queda guardado de la siguiente manera {key, count, index}
/// @param	{String}	bagKey
/// @param	{String}	itemKey
/// @param	{Real}		[count]=1
/// @param	{Any*}		[vars]
function pocket_add(_bagkey, _itemKey, _count=1, _vars)
{
	static database = MallDatabase().pocket.bags;
	var _bag = database[$ _bagkey];
	return (_bag.add(_itemKey, _count, _vars) );
}