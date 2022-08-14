/// @desc Obtiene un modificador en el grupo actual
/// @param {String} modify_key
/// @return {Struct.MallModify}
function mall_get_modify(_KEY)
{
	return (global.__mallModifyMaster[$ _KEY] );
}