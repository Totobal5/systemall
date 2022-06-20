/// @desc	Es un tipo de coleccion de datos que utiliza un struct para guardar contenidos y un array para guardar las llaves. Permite realizar ciertas acciones más rapido
/// @return {Struct.Collection}
function Collection() constructor 
{
	#region PRIVATE
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
	
	/// @param {String}	key
	/// @param {Any}	value
	/// @desc Añade un nuevo valor a la coleccion
	/// @returns {Struct.Collection}
	static set = function(_key, _value) 
	{
		if (!exists(_key) ) {
			array_push(__keys, _key);
			__size = array_length(__keys);
		}
		
		__content[$ _key] = _value;
		
		return self;
	}

	/// @param {Any} value
	/// @desc Establece todos los valores de la coleccion a un valor especificado
	/// @returns {Struct.Collection}
	static fill = function(_value) 
	{
		var i=0; repeat(__size) 
		{
			set(__keys[i++], _value);
		}
		
		return self;
	}
	
	/// @param {String} key
	/// @returns {Bool}
	static exists = function(_key) 
	{
		return (variable_struct_exists(__content, _key) );
	}
	
	/// @param	{String, Real}	key_or_index 
	/// @desc Elimina un valor de la coleccion usando un indice o una llave. Devuelve el valor eliminado
	/// @returns {Any}
	static remove = function(_to_remove) {
		var _delete = undefined;

		if (is_numeric(_to_remove) ) {
			#region Eliminar por indice
			var _string = __keys[_to_remove];
			
			_delete = __content[$ _string];
			variable_struct_remove(__content, _string);
			
			// Remover
			array_delete(__keys, _to_remove, 1);		
			#endregion
		}
		else if (is_string(_to_remove) ) {
			#region Eliminar por llave
			var _index = search(_to_remove);
			
			// Si existe la llave
			if (_index >= 0) 
			{
				// Remover contenido del struct
				var _delete = __content[$ _to_remove];
				variable_struct_remove(__content, _to_remove);
				
				// Remover
				array_delete(__keys, _index, 1);
			}
			#endregion
		}

		// Obtener tamaño
		__size = array_length(__keys);
		
		return (_delete );
	}
	
	/// @param {String, Real}	key_or_index	string or real > 0
	/// @desc Devuelve un valor
	/// @returns {Any}
	static get = function(_key) 
	{
		return (is_string(_key) ? 
			__content[$ _key] : 
			__content[$ __keys[_key] ] 
		);	
	}
	
	/// @param {Bool} [content] Devolver contenido (true) o llave(false)
	/// @desc Devuelve el primer valor de la coleccion 
	static first = function(_content=true) 
	{ 
		var _first = __keys[0];
		return _content ? __content[$ _first] : _first;  
	}
	
	/// @param {Bool} [content] Devolver contenido (true) o llave(false)
	/// @desc Devuelve el ultimo valor de la coleccion 	
	static last  = function(_content=true) 
	{ 
		var _last = __keys[__size - 1];
		return _content ? __content[$ _last] : _last;  
	}
	
	/// @desc Devuelve el ultimo valor de la coleccion y lo elimina
	/// @return {Mixed}
	static pop = function() 
	{
		var _last = last();
		remove(__size - 1);
		return _last;
	}
	
	/// @desc Devuelve el primer valor de la coleccion y lo elimina
	/// @return {Mixed}
	static shift = function() 
	{
		var _first = first();
		remove(0);
		return _first;
	}
	
	/// @param {Bool} [content?] Devolver contenido (true) o llave(false)
	/// @desc Cicla los valores de la coleccion (izq->der)
	static cicle  = function(_content=true) 
	{
		__cicle = max(0, min(__size - 1, __cicle) );
		return (_content ? 
			__content[$ __keys[__cicle++] ] :
			__keys[__cicle++]
		);
	}
	
	/// @param {Function}	filter_method	function(value, key, i) {return true;}
	/// @desc Devuelve un array con todos los elementos que devolvieron true al metodo ingresado
	static filter = function(_method)
	{
		var _array = [];
		var i=0; repeat(__size)
		{
			var _key = __keys[i];
			var _val = __content[$ _key];
			
			// Solo si es true
			if (_method(_val, _key, i) ) array_push(_array, _val);	
			++i;
		}
		
		return (_array );
	}

	/// @param {Function}	filter_method	function(value, key, i) {return some_value;}
	/// @desc Devuelve un array con el resultado de la funcion al ingresar un elemento por ella
	static map = function(_method)
	{
		var _array = [];
		var i=0; repeat(__size)
		{
			var _key = __keys[i];
			var _val = __content[$ _key];
			
			// Ingresar
			array_push(_array, _method(_val, _key, i) );
			++i;
		}
		
		return (_array );			
	}

	/// @param {Function}	filter_method	function(value, key, i) {return if (nice) {return true;} else {return false;} }
	/// @desc Devuelve true si cada elemento devuelve true en la funcion pasada
	static every = function(_method)
	{
		var i=0; repeat(__size)
		{
			var _key = __keys[i];
			var _val = __content[$ _key];
			
			if (!_method(_val, _key, i) ) return false;
			++i;
		}	
		
		return true;
	}
	
	/// @param	{Function}	filter_method	function(value, key, i) {return ;}
	/// @desc Simplemente pasa una funcion por cada elemento de esta coleccion.
	static foreach = function(_method)
	{
		var i=0; repeat(__size)
		{
			var _key = __keys[i];
			var _val = __content[$ _key];
			
			_method(_val, _key, i);
			++i;
		}	
	}
	
	/// @param {String} key
	/// @desc Devuelve el indice de la llave. -1 si no existe
	static search = function(_key) 
	{
		// No existe salir rapido
		if (!exists(_key) ) return -1;
		
		var i=0 repeat(__size) 
		{
			var _in = __keys[i++];
			if (_in == _key) return i;
			i++;
		}
		
		return -1;
	}
	
	/// @param {Bool} [reset_cicle]
	/// @desc Devuelve el tamaño de la coleccion
	/// @return {Real} 
	static size = function(_reset_cicle=false) 
	{
		if (_reset_cicle) __cicle = 0; // Para ciclar
		return (__size);
	}
	
	/// @desc True : Esta vacio 
	///		  False: tiene contenido
	/// @return {Bool}
	static empty = function() 
	{
		return (__size == 0); 
	}
	
	/// @return {Struct.Collection} 
	/// @desc Reinicia los valores de la coleccion
	static reset = function() 
	{
		__content = {};
		
		__keys = [];
		__last  = 0;
		__cicle = 0;
		
		__size = 0;
		
		return self;
	}
		
	/// @desc Devuelve una copia de esta coleccion
	/// @return {Struct.Collection}
	static copy = function() 
	{
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
	static toString = function() 
	{
		return "size: " + string(__size);
	}
	
	#endregion
}

/// @param {Struct.Collection} collection
/// @returns {Bool}
function is_collection(_collection) 
{
	return (is_struct(_collection) && (instanceof(_collection) == "Collection") );
}