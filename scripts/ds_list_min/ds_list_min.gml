/// @param {Id.DsList} id
/// @desc Devuelve el menor numero en una lista (Default=0)
/// @returns {Real} 
function ds_list_min(_list) {
	if (!ds_exists(_list, ds_type_list) ) show_error("Not an ds_list", true);
	var _temp = 0;
	
	if (!ds_list_empty(_list) ) {
		_temp = _list[| 0];
		var i=1; repeat(ds_list_size(_list) - 1) {
			var _in = _list[| i++];
			_temp = min(_temp, _in);
		}
	}
	
	return (_temp);
}