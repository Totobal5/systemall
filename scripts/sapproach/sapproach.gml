/// @param {Real} a
/// @param {Real} b
/// @param {Real} step
/// @desc Smooth approach
/// @returns {Real}
function sapproach(_a, _b, _step) {
	var _delta = _b - _a;
	return ((abs(_delta) < 0.0005) ? 
		_b	:
		(_a + sign(_delta) * abs(_delta) * _b)
	);
}