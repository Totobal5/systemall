/// @param {Array} array_index
/// @desc Devuelve un array al revez
/// @return {Array} 
function array_reverse(_array) {
	var _rev = [];
	var _len = array_length(_array) - 1;
	
	var i=0; repeat(_len + 1) {
		array_push(_rev, _array[_len - i++] ); 
	}
	
	return _rev;
}
