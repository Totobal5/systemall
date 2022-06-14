/// @param {String} element_key
/// @desc Obtiene un elemento en el grupo actual
/// @return {Struct.MallElement}
function mall_get_element(_key){
	return (mall_actual_group().__elements[$ _key] );
}