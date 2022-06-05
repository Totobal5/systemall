/// @param {Real} index
/// @param {Real} value
/// @param {Bool} [seconds?]
/// @param [instance]
function alarm_delay(_index, _value, _seconds=false, _ins=id) {
	var _delta = (delta_time / 1000000)
	if (_ins == id) {
		if (alarm_off(_index) ) {
			alarm[_index] = _seconds ? 
				(_value * _delta * game_get_speed(gamespeed_fps) ) : 
				(_value * _delta);
		}
	}
	else with (_ins) alarm_delay(_index, _value, _seconds, id);
}