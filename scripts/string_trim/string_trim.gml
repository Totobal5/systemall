/// @param {String} string/// @return {String}
function string_trim(_str) {
	var len = string_length(_str);
	var i=1; repeat(len) {
		var _char = string_char_at(_str, i);
		if (!string_pos(_str, _char) == " ") break;
		i++;
	}
	
	repeat(len) {
		var _char = string_char_at(_str, len);
		if (!string_pos(_str, _char) == " ") break;
		len--;
	}
	
	return (string_copy(_str, i, len) );
}
