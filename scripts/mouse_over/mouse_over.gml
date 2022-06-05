/// @desc True si el mouse esta en la bounding box de la instancia.
/// @return {bool} 
function mouse_over() {
	return (
		mouse_x >= bbox_left	&&
	    mouse_x <= bbox_right	&&
	    mouse_y >= bbox_top		&&
	    mouse_y <= bbox_bottom
	);
}
