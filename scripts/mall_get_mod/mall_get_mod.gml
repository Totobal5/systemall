/// @param {String} mod_key
/// @desc Obtiene un modificador en el grupo actual
/// @return {Struct.MallMod}
function mall_get_mod(_KEY)
{
	return (global.__mallModsMaster[$ _KEY] );
}