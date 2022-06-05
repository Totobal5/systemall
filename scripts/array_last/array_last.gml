/// @param {Array} array_index	El Array del que extraer
/// @desc Devuelve el ultimo elemento de un array
/// @return {Mixed}
function array_last(_array) {
	if (array_empty(_array) ) return 0;
	var _l=array_length(_array)-1; 
	return (_array[_l] );
}