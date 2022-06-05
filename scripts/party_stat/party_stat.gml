/// @param {String} _group_key
/// @param {Real} [_lvl]
/// @return {Struct.PartyStats}
function PartyStats(_group_key, _lvl=1) : MallComponent(_group_key) constructor {
	#region PRIVATE
	__lvl = _lvl; // -1 signfica que no se ha inicializado
    // CONDICIONES POSEEN  {bol: true-false, value: }
    __condition = function() {
		return {bol: true, value: 0}; 
	}
    
    __levelStart = MALL_DUMMY_METHOD;
    __levelEnd   = MALL_DUMMY_METHOD;
    
    __start = false;
	__default = undefined;
		
	#endregion
	
    #region METHODS
	/// @ignore
	/// @desc Crear cada estadistica
    static initialize = function() {
        var _stats = mall_get_stats();
        var _statGroup = mall_get_group(__key).__stats;   // Obtener las estadisticas personalizadas del grupo
		
        var i=0; repeat (array_length(_stats) ) {
			// Obtener llaves
			var _key  = _stats[i++];
			var _stat = _statGroup[$ _key];
			
			// Que exista la estadistica
			if (!is_undefined(_stat) ) {
				var _statComponent = new __PartyStatsComponent(_key, _stat);
				variable_struct_set(self, _key, _statComponent);
				if (MALL_PARTY_SHOW_MESSAGE) print("Mall Party: %s Creado!", _key);
			}
		}
		// Default component
		__default = _statComponent;
	}
	
	/// @param {String}	_key
	/// @param {Real}	_value
	/// @param {Bool}	[_toActual]
	/// @desc Establece el valor maximo de la estadistica a este nivel con limite el mayor y menor valor de la configuracion. (¡Solo usar cuando se sube de nivel!)
    /// @return {Struct.PartyStats}
	static setByLevel  = function(_key, _value, _toActual=false) {
		// Que no salga de los limites
		with (get(_key) ) {
			valueEquipment -= valueMax;
			valueMax    = clamp(_value, limit[0], limit[1] );
			valueEquipment += valueMax;
			
			if (_toActual) valueActual = valueEquipment;
		}
		
		return self;
    }
    
	/// @param	{String} _key
	/// @param	{Real} _value
	/// @desc	Establece el valor actual de una estadistica teniendo como limite mayor el "final" y menor el de la configuración
    /// @return {Struct.PartyStats}
	static set = function(_key, _value) {
        with (get(_key) ) {
			valueActual = clamp(_value, valueMin, valueEquipment);	
		}
		
        return self;
    }

	/// @param {String} _key
	/// @returns {Struct.__PartyStatsComponent}
	static get = function(_key) {
		return (self[$ _key] ?? __default);
	}

	/// @param {String}	_key
	/// @param {Real}	_add
	/// @param {Real}	_type
	/// @desc	Aumenta o disminuye el valor de una estadistica en base a a valueMin y valueEquipment devuelve el valor aumentado
	/// @return {Real}
    static add = function(_key, _add, _type=NUMTYPE.REAL) {
        var _stat = get(_key), _toAdd = 0;
		
		// Numtype
		if (is_array(_add) ) {
			_type = numtype_type (_add);
			_add  = numtype_value(_add);
		}
		
		// Si existe la estadistica
        if (!is_undefined(_stat) ) {
            switch (_type) {
                case NUMTYPE.REAL:		_toAdd += _add;							break;
                case NUMTYPE.PERCENT:	_toAdd += (_stat.valueActual * _add);	break;
            }
            
            set(_key, _stat.valueActual + _toAdd);
        }
        
        return (_toAdd);
    }
    
	/// @param	{String}	_key
	/// @param	{Real}		_value
	/// @param	{Real}		_type
	/// @desc	Regresa si un control esta afectando a esta estadistica y disminuye o aumenta el valor
    static passAffected = function(_key, _value, _type=NUMTYPE.REAL) {
		var _statGroup = mall_get_stat(_key);
		var _affected  = _statGroup.__affected;
        var _affectedNames = variable_struct_get_names(_affected);
		
        #region Pasar argumento
        if (is_undefined(_value) ) {
            var _stat = get(_key);
            _value = _stat.valueEquipment;
            _type  = numtype_type(_stat.base);
        }
		// Pasarse a sí mismo
		else if (is_array(_value) ) {
			_value = numtype_value(_value);
			_type  = numtype_type (_value);
        }
        
        #endregion
        
        var i = 0; repeat(array_length(_affectedNames) ) {
            var _ikey = _affectedNames[i++];    
            var _in = _affected[$ _ikey];
            
            var _iVal = numtype_value(_in);
            var _iTyp = numtype_type (_in);  
        }
    }
	  
    /// @param {String}	_key	Llave de estadistica
    /// @param {Array}	_base	Numtype
	/// @return {Struct.PartyStats}
    static setBase = function(_key, _base) {
		if (argument_count > 2) {
			var i=0; repeat((argument_count - 2) div 2) {
				setBase(argument[i++], argument[i++] );	
			}
		}
		else {
			get(_key).base = _base;
		}

        return self;
    }
    
    /// @param {Function}	_condition
    /// @param {String}		_key
    /// @desc permite establecer la condicion para subir de nivel global o individual
	/// @return {Struct.PartyStats}
    static setCondition = function(_condition, _key) {
        // Comprobamos individual
		var _stat = get(_key);
		if (_stat.single) {
			_stat.condition = method(_stat, _condition);
		}
		else {
			__condition = method(undefined, _condition);	
		}

        return self;
    }
    
    /// @param {Function}	_start
    /// @param {Function}	_end
	/// @return {Struct.PartyStats}
    static setLevelEvents = function(_start, _end) {
        __levelStart = method(undefined, _start);
        __levelEnd   = method(undefined,   _end);
        
        return self;
    }
    
    /// @param {Real}	_lvl
    /// @param {String} _key
	/// @return {Struct.PartyStats}
    static setLevel = function(_lvl, _key) {
		var _stat = get(_key);
		if (_stat.single) {
			_stat.lvl = _lvl;	
		}
		else {
			__lvl = _lvl;
		}
		
		// Subir de nivel
		levelUp(0, true);
		
        return self;
    }
    
    /// @param {Real} _operate
    /// @param {Bool} _force
    static levelUp = function(_operate=0, _force=false) {
        var _keys = mall_get_stats();
        var _statGroup = mall_get_group(__key);  // Obtener estadisticas     
        var _return = [];
		var _globalCheck = undefined;
		
		__lvl += _operate;
			
        // Ejecutar funcion al ejecutar
        __levelStart();
        
        // Ciclar por las estadisticas
        var i=0; repeat(array_length(_keys) ) {
            var _key   = _keys[i++];				// Obtener llave
            var _statMaster = _statGroup.getStat(_key);	// Obtener configuracion del grupo  
            
            // Si no existe evitar
            if (is_undefined(_statMaster) ) i++; continue;
            
			// Obtener struct
            var _stat = get(_key);
            
            var _useLevel = 1;
			var _localCheck = false;
            var _toMax = false;
            var _toMin = false;
            var _toAdd = 0;
			
            #region Comprobar si sube de nivel solo o no
            if (_stat.single) {
                _stat.lvl += _operate;  // Actualizar nivel individual
                _useLevel = _stat.lvl;
                
                _localCheck = _stat.condition();
            } else {
                _useLevel = __lvl;
				// Solo una vez ya que EXP o otra estadistica puede pasar a 0 y cagar todos los demas niveles a lo estupido desgraciado
				_globalCheck ??= __condition();
            }
            
            #endregion
            
            // Agregar valor
            var _rest = (_stat.valueEquipment - _stat.valueMax);
            // Si se cumplen las condiciones para subir de nivel
            if ((_localCheck || (_globalCheck && _localCheck==undefined) )  || _force) {
                // Evitar errores al no establecer base
				_toAdd = _statMaster.execute(_useLevel, _stat, self);
				_toMax = _stat.toMax.work();
				_toMin = _stat.toMin.work();
  
                if (_toMax  && !_toMin) _stat.valueActual = _toAdd + _rest;   // Poner en el valor final
                if (!_toMax &&  _toMin) _stat.valueActual = _stat.valueMin;
				
				// Primer subida de nivel
				if (!__start) {
					if (_toMin) {
						_stat.valueLast = _statMaster.execute(max(1, _useLevel - 1), _stat, self);	
					}
					else {
						_stat.valueLast = _stat.limit[0];	
					}
				}
				else _stat.valueLast = _stat.valueMax;	
					
                // Primera subida de nivel
                var _check = (!_toMax && !_toMin);
                
                // Cambiar upper, final y actual
                setByLevel(_key, _toAdd, (_check && !__start) );
                
                // Mostrar los valores en el debugger
                if (PARTY_STAT_SHOWMESSAGE) {
					show_debug_message(_key + ": " + string(_toAdd) );
				}
                
                // Poner valores para regresar
                array_push(_return, {
					key: _key, 
					valueActual:	_stat.valueActual, 
					valueMax:		_stat.valueMax, 
					valueLast:		_stat.valueLast, 
					valueEquipment: _stat.valueEquipment
				}); 
            }
        }
        
        // Ejecutar funcion al terminar de subir de nivel
        __levelEnd();
        
        // Se cumplio la primera subida de nivel
        __start = true;
        
        return _return;
    }
    
    /// @param {String} _key
    /// @returns {Bool}
    static exists = function(_key) {
        return (variable_struct_exists(self, _key) );
    }
    
    /// @param {String} _key
    /// @param {Real}	_value
	/// @return {Bool}
    static isAbove = function(_key, _value) {
        return (get(_key).valueActual > _value);
    }
    
    /// @param {String} _key
    /// @param {Real}	_value
	/// @return {Bool}
    static isBelow = function(_key, _value) {
        return (get(_key).valueActual < _value);
    }
    
    /// @desc Para debug
    /// @returns {string}
    static toString = function() {
        /// @return {String}
		static p = function(_value, _type) {
            var _in = ( (_type == NUMTYPE.PERCENT) ? 
				string(_value) + "%" : 
				string(_value)
            );
			
            return (_in + "\n");
        }

        var _keys  = mall_get_stats();  
		var _print = "";
        var i=0; repeat(array_length(_keys) ) {
            var _key  = _keys[i++];
            var _stat = get(_key); 
			var _type = numtype_type(_stat.base);
            
            // Nombre
            _print += _key + "\n";
            
            if (_type == NUMTYPE.REAL) {
				_print += "type: Real \n";
			} 
			else {
				_print += "type: Percent \n"; 
			}
            
            _print += "equipment.value: "	+ p(_stat.valueEquipment, _type);
            _print += "max.value: "			+ p(_stat.valueMax		, _type);
            _print += "actual.value: "		+ p(_stat.valueActual	, _type);
        }
        
        show_debug_message(_print);
        return _print;
    }
    
    #endregion
    
	initialize();
}

