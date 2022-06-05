/// @param {String} string
/// @param {String} delimeter
/// @param {String} not_found
function string_explode(_str, _delimeter, _not="") {
	var _count = string_count(_delimeter, _str);
	var _len   = string_length(_delimeter);	
	var _array = []; repeat(_count) {	
		var _pos = string_pos (_delimeter, _str) - 1;	// Obtener posicion
		var _cpy = string_copy(_str, 1, _pos);
		
		// Agregar al array
		array_push(_array, _cpy);
		_str = string_delete(_str, 1, _pos + _len);
	}
			
	// Lo que queda agregar al final.
	if (array_length(_array) <= 0) _array[0] = _not;

	return _array;			
}
