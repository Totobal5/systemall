/// @desc	Regresa un bolsillo a partir de la llave
/// @param	{String} bagKey
/// @return {Struct.PocketBag}
function pocket_get_bag(_bagKey)
{
	static database = MallDatabase.pocket.bags;
	return (database[$ _bagKey] );
}