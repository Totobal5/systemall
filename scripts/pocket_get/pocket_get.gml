/// @desc	Regresa un objeto de un bolsillo
/// @param	{String}      bagKey    Llave del bolsillo
/// @param	{String,Real} [item]=0  Puede ser un indice o un itemKey
/// @param	{String,Real} [flags]=0 Variables a pasar
/// @return {Struct.PocketBag}
function pocket_get(_bagKey, _key=0, _flags)
{
	static database = MallDatabase().pocket.bags;
	var _bag = database[$ _bagKey];
	// Si es a partir del indice
	if (is_numeric(_key) ) {_key = _bag.order[_key]; }
	return (_bag.get(_key, _flags) );
}