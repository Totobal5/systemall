/// @param x
/// @param y
/// @desc trabaja como un punto en un plano o como un vector
function Vector2(_x = 0, _y = 0) constructor {
	#region Interno
	__is = 0;
	
	#endregion
	
	x = _x;
	y = _y;
	
	xo = 0;	// Origen
	yo = 0; // Origen
	
	#region Metodos
	static SetOrigin = function(_x, _y = _x) {
		xo = _x;
		yo = _y;
		
		return self;
	}
	
	static IsOrigin = function() {
		return (x == _x) && (y == _y);
	}		
	
		#region Basicas
	/// @param x
	/// @param y
	static SetXY = function(_x, _y = _x) {
		x = _x;
		y = _y;
		
		return self;
	}
	
	/// @param point
	static SetPoint = function(_pn) {
		return SetXY(_pn.x, _pn.y);
	}		
	
	/// @param x
	static SetX  = function(_x) {
		x = _x;
		
		return self;
	}
	
	/// @param y		
	static SetY  = function(_y) {
		y = _y;
		
		return self;
	}
	
	/// @param x
	static WithX = function(_x) {
		return Copy().SetX(_x);	
	}
	
	/// @param y		
	static WithY = function(_y) {
		return Copy().SetY(_y);		
	}
	
	static GetAngle = function() {
		return darctan(y / x);
	}
	
	static GetX = function() {return x; }
	static GetY = function() {return y; }
	
	/// @param x
	/// @param y
	static Add = function(_x, _y = 0) {
		x += _x;
		y += _y;
		
		return self;
	}

	/// @param x
	/// @param y	
	static Multiply = function(_x, _y = _x) {
		x *= _x;
		y *= _y;
		
		return self;
	}
	
	/// @param x
	/// @param y	
	static Division = function(_x, _y = _x) {
		x /= max(1, _x);
		y /= max(1, _y);
		
		return self;
	}
	
	static LengthFromOrigin = function() {
		var vx = (x - xo);
		var vy = (y - yo);
		
		return sqrt( sqr(vx + vy) );
	}
	
	/// @param {Vector2} Vector2
	static LengthTo = function(_point) {
		var vx = (x - _point.y);
		var vy = (y - _point.y);
		
		return sqrt( sqr(vx) + sqr(vy) );		
	}
	
	#endregion
	
		#region Operaciones
	/// @param delta_x
	/// @param delta_y
	static Translated = function(_delta_x, _delta_y = _delta_x) {
		return Copy().Add(_delta_x, _delta_y);
	}
	
	/// @param {Vector2} Vector2
	static DistanceFrom = function(_point) {
		return point_distance(x, y, _point.x, _point.y);
	}
	
	static DistanceFromOrigin = function() {
		return point_distance(x, y, xo, yo);	
	}
	
	static AngleTo = function(_point) {
		return darctan2( (_point.y - y) , (_point.x - x) );
	}
	
	static AngleFromOrigin = function() {
		return darctan2( (yo - y) , (xo - x) );
	}
	
	static DotProduct = function(_point) {
		return dot_product(x, y, _point.x, _point.y);
	}
	
	static Normalized = function() {
		var len = LengthFromOrigin();
		
		return new Vector2( (x - xo) / len, (y - yo) / len);
	}
	
	#endregion
	
		#region Misq
	/// @returns {string}
	static ToString = function() {
		return "x: " + string(x) + "/n y: " + string(y);
	}
	
	/// @desc Copia el vector pero en origen 0, 0
	/// @returns {Vector2}
	static Copy = function() {
		return new Vector2(x, y);
	}
	
	#endregion	
		
	#endregion
}

