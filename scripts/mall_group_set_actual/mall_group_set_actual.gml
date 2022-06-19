/// @param {String}	group_key
/// @desc Establece un nuevo grupo actual para modificar
function mall_group_set_actual(_key)
{
	// Solo si existe la llave
	if (global.__mall_groups_master.exists(_key) )
	{
		global.__mall_group_actual = mall_get_group(_key);	
	}
}