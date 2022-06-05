/// @desc	Es un tipo de coleccion de datos que utiliza un struct para guardar contenidos y un array para guardar las llaves
///			Permite realizar ciertas acciones más rapido
/// @return {Struct.Collection}
function Collection() constructor {
	#region PRIVATE
	/// @ignore
	__is = "Collection";
	
	/* @ignore @type {struct} */
	__content = {};	// Guardar los valores
	
	/*@ignore @type {Array<String>}*/
	__keys = [];
	
	/// @ignore
	__last  = 0;	// Ultimo indice en ciclo
	/// @ignore
	__cicle = 0;	// Para el ciclo
	
	/// @ignore
	__size = 0;
	
	#endregion
	
	#region METHODS
	
	/// @param {string}	key
	/// @param {Mixed}	value
	/// @desc Añade un nuevo valor a la coleccion
	/// @returns {Struct.Collection}
	static set = function(key, value) {
		if (!exists(key) ) {
			array_push(__keys, key);
			__size = array_length(__keys);
		}
		
		__content[$ key] = value;
		
		return self;
	}

	/// @param {Mixed} value
	/// @desc Establece todos los valores de la coleccion a un valor especificado
	/// @returns {Struct.Collection}
	static every = function(value) {
		var i=0; repeat(__size) set(__keys[i++], value);
		return self;
	}
	
	/// @param {String} key
	/// @return {Bool}
	static exists = function(key) {
		return (variable_struct_exists(__content, key) );
	}
	
	/// @param {String, Real, Array} [use]
	/// @returns {Array<String>, String} Devuelve la llave
	static remove = function(use, _it=false) {
		var _delete = undefined;

		if (is_numeric(use) ) {
			#region Indice
			_delete = __keys[use];
			variable_struct_remove(__content, _delete);
			
			// Remover
			array_delete(__keys, use, 1);		
			#endregion
		}
		else if (is_string(use) ) {
			#region Llave
			var _index = search(use);
			
			if (_index >= 0) {
				// Remover contenido del struct
				var _delete = __keys[_index];
				variable_struct_remove(__content, _delete);
				
				// Remover
				array_delete(__keys, _index, 1);
			}
			#endregion
		}
		else if (is_array(use) ) {
			#region Array de elementos
			_delete = [];
			
			for (var i=0, len=array_length(use); i<len; i++) {
				var _in = remove(use[i], true);
				// Eliminado
				if (_in != undefined) array_push(_delete, _in);
			}
			
			#endregion
		}

		// Obtener tamaño
		if (!_it) __size = array_length(__keys);
		
		return _delete;
	}
	
	#region GET´S
	/// @param {String, Real} key	Llave o indice para obtener el valor
	static get = function(key) {
		return (is_string(key) ? 
			__content[$ key] : 
			__content[$ __keys[key] ] 
		);	
	}
	
	/// @param {Bool} [content?] Devolver contenido (true) o llave(false)
	/// @desc Devuelve el primer valor de la coleccion 
	static peekIn = function(content=true) { 
		var _first = __keys[0];
		return content ? __content[$ _first] : _first;  
	}
	
	/// @param {Bool} [content?] Devolver contenido (true) o llave(false)
	/// @desc Devuelve el ultimo valor de la coleccion 	
	static peekOut = function(content=true) { 
		var _last = __keys[__size - 1];
		return content ? __content[$ _last] : _last;  
	}
	
	/// @desc Devuelve el ultimo valor de la coleccion y lo elimina
	/// @return {Mixed}
	static pop = function() {
		var _last = peekOut();
		remove(__size - 1);
		return _last;
	}
	
	/// @desc Devuelve el primer valor de la coleccion y lo elimina
	/// @return {Mixed}
	static shift = function() {
		var _first = peekIn();
		remove(0);
		return _first;
	}
	
	/// @param {Bool} [content?] Devolver contenido (true) o llave(false)
	/// @desc Cicla los valores de la coleccion (izq->der)
	static cicle = function(content=true) {
		__cicle = max(0, min(__size - 1, __cicle) );
		return (content ? 
			__content[$ __keys[__cicle++] ] :
			__keys[__cicle++]
		);
	}
	
	#endregion
	
	/// @param {String, Array} key
	/// @desc Devuelve el indice de la llave
	static search = function(key) {
		// No existe salir rapido
		if (!exists(key) ) return undefined;
		
		var i=0 repeat(__size) {
			var _in = __keys[i++];
			if (_in == key) return i;
			i++;
		}
		
		return -1;
	}
	
	/// @param {Bool} [reset_cicle]
	/// @desc Devuelve el tamaño de la coleccion
	/// @return {Real} 
	static size = function(reset_cicle=false) {
		if (reset_cicle) __cicle = 0; // Para ciclar
		return (__size);
	}
	
	/// @desc True: Esta vacio False: tiene contenido
	/// @return {Bool}
	static empty = function() {
		return (__size == 0); 
	}
	
	/// @return {Struct.Collection} 
	/// @desc Reinicia los valores de la coleccion
	static clear = function() {
		__content = {};
		
		__keys = [];
		__last  = 0;
		__cicle = 0;
		
		__size = 0;
		
		return self;
	}
		
	/// @return {Struct.Collection}
	static copy = function() {
		var coll = (new Collection() ); /// @is {Collection}

		// Devolver valores
		var i = 0; repeat(__size) {
			var _key = __keys[i++];
			var _val = __content[$ _key];
			
			coll.set(_key, _val);
		}
		
		return (coll);
	}
	
	/// @returns {string}
	static toString = function() {
		return "size: " + string(__size);
	}
	
	#endregion
}

/// @param {Struct.Collection} _collection
/// @returns {Bool}
function is_collection(_collection) {
	return (is_struct(_collection) && (_collection.__is == "Collection") );
}
