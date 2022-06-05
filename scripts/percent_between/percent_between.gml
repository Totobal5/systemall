/// @param {Real} percent
/// @returns {Real}
function percent_between(_percent) {
	return (_percent - random(_percent) ) / max(0.01, _percent);
}