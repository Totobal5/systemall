/// @description [DRAW SLIDER]
draw_set_alpha(image_alpha);
if (sliderSprite != -1) {
	var _color = draw_get_color();
	var _x = x + sliderXoffset;	
	var _y = y + sliderYoffset;
	
	var _relation = (slider / sliderMax);
	
	// Mover un slider
	if (!isStretch ) {
		_x += ( (sprite_width  * _relation) - sliderW * _relation) * ( isAxis);	
		_y += ( (sprite_height * _relation) - sliderH * _relation) * (!isAxis);
		
		draw_set_color(sliderColor);
		draw_sprite(sliderSprite, 0, _x, _y);
	}
	// Rellenar una barra
	else {
		var _w = ( isAxis) ? (sprite_width  * _relation) : sliderW; 
		var _h = (!isAxis) ? (sprite_height * _relation) : sliderH;
			
		draw_sprite_stretched(sliderSprite, 0, _x, _y, _w, _h);	
	}
}

if (sliderLines > 0) {
	var _lines = (sprite_width div (sliderLines + 1) );	
	var _x = x, _sumX = (!isAxis) ? _lines : 0;
	var _y = y, _sumY = ( isAxis) ? _lines : 0;
	
	draw_set_color(sliderLinesColor);
	repeat (_lines) {
		_x += _sumX;	_y += _sumY;
		// Dibujar lineas
		draw_line(_x - sliderXoffset, _y - sliderYoffset, _x + sliderXoffset, _y + sliderYoffset);
	}
}


// Rest
draw_set_color(_color);