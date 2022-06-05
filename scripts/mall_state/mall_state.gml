/// @desc Donde se guardan las propiedades de los estados
function MallState(_key) : MallComponent(_key) constructor {
	#region PRIVATE
	__init    = numtype(false, NUMTYPE.BOOLEAN);	// Valor inicial
	__compare = numtype(false, NUMTYPE.BOOLEAN);	// Con que valor comparar
	
	__resists = {};	// Que estadistica resiste a este estado. Se usa un struct ya que es más rapido para buscar.
	__action  = {}; // Que accion afecta este estado 
	
	/// @type {Struct.Counter}
    __prop = (new Counter(0, 0) ).changeType(0);
    __eventStr = MALL_DUMMY_METHOD;  // Funcion a usar cuando se inicia el estado
    __eventUpd = MALL_DUMMY_METHOD;  // Funcion a usar cuando se actualiza el estado
    __eventEnd = MALL_DUMMY_METHOD;  // Funcion a usar cuando se finaliza el estado
    
    // Mensajes
    __propKey = [noone, noone, noone]; // Llaves para traducir
    __propInit   = "";  // Cuando inicia el estado
    __propUpdate = "";  // Cuando se actualiza el estado 
    __propEnd    = "";  // Cuando se termina el estado
	
	#endregion

    #region METHODS
    /// @param key
    /// @param ...
    /// @returns {MallState}
    static setResists  = function() {
        // Evitar indefenidos
        if (is_undefined(argument0) ) return self;
        
        if (!is_array(argument0) ) {
            var i=0; repeat(argument_count) {
                var _key = argument[i++];
                __resists[$ _key] = true;
            }
            
        } else { // Soporte array
            var _keys = argument0;
            
            var i=0; repeat(array_length(_keys) ) {
                var _key = _keys[i++];
                __resists[$ _key] = true;
            }
        }
        
        return self;
    }
    
    /// @param stat/part/action
    /// @param value
    /// @param number_type
    /// @param ...
    /// @returns {MallState}
    static SetAffected = function() {
        var _inside, _class, _temp, _type, _value;
		
		var _gStats = mall_actual_group().__stats;
		var _gParts = mall_actual_group().__parts;
		var _gAction = global.__mall_actions_master;
		
        // -- Comprobar si es una parte o estadistica
        var i = 0; repeat (argument_count div 3) {
            /// @type {Struct.MallComponent}
			_inside = argument[i++];
            
            _temp = argument[i++];
            _type = argument[i++];
            
            _value = numtype(_temp, _type);  

            if (!is_struct(_inside) ) {
                var _key = _inside;
                
                if (variable_struct_exists(_gStats, _key) ) {           // Es una estadistica
                    _class = _gStats[$ _key];    
            
                } else if (variable_struct_exists(_gParts, _key) ) {    // Es una parte
                    _class = _gParts[$ _key];
                    
                } else { 
                    // Guardar y seguir iterando
                    if (array_find(_gAction, _key, function(value, in, i) {return in==value; } ) ) {
                        __action[$ _key] = _value;
                        continue;
                    }
                }
                
            } else _class = _inside;
			
			// Añadir efecto al componente pasado
            _class.setAffected(__key, _value);
        }

        return self;
    }
    
    /// @param _init
    /// @param _update
    /// @param _end
    static setMessages = function(_init, _update, _end) {
        __propInit   =  _init;
        __propUpdate = _update;
        __propEnd    =    _end;
            
        return self;    
    }
    
    /// @param _min
    /// @param {Real} _max
    /// @param {Real} _aument
    /// @param {Real} _iterate_times
    /// @param {Function} _event_start
    /// @param {Function} _event_update
    /// @param {Function} _event_end
    static event = function(_min, _max, _aument, _iterate_times, _event_start, _event_update, _event_end) {
        // Es para siempre o hasta que se cure u.u
        if (is_undefined(_min) ) {
			__prop = noone;
            return self;
        }
        // Propiedades del counter
		__prop.setLimit(_min, _max).modify(_aument, max(1, _iterate_times) );
		
        // -- Metodos a usar
		__eventStr = _event_start  ?? __eventStr;
		__eventUpd = _event_update ?? __eventUpd;
		__eventEnd = _event_end    ?? __eventEnd;
		
        return self;
    }

    #endregion
}


