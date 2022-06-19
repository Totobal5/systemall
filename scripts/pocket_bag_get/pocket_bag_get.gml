/// @param	{String}	bag_key
/// @desc	Regresa un bolsillo a partir de la llave
function pocket_bag_get(_key)
{
	return (global.__mall_pocket_bag[$ _key] );
}