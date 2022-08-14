/// @desc	Regresa un bolsillo a partir de la llave
/// @param	{String} bag_key
function pocket_bag_get(_KEY)
{
	return (global.__mallPocketBag[$ _KEY] );
}