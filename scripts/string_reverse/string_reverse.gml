/// @param {String} string/// @return {String}
function string_reverse(_str) {
	var _len = string_length(_str);
		
	var i=_len; repeat(_len) {
		_str += string_char_at(_str, i--);
	}	
	
	return _str;
}
