/// @desc Crea una bolsa para agregar objetos
/// @param	{String} bag_key
/// @param	{Function} init_function
/// @return {Struct.PocketBag}
function pocket_create_bag(_bagKey, _initFun)
{
	static database = MallDatabase().pocket.bags;
	if (!variable_struct_exists(database, _bagKey) ) {
		database[$ _bagKey] = new PocketBag(_initFun);
	}
	
	return (database[$ _bagKey] );
}