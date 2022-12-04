/// @desc Crea una bolsa para agregar objetos
/// @param	{String} bagKey
/// @param	{Function} initFunction
/// @return {Struct.PocketBag}
function pocket_create_bag(_bagKey, _initFun)
{
	static database = MallDatabase().pocket.bags;
	if (!variable_struct_exists(database, _bagKey) ) {
		database[$ _bagKey] = new PocketBag(_initFun);
		if (MALL_POCKET_TRACE) show_debug_message("MallRPG Pocket: {0} se ha creado", _bagKey);
	}
	
	return (database[$ _bagKey] );
}