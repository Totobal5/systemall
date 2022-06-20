enum VEC2_DIR 
{
	RIGHT	=   0,
	UP		=  90, 
	LEFT	= 180, 
	DOWN	= 270
}

/// @param {Real} x	Posicion horizontal del vector (Default=0)	
/// @param {Real} y	Posicion vertical del vector (Default=0)	
/// @returns {Struct.Vector2}
function Vector2(_x=0, _y=0) constructor 
{
	#region PRIVATE
	/* @ignore @type {Real} Origen x */
	__xo = 0;
	/* @ignore @type {Real} Origen y */
	__yo = 0;
	#endregion
	
	#region PUBLIC
	/// @type {Real}
	x = _x;
	/// @type {Real}
	y = _y;
	
	#endregion

	#region METHODS
	
		#region Basic
	/// @param {Real} x
	/// @param {Real} [y]
	/// @desc Establece el origen
	/// @return {Struct.Vector2}
	static setOrigin = function(_x, _y=_x) 
	{
		__xo = _x;
		__yo = _y;
		
		return self;
	}
	
	/// @desc Indica si se encuentra en el origen
	/// @return {Bool}
	static inOrigin = function() 
	{
		return (x == __xo) && (y == __yo);
	}		
	
	/// @desc establece "x = 1" e "y = 1"
	/// @return {Struct.Vector2}
	static one  = function() 
	{
		x = 1; y = 1;
		return self;
	}
	
	/// @desc establece "x = 0" e "y = 0"
	/// @return {Struct.Vector2}
	static zero = function() 
	{
		x=0; y=0;
		return self;
	}
	
	/// @desc establece "x * =-1" e "y *= -1"
	/// @return {Struct.Vector2}
	static negative = function() 
	{
		x *= -1; y *= -1;
		return self;
	}
	
	/// @desc establece "x = abs(X)" e "y = abs(Y)"
	/// @return {Struct.Vector2}
	static absolute = function() 
	{
		x = abs(x); y = abs(y);
		return self;
	}
	
	#endregion
	
		#region Posicionar
	/// @param {Real,Struct.Vector2}	x	posicion horizontal o Vector2
	/// @param {Real}					[y]	posicion vertical
	/// @desc Establece la posicion X e Y del Vector
	/// @return {Struct.Vector2}
	static setXY = function(_x, _y=_x) 
	{
		if (is_vector2(_x) ) {
			/// @type {Struct.Vector2}
			var _vector = _x;
			
			x = (_vector).x;		
			y = (_vector).y;	
		} 
		else {
			x = _x;	
			y = _y;
		}
		
		return self;
	}
	
	/// @param {Real,Struct.Vector2}	x	posicion horizontal o Vector2
	/// @desc Establece la posicion X y mantiene el valor Y
	/// @return {Struct.Vector2}
	static setX  = function(_x) 
	{
		x = (!is_vector2(_x) ) ? _x : _x.x;
		
		return self;
	}
	
	/// @param {Real, Struct.Vector2}	y	posicion vertical o Vector2
	/// @desc Establece la posicion Y e mantiene el valor X
	/// @return {Struct.Vector2}	
	static setY  = function(_y) 
	{
		y = (!is_vector2(_y) ) ? _y : _y.y;
		
		return self;
	}
	
	/// @param {Real, Struct.Vector2}	x	posicion horizontal o Vector2
	/// @param {Real}					[y]	posicion vertical
	/// @desc Crea un nuevo Vector2 copiando el valor X e Y como tambien sus origenes
	/// @return {Struct.Vector2}
	static useXY = function(_x, _y=_x) 
	{
		return (new Vector2(_x, _y) ).setOrigin(__xo, __yo);
	}
	
	/// @param {Real, Struct.Vector2}	x	posicion horizontal o Vector2
	/// @desc Crea un nuevo Vector2 copiando el valor X como tambien sus origenes pero manteniendo el valor Y
	/// @return {Struct.Vector2}
	static useX = function(_x) 
	{
		return (new Vector2(_x, y) ).setOrigin(__xo, __yo);
	}
	
	/// @param {Real, Struct.Vector2}	y	posicion vertical o Vector2
	/// @desc Crea un nuevo Vector2 copiando el valor Y como tambien sus origenes pero manteniendo el valor X
	/// @return {Struct.Vector2}
	static useY = function(_y) 
	{
		return (new Vector2(x, _y) ).SetOrigin(__xo, __yo);		
	}
	
	#endregion
	
		#region Operaciones
	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @desc Añade valores a la posicion x y/o y
	/// @return {Struct.Vector2}
	static add = function(_x=0, _y=_x) 
	{
		if (!is_vector2(_x) ) {
			x += _x;
			y += _y;
		}
		else {
			x += _x.x;	
			y += _x.y;
		}
		
		return self;
	}

	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @return {Struct.Vector2}	
	static multiply = function(_x=1, _y=_x) 
	{
		if (!is_vector2(_x) ) {
			x *= _x;	
			y *= _y;	
		}
		else {
			x *= _x.x;
			y *= _x.y;
		}
		
		return self;
	}
	
	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @return {Struct.Vector2}	
	static division = function(_x, _y=_x) 
	{
		if (!is_vector2(_x) ) {
			x /= max(0.01, _x);	
			y /= max(0.01, _y);	
		}
		else {
			x /= max(0.01, _x.x);
			y /= max(0.01, _x.y);
		}
		
		return self;
	}
	
	#endregion
	
		#region Gets
	/// @param {Bool}	[origin] Devolver desde 0 (false) o desde el origen (true)
	/// @desc Devuelve la longitud del Vector2
	/// @returns {Real}
	static length = function(_origin=false) 
	{
		return (!_origin ?
			(point_distance(0, 0, x, y) ) :
			(point_distance(__xo, __yo, x, y) )
		);
	}
	
	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @desc Devuelve la longitud desde un punto
	/// @returns {Real}	
	static lengthTo = function(_x, _y=_x) 
	{
		if (is_vector2(_x) ) {
			return (point_distance(x, y, _x.x, _x.y) );		
		}
		else {
			return (point_distance(x, y, _x, _y) );
		}
	}
	
	/// @desc Devuelve el angulo hacia el vector
	/// @return {Real}
	static originAngle = function() 
	{
		return darctan2( (__yo - y) , (__xo - x) ); 
	}
	
	/// @desc Devuelve el angulo del vector
	/// @return {Real}
	static angle = function() 
	{
		return darctan(y / x); 
	}
	
	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @desc Devuelve el angulo hacia el punto ingresado
	/// @return {Real}	
	static angleTo = function(_x, _y=_x) 
	{
		if (is_vector2(_x) ) {
			return darctan2( (_x.y - y) , (_x.x - x) );
		}
		else {
			return darctan2( (_y - y) , (_y - x) );	
		}
	}
	
	/// @param {Real}	delta_x		Cuanto mover horizontalmente
	/// @param {Real}	[delta_y]	Cuanto mover verticalmente
	/// @desc Devuelve un nuevo vector transladado xDelta e yDelta
	/// @return {Struct.Vector2}
	static translated = function(_xDelta=0, _yDelta=_xDelta) 
	{
		var _vector2 = new Vector2(x, y);
		return _vector2.add(_xDelta, _yDelta);
	}

	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @desc Devuelve el cross product
	/// @return {Real}
	static cross = function(_x, _y) 
	{
		if (is_vector2(_x) ) {
			return ((x * _x.x) - (y * _x.y) );
		}
		else {
			return ((x * _y) - (y * _x) );	
		}
	}

	/// @param {Real, Struct.Vector2}	x	Posicion horizontal o Vector2
	/// @param {Real}			 		[y]	Posicion vertical
	/// @desc Devuelve el dot product
	/// @returns {Real}
	static dot = function(_x, _y) 
	{
		if (is_vector2(_x) ) {
			return dot_product(x, y, _x.x, _x.y);
		}
		else {
			return dot_product(x, y, _x, _y);
		}
	}
	
	// SignTest(_Ax, _Ay, _Bx, _By, _Lx, _Ly) {
	// 	return ((_Bx - _Ax) * (_Ly - _Ay) - (_By - _Ay) * (_Lx - _Ax));
	// }
	
	/// @desc Devuelve un nuevo vector con los valores normalizados
	/// @returns {Struct.Vector2}
	static norm = function() 
	{
		var len = Length();
		return (new Vector2( x/len, y/len) );
	}

	#endregion
	
		#region Directions
	/// @param {Constant.VEC2_DIR}	direction
	/// @param {Real}				value
	static dirAdd = function(_direction, _value) 
	{
		switch (_direction) {
			case VEC2_DIR.UP:		y += _value;	break;
			case VEC2_DIR.LEFT:		x -= _value;	break;
			case VEC2_DIR.RIGHT:	x += _value;	break;
			case VEC2_DIR.DOWN:		y -= _value;	break;
		}
		
		return self;
	}
	
	/// @param {Constant.VEC2_DIR}	direction
	/// @param {Real}				value
	static dirMult = function(_direction, _value) 
	{ 
		switch (_direction) {
			case VEC2_DIR.UP:		y *=  _value;	break;
			case VEC2_DIR.LEFT:		x *= -_value;	break;
			case VEC2_DIR.RIGHT:	x *=  _value;	break;
			case VEC2_DIR.DOWN:		y *= -_value;	break;
		}
		
		return self;		
	}

	/// @param {Constant.VEC2_DIR}	direction
	/// @param {Real}				value
	static dirDiv  = function(_direction, _value) 
	{
		switch (_direction) {
			case VEC2_DIR.UP:		y /= max(0.01,  _value);	break;
			case VEC2_DIR.LEFT:		x /= max(0.01, -_value);	break;
			case VEC2_DIR.RIGHT:	x /= max(0.01,  _value);	break;
			case VEC2_DIR.DOWN:		y /= max(0.01, -_value);	break;
		}
		
		return self;			
	}
	
	#endregion
	
		#region Utils	
	/// @returns {String}
	static toString = function() 
	{
		return "x: " + string(x) + "\n y: " + string(y);
	}
	
	/// @returns {Array.Real}
	static toArray  = function() 
	{
		return [x, y];
	}
	
	/// @returns {Id.DsList}
	static toList   = function() 
	{
		var _list = ds_list_create();
		ds_list_add(_list, x, y);
		return (_list);
	}
	
	/// @desc Regresa una copia de este vector
	/// @returns {Struct.Vector2}
	static copy = function() 
	{
		return (new Vector2(x, y) ).setOrigin(__xo, __yo);
	}

	#endregion

	#endregion
}

/// @param {Struct.Vector2} Vector2
/// @returns {Bool}
function is_vector2(_vector2) 
{
	return (is_struct(_vector2) && (instanceof(_vector2) == "Vector2") );
}