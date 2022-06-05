/// @param {String} _key
/// @desc Regresa una configuracion de parte del grupo actual
/// @returns {Struct.MallPart}
function mall_get_part(_key) {
	return (mall_actual_group() ).__parts[$ _key];
}