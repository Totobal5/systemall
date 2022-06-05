/// @param {Real} left		x1	
/// @param {Real} top		y1	
/// @param {Real} right		x2	
/// @param {Real} bottom	y2	
/// @return {Bool}
/// @desc True si el mouse esta en la region rectangular
function mouse_is_here(_x1, _y1, _x2, _y2) {
	return (
		(mouse_x > _x1) && (mouse_x < _x2) && 
		(mouse_y > _y1) && (mouse_y < _y2) 
	);
}