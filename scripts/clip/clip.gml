/// @param {Real} val
/// @param {Real} min	
/// @param {Real} max	
/// @desc Si valor es menor que minimo devuelve maximo y si valor es mayor que maximo devuelve minimo.
/// @returns {Real}
function clip(_data, _min, _max) {
	return max(_min, min(_max, _data) );
}