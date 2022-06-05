///	@param {Real} index
/// @return {Bool}
function lima_input_delay_possible(_index) {
	return (delayKeys[_index] <= -1);
}

/// @param {Real} index
/// @param {Real} [new_delay]
function lima_input_delay_reset(_index, _value) {
	/// @context {lima_button_input}
	delayKeys[_index] = _value ?? __delayKeys[_index];
}