/// @param x_start 
/// @param y_start
/// @param x_end
/// @param y_end
function Line(_xstart = 0, _ystart = 0, _xend = 0, _yend = 0) constructor {
	#region Interno
	__is = 1;
	
	#endregion
	
	pos_start = new Vector2(_xstart, _ystart);  /// @is {Vector2}
	pos_end   = new Vector2(_xend  , _yend  );	/// @is {Vector2}
	
	#region Metodos
	
	static IsVertical   = function() {return (pos_start.x == pos_end.x); }
	static IsHorizontal = function() {return (pos_start.y == pos_end.y); }
	
	/// @returns {bool}	
	static IsInsideX = function(_x) {
		return ( (_x >= pos_start.x && _x <= pos_end.x) );	
	}

	/// @returns {bool}
	static IsInsideY = function(_y) {
		return ( (_y >= pos_start.y && _y <= pos_end.y) );
	}
	
	/// @param {Vector2} point
	/// @returns {bool}	
	static IsInsidePoint = function(_pn) {
		return ( (IsInsideX(_pn.x) && IsInsideY(_pn.y) ) );	
	}

	/// @param {Line} line
	/// @returns {bool}	
	static IsInsideLine  = function(_ln) {
		return (
			(IsInsideX(_ln.pos_start.x) || IsInsideX(_ln.pos_end.x) ) &&
			(IsInsideY(_ln.pos_start.y) || IsInsideY(_ln.pos_end.y) )
		);	
	}

		#region Basics
	/// @desc Da vuelta el inicio con el final
	static Reverse = function() {
		var _newstart = pos_end  .Copy();
		var _newend   = pos_start.Copy();
	
		pos_start = _newstart;
		pos_end   = _newend  ;
		
		gc_collect();
		
		return self;
	}
	
	static Intersect = function(_ln) {
		var _a1 = pos_start.x - pos_end  .x;
		var _b1 = pos_end  .y - pos_start.y;
		var _c1 = _a1 + _b1;

		var _a2 = _ln.pos_start.x - _ln.pos_end  .x;
		var _b2 = _ln.pos_end  .y - _ln.pos_start.y;
		var _c2 = _a2 + _b2;		
		
		var _delta = (_a1 * _b2) - (_a2 * _b1);
		
		if (_delta == 0) return false;
		
		var _x = (_b2 * _c1 - _b1 * _c2) / _delta;
		var _y = (_a1 * _c2 - _a2 * _c1) / _delta;
		var _point = new Vector2(_x, _y);
		
		return (IsInsidePoint(_point) && _ln.IsInsidePoint(_point) );
	}
	
	#endregion
	
		#region Setters
	static SetVectorPoint = function(_pnStart, _pnEnd) {
		pos_start = _pnStart;
		pos_end   = _pnEnd  ;
		
		return self;
	}

	/// @param x
	/// @param y	
	static SetStart = function(_x, _y) {
		pos_start.SetXY(_x, _y);
		
		return self;
	}

	/// @param point
	static SetStartPoint = function(_pn) {
		pos_start.SetPoint(_pn);
		
		return self;
	}
	
	/// @param x
	/// @param y
	static SetEnd = function(_x, _y) {
		pos_end.SetXY(_x, _y);
		
		return self;
	}
	
	/// @param point
	static SetEndPoint = function(_pn) {
		pos_end.SetPoint(_pn);
		
		return self;
	}
	
	#endregion
	
		#region Getter´s
	/// @returns {Vector2}
	static GetStart = function() {
		return pos_start;
	}

	/// @returns {Vector2}	
	static GetEnd   = function() {
		return pos_end;
	}

	static GetEndX   = function() {return pos_end.x; }
	static GetEndY   = function() {return pos_end.y; }	
	static GetStartX = function() {return pos_start.x; }
	static GetStartY = function() {return pos_start.y; }
	
	static GetLength = function() {
		return pos_start.LengthTo(pos_end);
	}
	
	#endregion
	
		#region Misq
	static Copy = function() {
		return (new Line() ).SetVectorPoint(pos_start.Copy(), pos_end.Copy() );
	}
	
	#endregion
	
	#endregion
}

