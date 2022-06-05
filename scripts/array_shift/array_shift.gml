/// @param {array} array_index	El Array del que extraer
/// @desc Extrae el primer elemento de un array y lo elimina
/// @return {Mixed}
function array_shift(_array) {
	var _temp=_array[0];
	array_delete(_array, 0, 1);
	return _temp;
}