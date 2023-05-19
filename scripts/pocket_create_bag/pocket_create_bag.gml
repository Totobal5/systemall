/// @desc Crea una bolsa para agregar objetos
/// @param {String} bagKey
/// @param {Struct.PocketBag} bag
/// @return {Struct.PocketBag}
function pocket_create_bag(_bagkey, _bag)
{
	static database = MallDatabase.pocket.bags;
	if (!struct_exists(database, _bagkey) ) {
		database[$ _bagkey] = _bag;
		if (__MALL_PARTY_TRACE) show_debug_message("MallRPG Pocket: {0} se ha creado", _bagkey);
	}
	return _bag;
}