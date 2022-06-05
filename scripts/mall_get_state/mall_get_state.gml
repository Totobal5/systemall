/// @param {String} _key
/// @desc Obtiene el estado en el grupo actual
/// @return {Struct.MallState}
function mall_get_state(_key){
	return (mall_actual_group().__states[$ _key] );
}