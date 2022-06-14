/// @param	{String} part_key
/// @desc	Devuelve la estructura de la parte
/// @returns {Struct.MallPart}
function mall_get_part(_key) {
	return (mall_actual_group() ).__parts[$ _key];
}