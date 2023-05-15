/// @desc Agrega un objeto a un al bag indicado. Queda guardado de la siguiente manera {key, count, index}
/// @param	{String}	bagKey
/// @param	{String}	itemKey
/// @param	{Real}		[count]=1
/// @param	{Any*}		[vars]
/// @param	{function}	[addFunction]
function pocket_add(_bagkey, _itemKey, _count=1, _vars, _fn)
{
	static fun = function() {};
	static database = MallDatabase.pocket.bags;
	var _bag = database[$ _bagkey];
	var _ret = _bag.add(_itemKey, _count, _vars);
	// Si es undefined
	_fn ??= fun;
	_fn();
	
	return _ret;
}