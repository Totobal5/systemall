/// @param {instance} stick_to/// @param {number} x_offset
/// @param {number} y_offset
/// @param {number} angle_offset
function stick_to_angle(_ins, _x=0, _y=0, _angle=0) {
	var _dis = point_distance (_ins.x, _ins.y, _ins.x + _x, _ins.y + _y);
	var _dir = point_direction(_ins.x, _ins.y, _ins.x + _y, _ins.y + _y);
	
	// Pos
	x = _ins.x + lengthdir_x(_dis, _dir + _ins.image_angle);
	y = _ins.y + lengthdir_y(_dis, _dir + _ins.image_angle);
	
	// Angulo
	image_angle = _ins.image_angle + _angle;
}

