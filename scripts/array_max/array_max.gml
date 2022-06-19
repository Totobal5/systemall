/// @param {Array<Real>} array_index
/// @desc Devuelve el mayor numero en un array (Default=1)
/// @returns {Real} 
function array_max(_array) {
	var _temp = 1;
	
	if (!array_empty(_array) ) {
		_temp = _array[0];
		var i=1; repeat(array_length(_array) - 1) {
			var _in = _array[i++];
			_temp = max(_temp, _in);
		}
	}
	
	return (_temp);
}