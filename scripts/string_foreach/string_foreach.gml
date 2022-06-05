/// @param {String} string/// @param {Function} method
function string_foreach(_str, _method) {
	var _get = undefined;
	var i=1; repeat(string_length(_str) ) {
		_get = _method(string_copy(_str, 1, i), i++);
	}
	
	return (_get);
}
