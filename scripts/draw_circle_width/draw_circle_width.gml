/// @param	{Real} x
/// @param  {Real} y
/// @param  {Real} radius
/// @param  {Real} outline_width
/// @param  {Real} detail
/// @desc	A large outline width can cause artifacts, especially on low resolutions. 
///			Experiment with different values, or alternatively try increasing the size of the application surface.
function draw_circle_width(_x, _y, _radius, _outline_width, _detail) {
	//use foor loop to draw the circle with draw_line_width
	for (var i=0; i<360; i += 360 / _detail) 
	{
		var _cx = _x + lengthdir_x(_radius, i), _lx = _x + lengthdir_x(_radius, i + 360 / _detail);
		var _cy = _y + lengthdir_y(_radius, i), _ly = _y + lengthdir_y(_radius, i + 360 / _detail);
	    draw_line_width(_cx, _cy, _lx, _ly, _outline_width)
	}
}