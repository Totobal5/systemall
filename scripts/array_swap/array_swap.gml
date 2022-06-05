/// @param {Array} array
/// @param {Real} source
/// @param {Real} destination
/// @desc Intercambia valores entre un index y otro
function array_swap(_array, _i, _j) {
	var _temp = _array[_i];
	
	_array[_i] = _array[_j];
	_array[_j] = _temp;
}