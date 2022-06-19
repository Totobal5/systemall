/// @desc Array en constructor
/// @return {Struct.List}
function List() constructor {
	#region PRIVATE
	/// @type {Array}
	__list = [];
	
	/// @type {Real}	
	__size = 0;
	
	#endregion
	
	#region METHOD
	
		#region Basic
	/// @param	value
	/// @desc Agrega valores al final
	/// @return	{Struct.List}
	static push = function(_value) {
		// Resize
		if (__size mod 2 <= 0) array_resize(__list, max(1, __size << 1) );
		// Agregar elemento
		__list[__size++] = _value;
		return self;
	}
	
	/// @param value
	/// @desc Agrega valores al inicio
	/// @return {Struct.List}
	static sneak = function(_value) {
		array_insert(__list, 0, _value);
		__size++;
		return self;
	}
	
	/// @param {Real}	index
	/// @param {Mixed}	value
	/// @return {Struct.List}
	static set = function(_index, _value) {
		if (_index > __size) exit;
		__list[_index] = _value;
		return self;
	}
	
	/// @param {Real} index
	/// @return {Mixed}
	static get = function(_index) {
		return (__list[_index] );	
	}	
	
	/// @desc Devuelve el ultimo
	/// @return {Mixed}
	static last  = function() {
		return (__list[__size] );	
	}
	
	/// @desc Devuelve el primero
	/// @return {Mixed}
	static first = function() {
		return (__list[0] );	
	}
	
	/// @desc Devuelve el ultimo y lo elimina
	/// @return {Mixed}
	static pop = function() {
		__size--;
		return (array_pop(__list) ); 
	}
		
	/// @desc Devuelve el primero y lo elimina
	/// @return {Mixed}
	static shift = function() {
		var _first = __list[0];
		__size--;
		
		array_delete(__list, 0, 1);
		return (_first);
	}

	/// @return {Real}
	static size = function() {
		return (__size);
	}
	
	/// @return {Bool}
	static empty = function() {
		return (__size == 0);	
	}
	
	#endregion
	
		#region Utils
	
	/// @param {Real} source_index
	/// @param {Real} destination_index
	static swap = function(_sindex, _dindex) {
		var _t=__list[_sindex];

		__list[_sindex] = __list[_dindex];
		__list[_sindex] = _t;		
		
	}
	
	static shuffle = function() {
		var _seed=random_get_seed(); randomize();
		repeat (__size) {
			var _r1=irandom(_len), _r2 = irandom(_len - 1);
			swap(_r1, _r2);
		}
		random_set_seed(_seed);		
	}
	
	/// @param value
	/// @return {Bool}
	static exists = function(_value) {
		return (index(_value) != -1);	
	}
	
	/// @param value
	/// @return {Real}
	static index  = function(_value) {
		var i=0; repeat(__size) {
			var _in = __list[i++];
			if (_in == _value) return i;
		}
		
		return -1;
	}

	/// @param {Real} index
	/// @param {Real} number
	/// @return {Struct.List}
	static remove = function(_index, _number) {
		array_delete(__list, _index, _number);
		__size -= _number;		
		return self;
	}
	
	/// @return {Struct.List}
	static clear = function() {
		__list = [];
		__size =  0;
		return self;
	}
	
	/// @return {Real}
	static getMin = function() {
		var _t=__list[0];
		var i=1; repeat(__size) {
			_t = min(__list[i++], _t); 	
		}

		return (_temp);		
	}

	/// @return {Real}
	static getMax = function() {
		var _t=__list[0];
		var i=1; repeat(__size) {
			_t = max(__list[i++], _t); 	
		}

		return (_temp);			
	}
	
	/// @param {Function} method	function(value, i)
	static forEvery = function(_f) {
		var i=0;repeat(__size) _f(__list[i], i++);
	}
	
	/// @param {Function} method	function(value, i)
	/// @return {Array}
	static forEveryMap = function(_f) {
		var _return=array_create(__size);
		var i=0; repeat(__size) {
			_return[i] = _f(__list[i], i);
			++i;
		}
	
		return _return;		
	}
	
	#endregion
	
	#endregion
}
	
/// @param {Struct.List} list
/// @return {Bool}
function is_list(_list) {
	return (is_struct(_list) && (instanceof(_list) == "Line") );
}