/// @param {Array} _array
/// @desc Devuelve el menor numero en un array (Default=0)
/// @returns {Real} 
function array_min(_array) {
	var _temp=0;
	
	if (!array_empty(_array) ) {
		_temp = _array[0];
		var i=1; repeat(array_length(_array) - 1) {
			var _in = _array[i++];
			_temp = min(_temp, _in);
		}
	}
	
	return (_temp);
}

