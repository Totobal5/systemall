/// @param {Real} a
/// @param {Real} b
/// @param {Real} step
/// @returns {Real}
function approach(a, b, _step) {
	return (a < b) ? 
		min(a + abs(_step), b): 
		max(a - abs(_step), b);
}