/// @param x
/// @param y
/// @param width
/// @param height
/// @param halign
/// @param valign
/// @desc Todos los cambios producidos en él afectan a la posicion de origen generalmente (x1, y1) que seria top-left
function Rectangle(_x = 0, _y = 0, _w = 1, _h = 1, _halign = fa_left, _valign = fa_top) constructor {
	#region Interno
	__is = 2;
	
	#endregion
	
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
	
		#region Indent (sangría)
	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param [scale]
	static Indent  = function(_x1, _y1, _x2 = _x1, _y2 = _y1, _s = 1) {
		return SetCorners(x1 + (_x1 * _s), y1 + (_y1 * _s), x2 - (_x2 * _s), y2 - (_y2 * _s) );
	}
	
	/// @param {Rectangle} rectangle
	/// @param [scale]
	/// @desc Establece una sangria a partir de otro rectangulo
	static IndentOther = function(_rect, _s = 1) {
		return Indent(_rect.x1, _rect.y1, _rect.x2, _rect.y2, _s);
	}
	
	/// @param {Vector2} point_tl
	/// @param {Vector2} point_rb
	/// @param [scale]
	/// @desc Establece una sangria a partir de 2 puntos
	static IndentPoint = function(_pn1, _pn2, _s = 1) {
		return Indent(_pn1.x, _pn1.y, _pn2.x, _pn2.y, _s);	
	}
	
	#endregion
		
		#region Border
	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param scale	
	static Border = function(_x1, _y1, _x2 = _x1, _y2 = _y1, _s = 1) {
		return SetCorners(x1 - (_x1 * _s), y1 - (_y1 * _s), x2 + (_x2 * _s), y2 + (_y2 * _s) );	
	}
	
	/// @param other_rectangle
	/// @param scale
	static BorderOther = function(_rect, _s = 1) {
		return Border(_rect.x1, _rect.y1, _rect.x2, _rect.y2, _s);
	}
	
	/// @desc Establece un borde a partir de 2 puntos
	static BorderPoint = function(_pn1, _pn2, _s = 1) {
		return Border(_pn1.x, _pn1.y, _pn2.x, _pn2.y, _s);	
	}

	#endregion
	
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
		
		#region Traslade
	/// @param x
	/// @param y
	/// @desc Mueve este rectangulo a la posicion (_x, _y) y le suma/resta su posicion original
	static Traslade = function(_x, _y, _s = 1) {
		var _xo = GetOriginX(), _yo = GetOriginY();
		
		return SetBounds(_x + _xo, _y + _yo);
	}
	
	/// @param other_rectangle
	/// @param scale
	/// @desc Mueve este rectangulo a la posicion de otro rectangulo (respecto a su origen) y suma/resta su posicion original
	static TrasladeOther = function(_other, _s = 1) {
		var _x = _other.GetOriginX();
		var _y = _other.GetOriginY();
		
		return Traslade(_x, _y, _s);
	}

	/// @param point
	/// @param scale
	/// @desc Mueve este rectangulo a la posicion de un punto (respecto a su origen) y suma/resta su posicion original
	static TrasladePoint = function(_pn, _s = 1) {
		return Traslade(_pn.x, _pn.y, _s);
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
	
	/// @desc Establece el ancho
	static SetWidth   = function(_w) {w = _w;	return SetSize(); }
	
	/// @desc Establece la altura
	static SetHeight  = function(_h) {h = _h;	return SetSize(); }
		
	/// @desc Cambia el tamaño del rectangulo y las posiciones respecto a su origen
	static SetSize   = function(_w, _h) {
		if (_w == undefined) _w = wlast;	if (_h == undefined) _h = hlast;
		
		w = _w;
		h = _h;
		
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
	
	/// @param {Rectangle} rectangle
	/// @desc Cambia el tamaño para que sea igual que otro rectangulo
	static SetSizeOther = function(_rect) {
		var _w = _rect.GetWidth(), _h = _rect.GetHeight();
		
		return SetSize(_w, _h);	
	}
	
	static SetSizeRelative = function(_wrel, _hrel) {
		wrel = _wrel;
		hrel = _hrel;
		
		return self;
	}
	
	/// @param x
	/// @param y
	/// @param weight
	/// @param height
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

		SetSize( abs(_w), abs(_h) );

		return self;
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
	static IsEmpty = function() {
		return (w <= 0) || (h <= 0);
	}	
		
	#endregion
	
		#region Obtainers (Regresan otro cuadrado)
		
			#region Remove (Devuelven rectangulo)
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

	/// @param delta_x
	/// @param delta_y
	/// @desc Regresa un rectangulo que ha sido expandido de su origen (0, 0)
	/// @returns {Rectangle}
	static Expanded = function(_x, _y) {
		if (_y == undefined) _y = _x;
		
		return Copy().Expand(_x, _y);
	}

	/// @param delta_x
	/// @param delta_y
	/// @desc Regresa un rectangulo que ha sido reducido de su origen (0, 0)
	/// @returns {Rectangle}
	static Reduced = function(_x, _y) {
		if (_y == undefined) _y = _x;
		
		return Copy().Reduce (_x, _y);
	}	
		
		#region Indent
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

	/// @param other_rectangle
	/// @param scale
	/// @returns {Rectangle}
	static IndentedOther  = function(_other, _s) {
		return Copy().IndentOther(_other, _s);
	}	

	/// @param point_tl
	/// @param point_bt
	/// @param scale
	static IndentedPoint  = function(_tl, _bt, _s) {
		return Copy().IndentPoint(_tl, _bt, _s);
	}

	#endregion
		
		#region Border
	/// @param x1
	/// @param y1
	/// @param x2
	/// @param y2
	/// @param scale
	static Bordered = function(_x1, _y1, _x2 = _x1, _y2 = _y1, _s = 1) {
		return Copy().Border(_x1, _y1, _x2, _y2, _s); 	
	}	
		
	/// @param other_rectangle
	/// @param scale
	/// @returns {Rectangle}
	static BorderedOther = function(_other, _s) {
		return Copy().BorderOther(_other, _s);
	}			
	
	static BorderedPoint = function(_tl, _bt, _s) {
		return Copy().BorderPoint(_tl, _bt, _s);
	}
	
	#endregion
	
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

/// @param string
/// @desc Permite leer archivos, iterar un string y hacer conversiones .json
function Parser(_str = "") constructor {
	//gc_collect();
	
	str  = _str;
	str_start = str;
	
	// variables de metodos
	str_split = ["", ""];
	
	size = string_width (str); // tamaño en pixeles
	len  = string_length(str); // numeros de caracteres
	
	json = {};
	map  = noone;
	
	/// @param index
	static Get = function(_ind = -1) {
		return (_ind > -1) ? str_split[_ind] : str;
	}
	
	/// @param file
	/// @return {struct}
	/// @desc str -> str_in_file
	static ReadFile = function(_file) {
		var _scr = "", _f = file_text_open_read(_file);

		while (!file_text_eof(_f) ) {
			_scr += file_text_read_string(_f);
			file_text_readln(_f);
		}
	
		file_text_close(_f);	
		
		Change(_scr);
		
		return self;
	}
	
	/// @param file_name
	/// @param [save_function]
	static SaveFile = function(_filename, _save_function) {
		if (_save_function == undefined) _save_function = carga_save;
		
		_save_function(str, _filename);
	}
	
	/// @param string
	static Change = function(_str) {
		str  = _str;
		size = string_width (str); // tamaño en pixeles
		len  = string_length(str); // numeros de caracteres		
	}
	
	/// @param char
	/// @param [not_found
	/// @param split_index
	/// @param split_max]
	/// @returns {array} 
	/// @desc Separa un string a partir de un caracter especial. (Permite utilizar el split anterior como entrada)
	static Split = function(_cut, _strnot = "", _ind = -1, _max = -1) {
		gc_collect();	// Limpiar nosotros mismos
		
		// Permite utilizar Split anterior.
		var _str = (_ind > -1) ? str_split[_ind] : str;
		var _len = string_length(_str);
		
		var _array = [];
		/*
		
		for (var i = 1, j = 1; i <= _len; i++) {
			var _char = string_char_at(_str, i);
			
			if (_char == _cut) {
				array_push(_array, string_copy(_str, j, i - 1) );
				
				j = i + 1;
			}
			
			if (_max != -1) && (array_length(_array) > _max) break;			
		}
		
		*/
		
		var i = 1, j = 1;
		
		var _copy = "", _char = "";
		
		repeat (_len) {
			_copy = string_copy(_str, j, i);
			i++;
			
			_char = string_char_at(_copy, i - 1);
			
			if (_char == _cut) {
				array_push(_array, string_delete(_copy, i - 1, 1) );
				
				_copy = "";	
				
				j = i; 
				i = 1; 
			}
			
			if (_max != -1) && (array_length(_array) > _max) break;
		}
		
		// Si no se encuentra el caracter
		str_split = _array;
		
		if (array_length(str_split) <= 0) array_push(str_split, _str, _strnot);
		
		return str_split;		
	}
	
	/// @param replace_string
	/// @param search_string
	/// @param [split_index]
	static Replace = function(_replace, _substring, _ind = -1) {
		if (_ind > -1) {str_split[_ind] = string_replace(_str, _substring, _replace);} 
				  else {str 			= string_replace(_str, _substring, _replace);}

		return self;
	}
	
	/// @param [split_index]
	static IsReal = function(_ind = -1) {
		var _str = (_ind >= 0) ? str_split[_ind] : str;
		
		try {var _is = is_real(_str); } catch (_is) {_is = false; }
		
		return _is;
	}
	
	static FromJson = function(_struct) {
		json = snap_to_json(_struct);
		
		Change(json);
		
		return self;
	}
	
	/// @param [split_index]
	/// @returns {struct}
	/// @des Crea un struct a partir del string introducido.
	static ToJson = function(_ind = -1) {
		var _str = (_ind >= 0) ? str_split[_ind] : str;
		
		try {var _j = snap_from_json(_str); } catch (_j) {_j = {}; }
		
		json = _j;
		
		return json;
	}	

	static ToMap  = function() {
		
	}
	
	/// @desc
	static Clean = function() {
		gc_collect();	// Limpiar nosotros mismos
		
		str  = str_start;
		str_split = [];
		
		size = string_width (str); // tamaño en pixeles
		len  = string_length(str); // numeros de caracteres
		
		json = {};
		map  = noone;
	} 
}

/// @param size
/// @param limite
/// @param [activo?]
function Contador(_size, _lim, _act = true) constructor {
	con = array_create(_size, 0);
	lim = array_create(_size, _lim);
	act = array_create(_size, _act);
	
	#region Metodos
	static Add    = function(_lim, _act) {
		array_push(con, 0);
		array_push(lim, _lim);
		array_push(act, _act);
		
		return self;
	}
	
	static Switch = function(_ind, _bool = true) {
		if (_bool) {
			if (!act[_ind] ) con[_ind] = 0;
			
			act[_ind] = !act[_ind];
		}	
		
		return self;
	}
	
	static GetActivate = function(_ind) {
		return ( act[_ind] );
	}
	
	static Count = function(_ind, _off) {
		if (GetActivate(_ind) ) {
			if (con[_ind] < lim[_ind] ) {
				con[_ind]++;
			} else if (con[_ind] >= lim[_ind] ) {
				if (_off) {con[_ind] = lim[_ind]; Switch(_ind); } else {con[_ind] = 0;}	
			}
		}	
	
		return (con[_ind] );
	}
	
	#endregion
}

/// @desc Numeros porcentuales.
function Data(_val = 0) constructor {
	#region Metodos
	__is = "MALL_DATA";
	
	static IsPorcent = function(_value) {
		var _len = string_length (_value);
		var _str = string_char_at(_value, _len);
		
		return ( (is_string(_value) ) && (_str == "%") );
	}
	
	static ConvertPorcent = function(_value) {
		if (IsPorcent(_value) ) {
			var _len	= string_length (_value); 
			var _bun	= string_delete (_value, _len, 1);
			
			return (real(_bun) / 100);
		} else if (is_numeric(_value) ) return (_value / 100);
	}
	
	static ToString = function(_value) {
		if (is_numeric(_value) ) {
			return (string(_value) + "%");
		} else {
			var _len = string_length (_value);
			var _str = string_char_at(_value, _len);
			
			if (_str != "%") return (_value + "%");
		}
		
		return (_value);	
	}
	
	static Set = function(_value) {
		if (is_data(_value) ) {
			num = _value.num;
			nop = num * 100;
			str = string(nop) + "%";			
		} else {
			num = ConvertPorcent(_value);
			nop = num * 100;
			str = string(nop) + "%";			
		}
		
		return self;
	}
	
	/// @desc Suma o resta
	static Operate  = function(_value) {
		if (is_data(_value) ) {
			num += _value.num;
			nop  = num * 100;
			str  = string(nop) + "%";
		} else {
			num += ConvertPorcent(_value);
			nop  = num * 100;
			str  = string(nop) + "%";			
		}
		
		return self;
	}
		
	static Operated = function(_value) {
		return (new __mall_class_data(1) );
	}
	
	static Multiply = function(_value) {
		if (is_numeric(_value) ) {
			num *= _value;
			str = string(num) + "%";
		} else {
			num *= ConvertPorcent(_value);
			str = string(num) + "%";
		}
		
		return self;		
	}
	
	/// @param {Data} Data_class	
	static Same = function(_other) {
		return Set(_other.nop);
	}
		
	static Turn  = function() {
		num *= -1;
		str  = ToString(num);
	}
	
	static Clamp = function(_min, _max) {
		return (Set(clamp(nop, _min, _max) ) );	
	}
	
	static Copy  = function() {
		return (new __mall_class_data(nop) );
	}
	
	#endregion
	
	bereal = 0;	// Segundo numerico que se encuentra
	
	num = ConvertPorcent(_value);	// Valor porcentaje (decimal)
	nop = num * 100;				// Valor sin ser porcentaje (entero)
	
	str = ToString(_value);			// Si es numero lo pasa a string

	gc_collect();
}
