/// @param {Real} seconds
function string_time_hms(_seconds) {
	var _hours		= _seconds div 3600;
	_seconds		= _seconds mod 3600;
	var _minutes	= _seconds div 60;
	_seconds		= _seconds mod 60;
    
	return    ((_hours   div 10) > 0 ? "" : "0") + string(_hours  ) + ":"
	        + ((_minutes div 10) > 0 ? "" : "0") + string(_minutes) + ":" 
	        + ((_seconds div 10) > 0 ? "" : "0") + string(floor(_seconds));
}