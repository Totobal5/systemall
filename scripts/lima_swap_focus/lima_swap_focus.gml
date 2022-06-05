/// @param {Real} index
function lima_swap_focus(_index) {
	var _instance = __lima_swap_get(_index);
	// Solo si esta activo
	if (_instance.isActive) {
		_instance.isFocus = true;			
		_instance.alarm[_index] = delayKeys[_index];
			
		lima_template_execute("Select");
	}
	
	// Desactivar
	isFocus = false;
	alarm[_index] = delayKeys[_index];
	lima_template_execute("Deselect");
}

/// @param {Real} _index
/// @ignore
function __lima_swap_get(_index) {
	/// @context {lima_interactive_input}
	switch (_index) {
		case 0:	return selectUp;
		case 1: return selectLeft;
		case 2: return selectRight;
		case 3: return selectDown;
	}
}