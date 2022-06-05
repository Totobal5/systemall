/// @param	{String} _key
/// @param	{Bool} [_init]
/// @desc	Un grupo es como debe funcionar los componentes guardados (MallStorage) entre sí. Esto sirve para diferenciar clases, especies o razas en distintos rpg (Humanos distintos a Orcos por ejemplo)
/// @return {Struct.MallGroup}
function MallGroup(_key, _init=false) constructor {
    #region PRIVATE
	__key = _key; // Nombre del grupo (Humano, Guerrero, etc)
    
    // Se utiliza un struct para guardar los datos y acceder rapidamente
    __stats    = {};
    __states   = {}; 
    __elements = {}; 
    __parts    = {}; 
    #endregion
	
    #region METHODS  
	#region CREATES
	/// @desc Inicia todas las estructuras 
    static create = function() {
        createStats ();
        createStates();
        createParts ();
        createElements();
    }
	
	/// @param {Array<String>} _delete_array
	/// @desc Permite eliminar estadisticas del array para luego agregarlo al struct 
    static createStats  = function(_delete_array) {    
        var _keys = mall_get_stats();   // Obtener llaves
		
		var _len   = array_length(_keys);
		var _delen = array_length(_delete_array);
        var _content = {};
        
        // Eliminar llaves
		var _delete = false;
		var i=0; repeat(_len) {
			var _key = _keys[i++];	
			
			var j=0; repeat(_delen) {
				var _delkey = _delete_array[j++];
				if (_key != _delkey) {
					_delete = true; break;
				}
			}	
			
			if (!_delete) _content[$ _key] = new MallStat(_key);
			_delete = false;
		}

        __stats = _content;
    }
    
    /// @param {Array<String>} _delete_array
	/// @desc Permite eliminar estados del array para luego agregarlo al struct 	
    static createStates = function(_delete_array) {
        var _keys = mall_get_states();   // Obtener llaves
		
		var _len   = array_length(_keys);
		var _delen = array_length(_delete_array);
        var _content = {};
        
        // Eliminar llaves
		var _delete = false;
		var i=0; repeat(_len) {
			var _key = _keys[i++];	
			
			var j=0; repeat(_delen) {
				var _delkey = _delete_array[j++];
				if (_key != _delkey) {
					_delete = true; break;
				}
			}	
			
			if (!_delete) _content[$ _key] = new MallState(_key);
			_delete = false;
		}

        __states = _content;
    }
    
    /// @param {Array<String>} _delete_array
	/// @desc Permite eliminar partes del array para luego agregarlo al struct 
    static createParts  = function(_delete_array) {
        var _keys = mall_get_parts();   // Obtener llaves
		
		var _len   = array_length(_keys);
		var _delen = array_length(_delete_array);
        var _content = {};
        
        // Eliminar llaves
		var _delete = false;
		var i=0; repeat(_len) {
			var _key = _keys[i++];	
			
			var j=0; repeat(_delen) {
				var _delkey = _delete_array[j++];
				if (_key != _delkey) {
					_delete = true; break;
				}
			}	
			
			if (!_delete) _content[$ _key] = new MallPart(_key);
			_delete = false;
		}

        __states = _content;
    }
    
    /// @param {Array<String>} _delete_array
	/// @desc Permite eliminar elementos del array para luego agregarlo al struct
    static createElements = function(_delete_array) {
        var _keys = mall_get_elements();   // Obtener llaves
		
		var _len   = array_length(_keys);
		var _delen = array_length(_delete_array);
        var _content = {};
        
        // Eliminar llaves
		var _delete = false;
		var i=0; repeat(_len) {
			var _key = _keys[i++];	
			
			var j=0; repeat(_delen) {
				var _delkey = _delete_array[j++];
				if (_key != _delkey) {
					_delete = true; break;
				}
			}	
			
			if (!_delete) _content[$ _key] = new MallElement(_key);
			_delete = false;
		}

        __states = _content;
    }
	#endregion
	
	/// @param {String} _key
	/// @return {Struct.MallStat}
	static getStat  = function(_key) {
		return __stats [$ _key]; 
	}
	
	/// @param {String} _key
	/// @return {Struct.MallState}
	static getState = function(_key) {
		return __states[$ _key]; 
	}
	
	/// @param {String} _key
	/// @return {Struct.MallPart}
	static getPart  = function(_key) {
		return __parts [$ _key]; 
	}
	
	/// @param {String} _key
	/// @return {Struct.MallElement}
	static getElement = function(_key) {
		return __elements[$ _key];
	}

    #endregion
    
    // Iniciar
    if (_init) create();
}