/// @param {Bool} _visible
/// @param {Bool} _active
/// @param {Bool} _focus
function lima_set_states(_visible, _active, _focus) {
	isVisible = _visible ?? isVisible;
	isActive  =  _active ??  isActive;
	isFocus	  =   _focus ??   isFocus;
}