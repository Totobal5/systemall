/// @param {Vector2} vector2
function is_vector2(_vec2)	 {
	return (is_struct(_vec2) && (_vec2.__is == 0) );
}

/// @param {Line} line
function is_line(_line) 	 {
	return (is_struct(_line) && (_line.__is == 1) );	
}

/// @param {Rectangle} rectangle
function is_rectangle(_rect) {
	return (is_struct(_rect) && (_rect.__is == 2) );	
}
