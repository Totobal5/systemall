/// @param {Resource.GMSprite}	pixel_sprite		Sprite 1x1, white and origin 0,0
/// @param {Real}				x1
/// @param {Real}				y1
/// @param {Real}				x2
/// @param {Real}				y2
/// @param {Bool}				outline
/// @param {Constan.Color}		color
/// @param {Real}				alpha
/// @desc Dibuja un rectangulo usando un sprite (mucho más rapido que draw_rectangle)
function draw_rectangle_sprite(_pixel, _x1, _y1, _x2, _y2, _outline, _color, _alpha) {
	_color ??= draw_get_color();
	_alpha ??= draw_get_alpha();
  
	//Outline
	if (_outline)
	{ 
	  //top
	  draw_sprite_ext(_pixel,0, _x1 + 1, _y1, _x2 - (_x1 - 2), 1, 0, _color,_alpha);
	  //bottom 
	  draw_sprite_ext(_pixel,0, _x1, _y2 - 1, _x2 - _x1, 1, 0, _color,_alpha);
	  //left 
	  draw_sprite_ext(_pixel,0, _x1, _y1, 1, _y2 - (_y1 - 1), 0, _color,_alpha);
	  //rirght
	  draw_sprite_ext(_pixel,0, _x2-1,_y1, 1, _y2 - (_y1 - 1), 0, _color,_alpha);
	}
	//Filled
	else
	{ 
	  draw_sprite_ext(_pixel, 0, _x1, _y1, _x2 -_x1, _y2 - _y1, 0, _color, _alpha);
	}
}