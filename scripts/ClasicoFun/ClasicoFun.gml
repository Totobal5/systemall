#macro START_TIMER	var time1, time2; time1 = get_timer();
#macro END_TIMER	time2 = get_timer(); show_debug_message("time: " + string( (time2 - time1) / 1000) + " [ms]");

#region Is
/// @param {Vector2} vector2
function is_vector2(_vec2) {
	return (is_struct(_vec2) && (_vec2.__is == 0) );
}

/// @param {Line} line
function is_line(_line) {
	return (is_struct(_line) && (_line.__is == 1) );	
}

/// @param {Rectangle} rectangle
function is_rectangle(_rect) {
	return (is_struct(_rect) && (_rect.__is == 2) );	
}

/// @param {Data} data
function is_data(_data) {
	return (is_struct(_data) && variable_struct_exists(_data, "__isdata") );	
}

/// @param {Data} data
function is_dataext(_data) {
	if (is_data(_data) ) {return true; } else if (is_numeric(_data) ) {return false; } else {return noone; }
}

#endregion

#region Percent
/// @param porcent
/// @returns {bool}
function percent_chance(_porcent) {
	return (random(100) <= _porcent);
}

/// @param porcent
/// @returns {number}
function percent_between(_porcent) {
	return (_porcent - random(_porcent) ) / _porcent;
}


#endregion