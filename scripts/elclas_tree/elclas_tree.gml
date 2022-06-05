/// @param {String}	_id
/// @param {Bool}	_is_node
/// @return {Struct.Tree}
function Tree(_id, _value) constructor {
	#region PRIVATE
	__id = _id;	
	/// @type {Array<Struct.Tree>}
	__list = []; 	
	__size =  0;
	
	__node  = true;
	__value = _value;
	__depth = 1;

	#endregion
	
	#region METHOD
	/// @param {String}	_id
	/// @param _value
	/// @param {Bool}	_is_node
	static add = function(_id, _value, _is_node=true) {
		if (!__node) return self;
		
		var _tree = new Tree(_id, _value);
		_tree.__node   = _is_node;
		_tree.__depth += 1;	// Aumentar la profundidad
		
		// Obtener nuevo tamaño
		array_push(__list, _tree);
		__size = array_length(__list);
		
		return (_tree);
	}
	
	/// @desc Regresa cuantos elementos hay en el Tree
	/// @return {Real}
	static size = function() {
		if (array_empty(__list) ) return 1;
		
		var _sum = 1;
		var i=0; repeat(array_length(__list) ) {
			var _tree = __list[i++];
			
			if (!_tree.__node) continue;
			_sum += _tree.size();
		}
		
		return _sum;
	}
	
	/// @desc Regresa la altura hasta el final en el arbol
	/// @return {Real}
	static height = function(_depth_max=0) {
		var _depth = 0;
		var i=0; repeat(array_length(__list) ) {
			var _tree = __list[i++];	
			if (!_tree.__node) continue;	
			_depth = max(_tree.__depth, _tree.height() );
		}
		
		return _depth;
	}
	
	#endregion
}