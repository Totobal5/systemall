/// @desc Agrega un objeto a un al bag indicado. Queda guardado de la siguiente manera {key, count, index}
/// @param	{String}	bagKey
/// @param	{String}	itemKey
/// @param	{Real}		[count]=1
/// @param	{Any*}		[vars]
function pocket_add(_key, _itemKey, _count=1, _vars)
{
	var _bag  = pocket_bag_get(_key);
	return (_bag.add(_itemKey, _count, _vars) );
}