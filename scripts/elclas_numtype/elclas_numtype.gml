/// En un mismo enum se ponen todas las opciones para no rellenar Feather
enum NUMTYPE {
	VALUE, TYPE, DIV, 
	REAL, PERCENT, BOOLEAN
}

/// @param {Real}	value
/// @param {Real}	type
/// @return {Array}
function numtype(_value, _type) {
	var _data = [
		_value	,
		_type	,
		_value / 100
	];
	
	return _data;
}

/// @param {Array}	numtype
/// @param {Real}	value
/// @param {Real}	type
/// @return {Array}
function numtype_set(_numtype, _value, _type) {
	_numtype[0] = _value;
	_numtype[1] = _type ?? _numtype[1];
	_numtype[2] = _value / 100;
	return (_numtype);
}

/// @param {Array}	numtype
/// @return {Real}
function numtype_value(_numtype) {
	return _numtype[0];	
}
	
/// @param {Array}	numtype
/// @return {Real}
function numtype_type(_numtype) {
	return 	(_numtype[1] );
}

/// @param {Array}	numtype
/// @return {Real}
function numtype_div(_numtype) {
	return 	(_numtype[2] );	
}

/// @param {Array} numtype_destination
/// @param {Array} [numtype_source]
/// @return {Array<Real>}
function numtype_copy(_numtype_dest, _numtype_source) {
	if (argument_count > 1) {
		array_copy(_numtype_dest, 0, _numtype_source, 1, 3);	
	}
	else {
		var _array = [];
		array_copy(_array, 0, _numtype_source, 1, 3);
		return _array;
	}
}