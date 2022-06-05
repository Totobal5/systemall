/*
/// @param [x]
/// @param [y]
/// @param [width]
/// @param [height]
/// @param [halign]
/// @param [valign]
/// @desc Todos los cambios producidos en él afectan a la posicion de origen generalmente (x1, y1) que seria top-left
function Rectangle(_x = 0, _y = 0, _w = 1, _h = 1, _halign = fa_left, _valign = fa_top) : __ClasicoStruct__() constructor {
	// Limpiar manualmente cierta cosas
	gc_collect();
	
	w = abs(_w);
	h = abs(_h);
	
	wrel = 1;
	hrel = 1;
	
	wlast = w;
	hlast = h;
	
	x1 = _x;
	y1 = _y;
	
	x2 = x1 + _w;
	y2 = y1 + _h;
	
	angle = 0;	// °
	
	xrotate = (x1 + x2) * 0.5;
	yrotate = (y1 + y2) * 0.5;
	
	halign = _halign;
	valign = _valign;
	
	halign_last = _halign;
	valign_last = _valign;
	
	#region Metodos
		#region Funciones basicas
	/// @desc Alinea para estar concorde a su origen
	static Align = function() {

		return self;	
	}
	
	static Halign = function(_hal) {
		var _x = GetOriginX();
		
		halign = _hal;
			
		if (halign == fa_center) {
			if (halign_last == fa_center) {_x = 0; } else {_x = (w / 2); }
		}
		
		return _x;
	}
	
	static Valign = function(_val) {
		var _y = GetOriginY();
		
		valign = _val;

		if (valign == fa_middle) _y = h / 2;
		
		return _y;		
	}	
	
	/// @desc Suma un valor a la posicion de origen
	static Basic = function(_op_x, _op_y = _op_x) {
		var _x = GetOriginX(), _y = GetOriginY();
		
		return SetBounds(_x + _op_x, _y + _op_y);
	}
	
	/// @desc Multiplica a la posicion de origen
	static Multiply = function(_op_x, _op_y = _op_x) {
		return SetBounds(x1 * _op_x, y1 * _op_y);	
	}	
	
	/// @desc Divide a la posicion de origen.	
	static Division = function(_op_x, _op_y = _op_x) {
		return SetBounds(x1 / max(1, _op_x), y1 / max(1, _op_y) );	
	}

	/// @desc Multiplica el ancho y largo por un valor
	static Scale  = function(_scale) {
		return SetSize(w * _scale, h * _scale);
	}
	
	/// @param delta_x
	/// @param delta_y
	static Expand = function(_x, _y) {
		return SetBounds(x1 - _x, y1 - _y, w + (_x * 2), h + (_y * 2) );
	}

	/// @param delta_x
	/// @param delta_y	
	static Reduce = function(_x, _y) {
		return SetBounds(x1 + _x, y1 + _y, w - (_x * 2), h - (_y * 2) );
	}
	
	/// @param {number} angle
	static Rotate = function(_ang) {
		var _sin, _cos, _cx, _cy, _ox, _oy;
		
		if (_ang == undefined) _ang = angle;
		
		angle = _ang;

		_sin = dsin(angle); 
		_cos = dcos(angle);
		
		_cx = xrotate;
		_cy = yrotate;
		
		_ox = w;
		_oy = h;
		
		x1 = _cx + _ox * _cos - _oy * _sin;
		y1 = _cy + _ox * _sin + _oy * _cos;

		_cx += w; _cy += h;

		x2 = _cx + _ox * _cos - _oy * _sin;
		y2 = _cy + _ox * _sin + _oy * _cos;

		return self;
	}
	
	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param [scale]
	static Indent  = function(_x1, _y1, _x2 = _x1, _y2 = _y1, _s = 1) {
		#region Soporte otras clases
		if (is_rectangle(_x1) ) {
			var _r = _x1; // rectangulo
			_s = (!_y1) ? 1 : _y1;
			
			_x1 = _r.x1;
			_y1 = _r.y1;
			
			_x2 = _r.x2;
			_y2 = _r.y2;
			
		} else if (is_vector2(_x1) && is_vector2(_y1) ) {
			var _p1 = _x1, _p2 = _y1;
			_s = (!_x2) ? 1 : _x2;	

			_x1 = _p1.x; _y1 = _p1.y;
			_x2 = _p2.x; _y2 = _p2.y;
		}
		
		#endregion
		
		return SetCorners(x1 + (_x1 * _s), y1 + (_y1 * _s), x2 - (_x2 * _s), y2 - (_y2 * _s) );
	}

	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param scale	
	static Border = function(_x1, _y1, _x2 = _x1, _y2 = _y1, _s = 1) {
		#region Soporte otras clases
		if (is_rectangle(_x1) ) {
			var _r = _x1; // rectangulo
			_s = (!_y1) ? 1 : _y1;
			
			_x1 = _r.x1;
			_y1 = _r.y1;
			
			_x2 = _r.x2;
			_y2 = _r.y2;
			
		} else if (is_vector2(_x1) && is_vector2(_y1) ) {
			var _p1 = _x1, _p2 = _y1;
			_s = (!_x2) ? 1 : _x2;

			_x1 = _p1.x; _y1 = _p1.y;
			_x2 = _p2.x; _y2 = _p2.y;
		}
		
		#endregion		
		
		
		return SetCorners(x1 - (_x1 * _s), y1 - (_y1 * _s), x2 + (_x2 * _s), y2 + (_y2 * _s) );	
	}

	/// @param x
	/// @param y
	/// @desc Mueve este rectangulo a la posicion (_x, _y) y le suma/resta su posicion original
	static Traslade = function(_x, _y, _s = 1) {
		#region Soporte otras clases
		if (is_rectangle(_x) ) {
			var _r = _x; // rectangulo
			_s = (!_y) ? 1 : _y;
			
			_x = _r.GetOriginX();
			_y = _r.GetOriginY();
			
		} else if (is_vector2(_x) ) {
			var _p = _x;
			_s = (!_y) ? 1 : _y;	
			
			_x = _p.x;
			_y = _p.y;
		}
		
		#endregion

		var _xo = GetOriginX(), _yo = GetOriginY();
		
		return SetBounds(_x + _xo, _y + _yo);
	}
	
	#region Trim (Ignoran origen)
	static TrimTop    = function(_pos) {
		return SetCorners(x1, y1 + _pos, x2, y2);
	}	
	
	static TrimLeft   = function(_pos) {
		return SetCorners(x1 + _pos, y1, x2, y2);
	}

	static TrimBottom = function(_pos) {
		return SetCorners(x1, y1, x2, y2 - _pos);			
	}

	static TrimRight  = function(_pos) {
		return SetCorners(x1, y1, x2 - _pos, y2);		
	}
	
	/// @desc Hace un trim arriba y abajo al mismo tiempo
	static TrimTopBottom = function(_pos1, _pos2 = _pos1) {
		TrimTop(_pos1);
		
		return TrimTop(_pos2);
	}

	/// @desc Hace un trim izquierda y derecha al mismo tiempo
	static TrimLeftRight = function(_pos1, _pos2 = _pos1) {
		TrimLeft(_pos1);
		
		return TrimRight(_pos2);
	}

	#endregion

	#endregion

		#region Getter´s
	/// @desc Obtiene el tamaño (w, h) a partir de la posicion x e y 
	static GetSize   = function() {
		w = abs(x2 - x1);
		h = abs(y2 - y1);
		
		return self;
	}
	
	/// @desc Obtiene el largo
	static GetWidth  = function() {return w; }
	/// @desc Obtiene la altura
	static GetHeight = function() {return h; }
	
	/// @desc Obtener el largo relativo
	static GetWidthRelative  = function() {return (w / wrel); }
	
	/// @desc Obtener la altura relativa
	static GetHeightRelative = function() {return (h / hrel); }
	
	/// @desc Obtiene el centro de x1
	static GetCenterX = function() {return (x1 + (w / 2) );	}
	
	/// @desc Obtiene el centro de y1
	static GetCenterY = function() {return (y1 + (h / 2) ); }		
	
	/// @desc Obtiene el punto left
	static GetX = function() {return x1; }
	
	/// @desc obtiene el punto top
	static GetY = function() {return y1; }

	/// @desc Devuelve el origen x	
	static GetOriginX = function() {
		switch (halign) {
			case fa_left :  return x1; break;
			case fa_right:  return x2; break;
			case fa_center: return GetCenterX(); break;
		}	
	}
	
	/// @desc Devuelve el origen y
	static GetOriginY = function() {
		switch (valign) {
			case fa_top   : return y1; break;
			case fa_bottom: return y2; break;
			case fa_middle: return GetCenterY(); break;
		}
	}
	
	/// @returns {Vector2}
	static GetPosition = function() {
		return (new Vector2(x1, y1) );
	}
		
	/// @returns {Vector2}
	static GetPositionOrigin = function() {
		var _x = GetOriginX(), _y = GetOriginY();
		
		return (new Vector2(_x, _y) );
	}
	
	/// @desc Devuelve el aspect-ratio
	static GetAspectRatio = function() {
		return (w / max(1, h) );
	}
	
	static GetHalign = function() {return halign; }
	static GetValign = function() {return valign; }
	
	static GetSizeRelative = function() {return (hrel != 1 || wrel != 1); }
	
	#endregion

		#region Setter´s	
	/// @desc Cambia el tamaño del rectangulo a partir de su origen; generalmente (x1, y1)
	static SetAlign   = function(_hal, _val) {
		if (_hal == undefined) _hal = halign;
		if (_val == undefined) _val = valign;
		
		// Aplico los nuevos
		// Guardo Aligns anterior
		halign_last = halign;
		valign_last = valign;
		
		var _x = Halign(_hal), _y = Valign(_val);

		SetBounds(_x, _y);
	
		return self;
	}
	
	/// @param [width]
	/// @desc Establece el ancho
	static SetWidth   = function(_w) {w = _w;	return SetSize(w); }
	
	/// @param [height]
	/// @desc Establece la altura
	static SetHeight  = function(_h) {h = _h;	return SetSize(undefined, h); }
	
	/// @param [width]
	/// @param [height]
	/// @desc Cambia el tamaño del rectangulo y las posiciones respecto a su origen
	static SetSize   = function(_w, _h) {
		#region Antes de
		if (is_rectangle(_w) ) {
			var _r = _w;
			_w = _r.GetWidth ();
			_w = _r.GetHeight();
		}
	
		if (_w == undefined) _w = wlast;	if (_h == undefined) _h = hlast;
		
		w = _w;
		h = _h;
		
		#endregion
		
		switch (halign) {
			case fa_left  :	x2 = x1 + w;		break;
			case fa_right :	x1 = x2 - w;		break;
			case fa_center:	
				if (halign_last == fa_left) {
					x1 = x2 - w;
					
				} else if (halign_last == fa_right) {
					x2 = x1 + w;
					
				} else {
					x1 = x2 - w;
				}
				
				break;
		}
		
		switch (valign) {
			case fa_top    : y2 = y1 + h;		break;
			case fa_bottom : y1 = y2 - h;		break;
			case fa_middle : 
				if (valign_last == fa_top) {
					x1 = y2 - h;
					
				} else if (valign_last == fa_bottom) {
					y2 = y1 + h;
					
				} else {
					y1 = y2 - h;
				}
				
				break;
		}
		
		wlast = _w; hlast = _h;
		
		return self;
	}
	
	static SetSizeRelative = function(_wrel, _hrel) {
		wrel = _wrel;
		hrel = _hrel;
		
		return self;
	}
	
	/// @param [x]
	/// @param [y]
	/// @param [width]
	/// @param [height]
	/// @desc Cambia todos los valores del rectangulo a partir de su origen; generalmente (x1, y1)
	static SetBounds = function() {
		var _x, _y, _w, _h;
		
		#region Soporte para otros rectangulos!
		if (is_struct(argument[0] ) ) {
			var _rect = argument[0];
			
			_x = _rect.x1;
			_y = _rect.y1;
			
			_w = _rect.w;
			_h = _rect.h;
		} else {
			_x = argument[0];
			_y = argument[1];
			
			_w = (argument_count > 2) ? argument[2] : w;
			_h = (argument_count > 3) ? argument[3] : h;
		}
		
		#endregion

		switch (halign) {
			case fa_left  :	x1 = _x;	break;
			case fa_right :	x2 = _x;	break;
			case fa_center:
				if (halign_last == fa_left) {
					x2 = x1 + _x;
					
				} else if (halign_last == fa_right) {
					x1 = x2 - _x;
					
				} else {
					x2 = x2 - _x;
				}

				break;
		}
		
		switch (valign) {
			case fa_top    : y1 = _y;		break;
			case fa_bottom : y2 = _y;		break;
			case fa_middle : 
				if (valign_last == fa_top) {
					y2 = y1 + _y;
					
				} else if (valign_last == fa_bottom) {
					y1 = y2 - _y;
					
				} else {
					y2 = y2 - _y;
				}			
			
			
				break;			
		}

		return SetSize( abs(_w), abs(_h) );
	}
	
	/// @desc Cambia el valor de las posiciones y obtiene su nuevo tamaño (w y h)
	static SetCorners = function(_x1, _y1, _x2, _y2) {
		x1 = _x1;
		y1 = _y1;
		
		x2 = _x2;
		y2 = _y2;
		
		GetSize();
		
		return self;
	}
	
	/// @param new_x2
	/// @desc Cambia la posicion de la derecha del rectangulo
	static SetRight = function(_x2) {
		return SetCorners(x1, y1, _x2, y2);	
	}

	/// @param new_x1
	/// @desc Cambia la posicion de la izquierda del rectangulo	
	static SetLeft  = function(_x1) {
		return SetCorners(_x1, y1, x2, y2);			
	}

	/// @param new_y2
	/// @desc Cambia la posicion de abajo del rectangulo		
	static SetBottom = function(_y2) {
		return SetCorners(x1, y1, x2, _y2);		
	}

	/// @param new_y1
	/// @desc Cambia la posicion de arriba del rectangulo	
	static SetTop    = function(_y1) {
		return SetCorners(x1, _y1, x2, y2);		
	}
	
	#endregion
	
		#region Is
	static IsEmpty  = function() {
		return (w <= 0) || (h <= 0);
	}	
	
	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @desc Comprueba si las cordenadas se encuentran adentro del rectangulo
 	static IsInside = function(_x3, _y3, _x4, _y4) {
 		#region Soporte otras clases
 		if (is_rectangle(_x1) ) {	
  			var _r = _x1;
 		
 			_x3 = _r.x1; _y3 = _r.y1;
 			_x4 = _r.y2; _y4 = _r.y2;	
 		} else if (is_vector2(_x1) && is_vector2(_y1) ) {
 			var _p1 = _x1, _p2 = _y1;
 			
  			_x3 = _p1.x; _y3 = _p1.y;
 			_x4 = _p2.x; _y4 = _p2.y;			
	 	}
 		#endregion
		
		return ! ( (_x3 > x2) || (_x4 < x1) || (_y3 > y2) || (_y4 < y1)	);
 	}
 	
	#endregion
	
		#region Obtainers (Regresan otro cuadrado)
	
	/// @param x
	/// @parma y
	static Basiced = function(_x, _y) {
		return Copy().Basic(_x, _y);
	}

	/// @param delta_x
	/// @param delta_y
	/// @desc Regresa un rectangulo que ha sido expandido de su origen (0, 0)
	/// @returns {Rectangle}
	static Expanded = function(_x, _y) {
		if (_y == undefined) _y = _x;
		
		return Copy().Expand(_x, _y);
	}
	
	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param scale
	/// @desc Regresa un rectangulo que se le ha aplicado sangría
	/// @returns {Rectangle}
	static Indented = function(_x1, _y1, _x2, _y2, _s = 1) {
		return Copy().Indent(_x1, _y1, _x2, _y2, _s);
	}			

	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param scale
	static Bordered = function(_x1, _y1, _x2 = _x1, _y2 = _y1, _s = 1) {
		return Copy().Border(_x1, _y1, _x2, _y2, _s); 	
	}	

	/// @param escala
	/// @desc Regresa un rectangulo con sus valores multiplicados con origen (0, 0)
	/// @retun {Rectangle}
	static Scaled  = function(_scale) {
		return Copy().Scaled(_scale);
	}
	
	/// @param halign
	/// @param valign
	/// @desc Regresa un rectangulo con sus valores pero con un origen diferente
	/// @retun {Rectangle}	
	static Aligned = function(_h, _v) {
		return Copy().SetAlign(_h, _v);
	}

	#region Removed
	/// @param delta_x
	/// @param delta_y
	/// @desc Regresa un rectangulo que ha sido reducido de su origen (0, 0)
	/// @returns {Rectangle}
	static Reduced = function(_x, _y) {
		if (_y == undefined) _y = _x;
		
		return Copy().Reduce (_x, _y);
	}	

	/// @param value
	/// @returns {Rectangle}
	static RemoveTop    = function(_pos) {
		TrimTop(_pos);
		
		return (Copy() ).SetCorners(x1, y1 - _pos, x2, y1);
	}	
	
	/// @param value
	/// @returns {Rectangle}
	static RemoveLeft   = function(_pos) {
		TrimLeft(_pos);
		
		return (Copy() ).SetCorners(x1 - _pos, y1, x1, y2);
	}

	/// @param value
	/// @returns {Rectangle}
	static RemoveBottom = function(_pos) {
		TrimBottom(_pos);

		return (Copy() ).SetCorners(x1, y2, x2, y2 + _pos);
	}

	/// @param value
	/// @returns {Rectangle}
	static RemoveRight  = function(_pos) {
		TrimRight(_pos);

		return (Copy() ).SetCorners(x2, y1, x2 - _pos, y2);
	}

	#endregion

	
	/// @desc Regresa una copia del rectangulo cuyo origen es (0, 0)
	/// @returns {Rectangle}
	static Copy = function() {
		return (new Rectangle(x1, y1, w, h) ).SetSizeRelative(wrel, hrel);
	}
	
	#endregion
	
		#region Misq
	static HalignToString = function() {
		switch (halign) {
			case fa_left  : return "hal: fa_left"  ; break;
			case fa_right : return "hal: fa_right" ; break;
			case fa_center: return "hal: fa_center"; break;
		}	
	}	
		
	static ValignToString = function() {
		switch (valign) {
			case fa_top   : return "val: fa_top"   ; break;
			case fa_bottom: return "val: fa_bottom"; break;
			case fa_middle: return "val: fa_middle"; break;
		}		
	}	
		
	/// @desc Intenta convertir los valores a un string
	/// @returns {string}
	static ToString = function() {
		return "x1: " + string(x1) + "\n x2: " +string(x2) + "\n y1: " + string(y1) + "\n y2 " + string(y2) + "\n w: " + string(w) + "\n h: " + string(h) + 
			   "\n" + HalignToString() + "\n" + ValignToString();
	}
	
	static GetPositionRatio = function() {
		return (GetOriginX() / max(1, GetOriginY() ) );	
	}
	
	#endregion
	
	#endregion
	
	Align();
}

/// @param {Rectangle} rectangle
/// @returns {bool}
function is_rectangle(_rect) {
	return (is_struct(_rect) && (_rect.__is == Rectangle) );	
}


