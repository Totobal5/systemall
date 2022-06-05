/// @param {Array} array_index
/// @param method function(value, i)
/// @desc Devuelve un array a travez de una función establecida
/// @returns {Array<Mixed>}
function array_map(_array, _f) {
	var _return = [];
	var i=0; repeat(array_length(_array) ) {
		array_push(_return, _f(_array[i], i++) );
	}
	
	return _return;
}