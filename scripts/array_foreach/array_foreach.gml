/// @param {Array} array_index
/// @param method function(value, i)
/// @desc Ejecuta una funcion por cada elemento de array
function array_foreach(_array, _f) {
	var i=0;repeat(array_length(_array) ) {
		_f(_array[i], i++);
	}
}