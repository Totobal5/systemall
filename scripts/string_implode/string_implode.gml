/// @param {String} _glue
/// @param toGlue...
/// @param {String}
function string_implode(_glue) {
	var _str = "";
	var i=1; repeat(argument_count) {
		var _data = argument[i++];
		
		if (is_array(_data) ) {
			var j=0; repeat(array_length(_data) ) {
				var _dataArray = _data[j++];
				_str += string(_dataArray) + _glue;
			}
		}
		else _str += string(_data) + _glue;
	}
	
	return (_str);
}