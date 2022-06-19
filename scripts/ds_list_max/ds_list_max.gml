/// @param {Id.DsList} id
/// @desc Devuelve el mayor numero en una lista (Default=1)
/// @returns {Real} 
function ds_list_max(_list) {
	if (!ds_exists(_list, ds_type_list) ) show_error("Not an ds_list", true);
	var _temp = 1;
	
	if (!ds_list_empty(_list) ) {
		_temp = _list[| 0];
		var i=1; repeat(ds_list_size(_list) - 1) {
			var _in = _list[| i++];
			_temp = max(_temp, _in);
		}
	}
	
	return (_temp);
}