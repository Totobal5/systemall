/// @param {Real}				_x			Nueva posicion X
/// @param {Real}				_y			Nueva posicion Y
/// @param {Bool, Id.Instance}	[_relative]	Relativo a la posicion en que se encuentra la instancia o relativo a una instancia (bool o instancia)
/// @param {Id.Instance}		[_lima]		Elemento lima a mover (default: id)
function lima_place(_x, _y, _relative, _lima=id) {
	if (!is_lima(_lima) ) exit;
	
	with (_lima) {
		/// @context {lima_parent}
		_x += _xoff;
		_y += _yoff;		
		
		if (!instance_exists(_relative) ) {
			if (!_relative) {
				#region NO RELATIVO A NADA
				x = __lima_place_help_x(_x + xoffset, sprite_xoffset,  sprite_width);
				y = __lima_place_help_y(_y + yoffset, sprite_yoffset, sprite_height);
				
				#endregion
			}
			else {
				#region RELATIVO A SI MISMO
				x += __lima_place_help_x(_x + xoffset, sprite_xoffset,  sprite_width);
				y += __lima_place_help_y(_y + yoffset, sprite_yoffset, sprite_height);
			
				#endregion
			}			
		} 
		else {
			#region RELATIVO A UNA INSTANCIA
			switch (halign) {
				case fa_left :	x =  _relative.bbox_left  + _x;	break;
				case fa_right:	x =  _relative.bbox_right - _x;	break;
				case fa_center:	x = (_relative.sprite_width / 2) + _x; break;
			}
			
			switch (valign) {
				case fa_top:	y =  _relative.bbox_top		+ _y;	break;
				case fa_bottom:	y =  _relative.bbox_bottom  - _y;	break;
				case fa_middle:	y = (_relative.sprite_height / 2) + _x;	break;
			}
			
			#endregion
		}
	}
}

/// @return {Real}
/// @ignore
function __lima_place_help_x(_x, _w, _xoff) {
	/// @context {lima_parent}
	switch (halign) {
		case fa_left :	
			return (_x + _xoff);	
			
			break;
			
		case fa_right:	
			return (_x + _xoff) - (_w + _xoff);	
			
			break;
		
		case fa_center:
			// Dejar en 0
			var _midxoff = _xoff / 2, _midw = _w / 2;
			return (_x + _midxoff) - (_midw + _midxoff);
					
			break;	
	}		
}

/// @return {Real}
/// @ignore
function __lima_place_help_y(_y, _h, _yoff) {
	/// @context {lima_parent}
	switch (valign) {
		case fa_left :	
			return (_y + _yoff);	
			
			break;
			
		case fa_right:	
			return (_y + _yoff) - (_h + _yoff);	
			
			break;
		
		case fa_center:
			// Dejar en 0
			var _midxoff = _yoff / 2, _midw = _h / 2;
			return (_y + _midxoff) - (_midw + _midxoff);
					
			break;	
	}		
}