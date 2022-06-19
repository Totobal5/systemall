/// @param {Resource.GMSprite}	pixel_sprite		Sprite 1x1, white and origin 0,0
/// @param {Real}				x1
/// @param {Real}				y1
/// @param {Real}				x2
/// @param {Real}				y2
/// @param {Real}				[width]				default: 1
/// @param {Constan.Color}		[color]				default: draw_get_color()
/// @param {Real}				[alpha]				default: draw_get_alpha()	
/// @desc Dibuja una linea usando un sprite (mucho más rapido que draw_line)
function draw_line_sprite(_pixel, _x1, _y1, _x2, _y2, _width=1, _color, _alpha) {
	_color ??= draw_get_color();
	_alpha ??= draw_get_alpha();	
	
	var _dir = point_direction(_x1, _y1, _x2, _y2);
	var _len =  point_distance(_x1, _y1, _x2, _y2);
	
	var _lx = _x1 + lengthdir_x(_width / 2, _dir + 90);
	var _ly = _y1 + lengthdir_y(_width / 2, _dir + 90);
	draw_sprite_ext(_pixel, 0, _lx, _ly, _len, _width, _dir, _color, _alpha);
}