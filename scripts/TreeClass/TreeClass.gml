/// @param root_val
/// @param [name]
function __tree_class(_root_val) constructor {
	#region Interno
	static __defname__ = function() {return "leave" + string(leaves_size); }
    
    static __is_tree__ = function() {return (is_struct(other) && other.__is == "Tree class"); }
    
    static __set_trunk__ = function() {trunk = self; return self;}
    
    __is = "Tree class";
    
    #endregion

	id   = "root";
	
	trunk  = noone;	// Tronco
	branch = noone; // Rama 
	
	value = _root_val;
	
	// Hojas
	leaves		= [];
	leaves_size = array_length(leaves);
    
    depth = 0;  // La rama principal tiene una depth de 0
    
	#region Metodos
	/// @param [funcion
	/// @param both?]	Establece si se devuelven tambien los elementos borrados
	/// @desc Devuelve un array con los elementos que han sidos filtrados.
	static filter = function(_function, _both = false) {
		if (is_undefined(_function) ) _function = function(l, i, ext) {return true; }
		
		var _size  = get_size();
		var _new = [];
		var _del = [];
		
		for (var i = 0; i < _size; ++i) {
			var _leave = get_leave(i);
			
			if (_function(_leave, i) ) {array_push(_new, _leave); } else {array_push(_del, _leave); }
		}
		
		return _both ? [_new, _del] : _new;
	}
	
	/// @param id
	/// @param [val]
	/// @desc Agrega una rama nueva al arbol. devuelve la rama que se ha agregado.
	/// @return {struct}
	static add = function(_from, _id, _val) {
		var _new = new __tree_class(_val, _id);
		
		// Establecer la profundidad de la rama y el arbol a que pertenece
		_new.depth += (1 + _from.depth);
	    _new.trunk  = _from.trunk;  // Establecer quien es el tronco de esta rama
	    _new.branch = (tree_is_trunk(_from) ) ? noone : _from; // Establece de que rama proviene
	    
		array_push(leaves, _new);
		
		// Actualiza el largo
		leaves_size = array_length(leaves);
		
		return array_pop(leaves);
	}
	
	/// @param name
	/// @param posicion
	/// @desc si existe name en el tree devolverá una rama. se puede indicar que devuelva la rama junto a la posicion colocando el ultimo parametro a true 
	/// @returns {array}
	static get = function(_id, _pos = false) {
		var _size = get_size();
		
		for (var i = 0; i < _size; ++i) {
			if (leaves[i].id == _id) return (_pos) ? [leaves[i], i] : leaves[i];
		}
		
		return undefined;
	}
	
	static search = function(_depth) {
		var _search = [];
		var _size = get_size();
		
		for (var i = 0; i < _size; ++i) {
			var _leave = leaves[i];
			
			if (_leave.depth == _depth) {
				array_push(_search, _leave); 
			} else {
				array_push(_search, _leave.search(_depth) ); 
			}
		}
		
		return _search;
	}
	
	static get_leave = function(_pos) {
		return leaves[i];
	}

	/// @returns {struct}
	static get_last  = function() {
		return array_pop(leaves);
	}
	
	/// @returns {array}	
	static get_names = function() {
		var _size  = get_size();
		var _array = array_create(_size);
		
		for (var i = 0; i < _size; ++i) _array[i] = leaves[i].name;
		
		return _array;
	}
	
	static get_size  = function() {
		leaves_size = array_length(leaves);
		
		return leaves_size;
	}
	
	#endregion
}