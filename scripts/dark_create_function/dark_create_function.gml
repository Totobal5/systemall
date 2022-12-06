// Feather ignore all
/// @desc Crea una funcion en el sistema de dark
/// @param {string}   funKey   Llave de la función
/// @param {function} function funcion a ejecutar
function dark_create_function(_key, _function)
{
	static database = MallDatabase().dark.functions;
	if (!variable_struct_exists(database, _key) ) {
		database[$ _key] = _function;
		if (MALL_DARK_TRACE) show_debug_message("MallRPG Dark: {0} creado", _key);
	}
}