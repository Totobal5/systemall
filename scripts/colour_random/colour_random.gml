/// @desc Devuelve un color al azar
function colour_random() {
	var _red   = irandom(255);
	var _green = irandom(255);
	var _blue  = irandom(255);
	
	return (make_color_rgb(_red, _green, _blue) );
}

/// @desc Devuelve un color al azar
function color_random() {
	return (colour_random() );	
}