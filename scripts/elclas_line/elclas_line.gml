/// @param [x1] 
/// @param [y1]
/// @param [x2]
/// @param [y2]
/// @return {Struct.Line}
function Line(_x1=0, _y1=0, _x2=0, _y2=0) constructor {
	#region PRIVATE
	/// @ignore
	__is = "Line";

	#endregion
	
	#region PUBLIC
	pos1 = new Vector2(_x1, _y1);
	pos2 = new Vector2(_x2, _y2);
	
	#endregion
	
	#region METHOD
	
		#region Basic
	/// @desc Da vuelta el inicio con el final
	/// @return {Struct.Line}
	static reverse = function() {
		var _temp1 = pos1, _temp2 = pos2;
		
		pos1 = _temp2;	pos2 = _temp1;
		return self;
	}		
	
	/// @param {Struct.Line} Line
	static intersect = function(_line) {
		var _a1 = pos1.x - pos2.x;
		var _b1 = pos2.y - pos1.y;
		var _c1 = _a1 + _b1;

		var _a2 = _line.pos1.x - _line.pos2.x;
		var _b2 = _line.pos2.y - _line.pos1.y;
		var _c2 = _a2 + _b2;		
		
		var _delta = (_a1 * _b2) - (_a2 * _b1);
		
		if (_delta == 0) return false;
		
		var _x = (_b2 * _c1 - _b1 * _c2) / _delta;
		var _y = (_a1 * _c2 - _a2 * _c1) / _delta;
		var _point = new Vector2(_x, _y);
		
		return (IsInsidePoint(_point) && _line.IsInsidePoint(_point) );
	}

	#endregion

		#region Gets
	/// @returns {Real}		
	static length = function() {
		return (pos1.lengthTo(pos2) );
	}
	
	#endregion

		#region Utils
	/// @return {Bool}
	static isHorizontal = function() {
		return (pos1.x == pos2.x);	
	}

	/// @return {Bool}
	static isVertical	= function() {
		return (pos1.y == pos2.y);
	}

	/// @param {Real} x
	/// @return {Bool}
	static isInsideX = function(_x) {
		return ( (_x >= pos1.x && _x <= pos2.x) );		
	}	

	/// @param {Real} y
	/// @return {Bool}
	static isInsideY = function(_y) {
		return ( (_y >= pos1.y && _y <= pos2.y) );
	}
	
	/// @param {Struct.Vector2} Vector2
	/// @return {Bool}	
	static isInside = function(_vector2) {
		return ( (isInsideX(_vector2.x) && isInsideY(_vector2.y) ) );	
	}

	/// @param {Struct.Line} Line
	/// @return {Bool}	
	static isInsideLine  = function(_line) {
		return (isInside(_line.pos1) || isInside(_line.pos2) );
	}

	#endregion
	
	#endregion
}

/// @param {Struct.Line} line
/// @returns {Bool}
function is_line(_line) {
	return (is_struct(_line) && (_line.__is == "Line") );	
}