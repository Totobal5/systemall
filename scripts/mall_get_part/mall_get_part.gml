/// @param	{String} part_key
/// @desc	Devuelve la estructura de la parte
/// @returns {Struct.MallPart}
function mall_get_part(_key) {
	return (mall_group_get_actual() ).__parts[$ _key];
}