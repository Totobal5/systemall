/// @param {Array}		array_index	(Contiene structs)
/// @param {Mixed}		value
/// @param {Function}	method		function(value, in, i) {return false or true}
/// @desc Se pasa un metodo en él se debe indicar si se encontro un valor o no. 
/// @return {Bool}
function array_find(_array, _value, _f) {
	var i=0; repeat(array_length(_array) ) {
		var _in = _array[i];
		if (_f(_value, _in, i) ) return true;
		i++;
	}
	
	return false;	
}
