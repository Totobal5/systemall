/// @param {String} _group_key
/// @param {Bool}	_stats_unique
/// @param {Bool}	_states_unique
function PartyControl(_group_key, _stats_unique=false, _states_unique=true) : MallComponent(_group_key) constructor {
    #region PRIVATE
	__allKeys = [];
	__statUnique  = _stats_unique ;  // Si se permiten multiples ben/des a las estadisticas
    __stateUnique = _states_unique;  // Si se permiten más de un mismo estado
	#endregion
	
    #region METHODS
	/// @desc Iniciar control
    static initialize = function() {
        var _group = mall_get_group(__key);
        
        #region STATS
        var _statMaster = mall_get_stats(); // Obtener estadisticas
        var i = 0; repeat(array_length(_statMaster) ) {
            var _key  = _statMaster[i++];		// Obtener llaves    
            var _stat = _group.getStat(_key);    
             
			var _initial = _stat.__initial;
			var _value = numtype_value(_initial);
			var _type  = numtype_type (_initial);
			var _div = numtype_div(_initial);
			
			variable_struct_set(self, _key, new __PartyControlAtom(_type, _value, _div, __statUnique) );
			array_push(__allKeys, _key);
        }
        #endregion
        
        #region STATES
        var _stateMaster = mall_get_states();
        var i = 0; repeat(array_length(_stateMaster) ) {
            var _key   = _stateMaster[i++];		// Obtener llaves    
            var _state = _group.getState(_key);    

			var _initial = _stat.__initial;
			var _value = numtype_value(_initial);
			var _type  = numtype_type (_initial);
			var _div = numtype_div(_initial);			
			
			variable_struct_set(self, _key, new __PartyControlAtom(_type, _value, _div, __statUnique) );
			array_push(__allKeys, _key);
        }        
        #endregion
    }
    
    /// @param _key
    /// @param _value
    /// @param _type
    /// @desc Establece un nuevo valor en "update" con el tipo de numero default o diferente
    static set = function(_key, _value, _type) {
        var _control = get(_key);
		_type ??= _control.type;
        _control.update[_type] = _value;

		return self;
    }
    
    /// @param {String} _key
	/// @return {Struct.__PartyControlAtom}
    static get = function(_key) {
        return (self[$ _key] );
    }
    
    /// @param {String} _key
    /// @param {Real}	_operate
    /// @param {Real}	_type
    static add = function(_key, _operate, _type) {
        var _control = get(_key);
		_type ??= _control.type;
		
        switch (_type) {
			case NUMTYPE.REAL:		_control.update[_type] += _operate;			break;
			case NUMTYPE.BOOLEAN:	_control.update[_type]  = abs(_operate);	break;
			case NUMTYPE.PERCENT:	_control.update[_type] += _operate;			break;
        }
        
        return self;
    }
    
    /// @param {String} _key
	/// @desc Establebe el control a su valor inicial
    static reset = function(_key) {
        var _control = get(_key);
        _control.update[NUMTYPE.REAL]	 = _control.init;
		_control.update[NUMTYPE.PERCENT] = _control.init / 100;
		_control.update[NUMTYPE.BOOLEAN] = abs(_control.init);

        return self;
    }
    
	/// @desc Devuelve todos los controles al valor inicial
    static resetAll = function() {
		var i=0; repeat(array_length(__allKeys) ) {
			reset(__allKeys[i++] );	
		}

        return self;
    }
    
	/// @param {String} _key
    /// @param _effect
    /// @desc Agrega un efecto al control que afecta (stat/state/action)
    static addEffect  = function(_effect) {
        if (is_struct(_effect) ) {    
            var _key = _effect.__key;  // Obtener stat/state/action a la que afecta
			var _control = get(_key);
			
            // Existe
            if (!is_undefined(_control) ) { 
                // Agregar contenido a la box
                var _box = _control.box;
                
                // Permite varios
                if (is_array(_box) ) {
                    // No permite repetidos
                    if (!_control.same) {
                        var i = 0; repeat(array_length(_box) ) {     
                            var _in = _box[i++];
                            
                            if (_in.id == _effect.id) return false;
                        }
                    }
					// Agregar efecto
					else {
						array_push(_box, _effect);	
					}
                }
				// Solo permite 1
				else {    
                    reset(_key); // Reiniciar valores
                    _control.box = _effect;
                }
                // Indicar que esta siendo afectado
                _control.use = true;
                
				var _numtype = _effect.__value;
                var _value = numtype_value(_numtype);
                var _type  = numtype_type (_numtype);
                
                // Aumentar los valores de este control
                add(_key, _value, _type);
            }
        }
            
        return self;
    }
    
    /// @param {String} _key
    /// @param _id
    static deleteEffect = function(_key, _id) {
        var _control = get(_key);
        if (!is_undefined(_control) ) {
            var _box = _control.box;    
			// Permite varios
            if (is_array(_box) ) {
                // Buscar
                var i=0; repeat(array_length(_box) ) {
                    var _in = _box[i++];
                    
                    if (_in.id == _id) break;
                }
                
                // Eliminar
                array_delete(_box, i, 1);
                
                // Revisar si aun posee efectos
                if (array_empty(_box) ) _control.use = false;
            }
			// Solo 1
			else {
                var _in = _control.box;

                // Solo 1
                _control.box = undefined;
                _control.use = false;
            }
            
            // Quitar valores de este efecto
            add(_in.__key, -_in.__value[0], _in.__value[1] );            
        }
        
        return self;
    }
    
    /// @param {String} _key
	/// @return {Array}
    static update = function(_key) {
        var _return = [];
		var _control = get(_key);
		var _box = _control.box, _save;
        
        // Solo 1
		if (!is_undefined(_box) && !is_array(_box) ) {
			var _turns = _box.__turns;
			var _work  = _turns.work();
			var _count = _turns.getCount();

			if (_work) {
				// Si trabaja aumentar valor
				add(_key, _box.executeUpdate(self, _count) );
				_save = _control.update[_control.type];
			}
			else {
				_box.executeEnd(self, _count);
				_save = _control.update[_control.type];				
				reset(_key);
			}
			
			return [_save, _work];
		}
		// Varios
		else if (is_array(_box) ) {
			var _save = 0;
			for (var i=0, _len=array_length(_box); i<_len; i++) {
				var _in = _box[i++];
				var _turns = _in.__turns;
				var _work  = _turns.work();
				var _count = _turns.getCount();
				_save += _control.update[_control.type];				

				if (_work) {
					_box.executeUpdate(self, _count);
				}
				else {
					_box.executeEnd(self, _count);
					array_delete(_box, i, 1);
					_len--;
				}
			}
			
			return [_save, _work];
		}
    }
    
	/// @return {Array}
    static updateAll = function() {
		var _return = [];
		var i=0; repeat(array_length(__allKeys) ) {
			array_push(_return, update(__allKeys[i++] ) );	
		}
		
        return _return;
    }
    
	/// @param {String} _key
	/// @return {Bool}
    static exists = function(_key) {
        return (variable_struct_exists(self, _key) );
    }
    
    #endregion
    
    initialize();
}