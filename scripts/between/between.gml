/// @param {Real} range_a
/// @param {Real} range_b
/// @param {Real} value
/// @returns {Bool}
/// @desc Si un valor se encuentra entre a y b
function between(_ra, _rb, _val) {
	return (
		min(_ra, _rb) < _val && 
		max(_ra, _rb) > _val
	);
}