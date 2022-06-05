function Link() constructor {
    #region PRIVATE
	/*@type Array @ignore*/
    __list = [];    
	/*@type Struct @ignore*/
    __link = {};    
    /*@type Real @ignore*/
    __size = 0;
    
    #endregion
    
    #region METHOD
	/// @param {String}	key
	/// @param {Mixed}	value
	/// @desc Agrega valores al Link
	/// @return {Struct.Link}
    static push = function(key, value) {
		array_push(__list, value);
		
		var _size = array_length(__list);
		__link[$ key] = _size - 1;
		__size = _size;
		
		return self;
	}
	
	/// @param {String} key
	/// @return {Bool}
	static exists = function(key) {
		return (variable_struct_exists(__link, key) );	
	}
    
	/// @param {Real, String} index
	static get = function(index) {
		return (is_numeric(index) ? 
			__list[index] :
			__list[__link[$ index] ]
		);
	}
	
	/// @param key
	/// @desc Devuelve el indice a partir de un indice
	/// @return {String}
	static getKey = function(index) {
		var _names = variable_struct_get_names(__link);
		var i=0; repeat(array_length(_names) ) {
			var key = _names[i];
			if (__link[$ key] == index) return 	key;
		}	
		
		return "";
	}
	
    #endregion
}