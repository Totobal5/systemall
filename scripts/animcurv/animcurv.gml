/// @param animation_curve
/// @param channel
/// @param {mixed} val1
/// @param {mixed} val2
/// @param duration
/// @param [seconds]
function animcurv(_animcurv, _channel, _val1, _val2, _duration, _seconds=true){
	var _speed = (_seconds) ? game_get_speed(gamespeed_fps) : game_get_speed(gamespeed_microseconds);
	var _delta = (delta_time / 1000000) * _duration * _speed;
	
	var _chann = animcurve_get_channel(_animcurv, _channel);
	var _inter = animcurve_channel_evaluate(_chann, _delta);
	
	return (lerp(_val1, _val2, _inter) );
}