/// @ignore 
/// @param {String} _key
/// @param {Struct.MallStat} _stat
/// @return {Struct.__PartyStatsComponent}
function __PartyStatsComponent(_key, _stat) : MallComponent(_key) constructor {
	#region PRIVATE
	/// @ignore
	__displayKey = _stat.__displayKey;	// Llave para obtener el nombre de display
	/// @ignore
	__displayTextKey = _stat.__displayTextKey;	// Textos extras
	/// @ignore
	__return = method(self, _stat.__displayMethod);	// Como devolver sus valores
	
	#endregion
	
	#region PUBLIC
	base = numtype_copy(_stat.__initial);
	lvl  = 1;					// Nivel de la estadistica si se usa individualmente
	single = _stat.__lvlSingle	// Si sube de nivel individualmente
	limit  = _stat.__limits;	// Referencia a los limites de la configuracion
	condition = MALL_DUMMY_METHOD;	// Condicion que debe cumplir para subir de nivel

	// Valores que posee
	valueEquipment = numtype_value(base);	// Valor de la estadistica con los cambios producidos por equipamiento
	
	valueMax = valueEquipment;	// Valor de la estadistica actual maximo
	valueMin = limit[0];		// Valor minimo en que la estadistica puede estar
	
	valueLast   = valueEquipment;	// Valor "valueMax" anterior 
	
	valueActual = valueEquipment;	// Valor de la estadistica 
	
	toMax = _stat.__toMax.copy();	// Copiar contadores para que no hayan conflictos
	toMin = _stat.__toMin.copy();	// Copiar contadores para que no hayan conflictos

	#endregion
}