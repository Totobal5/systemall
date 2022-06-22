/// @param {String} state_key
/// @desc Obtiene el estado en el grupo actual
/// @return {Struct.MallState}
function mall_get_state(_key)
{
	return (mall_group_get_actual().__states[$ _key] );
}