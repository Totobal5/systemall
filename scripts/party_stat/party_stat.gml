/// @param {Real}	[start_level]
/// @return {Struct.PartyStats}
function PartyStats(_level=1) constructor 
{
	#region PRIVATE
	__is = instanceof(self);
	
	// Primer inicio
	__initialize = false;
	// Referencia a la estadistica
	__entity = weak_ref_create({});
	
	#region eventos
	
	/// @param {Struct.PartyStats}	[stat_entity]
	/// @return {Bool}
	__levelCheck = function(STAT_ENTITY) {return false;};	// Condicion global para subir de nivel
	
    __levelStartEvent  = function() {};	// Al iniciar  de subir de nivel
    __levelFinishEvent = function() {};	// Al terminar de subir de nivel

	#endregion
	
	
	#endregion
	
	#region PUBLIC
	level = _level;	// Nivel global

	#endregion

    #region METHODS
	/// @ignore
	/// @desc Crear cada estadistica
    static initialize = function() 
	{
		mall_stat_foreach(method(undefined, function(_STAT, _KEY) {
			var _statAtom = new __PartyStatsAtom(_KEY, _STAT);
			variable_struct_set(self, _KEY, _statAtom);
			
			if (MALL_PARTY_SHOW_MESSAGE) __mall_trace("Stat " + string(_KEY) + " creado");
		}) );
	}
	
	#region Configuracion
	/// @param {Struct.PartyEntity}	party_entity
	static setEntity = function(_ENTITY)
	{
		__entity = weak_ref_create(_ENTITY);
		return self;
	}
	
	/// @return {Struct.PartyEntity}
	static getEntity = function()
	{
		// Feather ignore all
		return (__entity.ref);
	}
	
    /// @param {String}				stat_key	Llave de estadistica
	/// @param {Real}				base_value	valor de base
    /// @param {ENUM.MALL_NUMTYPE}	base_type	tipo de numero
	/// @return {Struct.PartyStats}
    static setBase = function(_KEY, _VALUE, _TYPE) 
	{
		var i=0; repeat(argument_count div 3)
		{
			var _key  = argument[i];
			var _atom = get(_key);
			// Actualizar valores bases
			_atom.base = [
				argument[i+1], 
				argument[i+2] 
			];
		
			i += 1;
		}

        return self;
    }
	
	/// @param {String}	stat_key	Llave de estadistica
	/// @param {Any*}	flag		Flag para colocar en la estadistica
	static setFlag = function(_KEY, _FLAG)
	{
		var _atom = get(_KEY);
		_atom.__flag = _FLAG;
		return self;
	}
	
	/// @param {String}	stat_key	Llave de estadistica
	/// @return {Any}
	static getFlag = function(_KEY)
	{
		return (get(_KEY).__flag);
	}
	
	/// @desc permite establecer la condicion para subir de nivel global o individual
    /// @param {Function}	level_check
	/// @param {String}		[stat_key]
	/// @return {Struct.PartyStats}
    static setLevelCheck = function(_CHECK, _KEY) 
	{
		#region Global
		if (is_undefined(_KEY) )
		{
			__levelCheck = method(undefined, _CHECK);
		}
		#endregion
		
		#region Individual
		else if (is_string(_KEY) )
		{
			var _stat = get(_KEY);
			if (_stat.__single)
			{
				_stat.__check = method(_stat, _CHECK);
			}
		}
	
		#endregion
		
        return self;
    }
    
    /// @param {Function}	level_start_event	
    /// @param {Function}	level_finish_event	
	/// @return {Struct.PartyStats}
    static setLevelEvent = function(_START, _FINISH) 
	{
        __levelStartEvent  = method(undefined,  _START);
        __levelFinishEvent = method(undefined, _FINISH);
        
        return self;
    }

    /// @param {Function}	level_start_event	
	static setLevelEventStart  = function(_START)
	{
		__levelStartEvent = method(undefined, _START);
		return self;
	}

    /// @param {Function}	level_finish_event	
	static setLevelEventFinish = function(_FINISH)
	{
		__levelFinishEvent = method(undefined, _FINISH);
		return self;
	}

	/// @desc Ejecuta el displayMethod del stat
	/// @param {String} stat_key
	static eventDisplay = function(_KEY)
	{
		var _atom = get(_KEY);
		return (_atom.__displayMethod() );	
	}

	#endregion

	/// @desc Obtiene un PartyStatAtom a partir de la llave
	/// @param {String} stat_key
	/// @returns {Struct.__PartyStatsAtom}
	static get = function(_KEY) 
	{
		var _atom = variable_struct_get(self, _KEY);
		return (_atom);
	}
	
	/// @desc	Establece el valor actual de una estadistica teniendo como limites "limMin" y "control"
	/// @param	{String}			stat_key
	/// @param	{Real}				value
    /// @param  {ENUM.MALL_NUMTYPE}	numtype	
	/// @return {Real}
	static set = function(_KEY, _VALUE, _TYPE=MALL_NUMTYPE.REAL) 
	{
		var _stat = get(_KEY);
		if (is_undefined(_stat) ) return 0;
		
		with (_stat)
		{
			switch (_TYPE)
			{
				case MALL_NUMTYPE.REAL:		
				lastActual = actual;
				actual = clamp(_VALUE, limMin, control);
				break;
				
				case MALL_NUMTYPE.PERCENT:
				var _percent = (control * _VALUE) / 100;
				lastActual = actual;
				actual = clamp(_VALUE, limMin, control);
				break;
			}
			
			return (actual);
		}
    }

	/// @desc	Suma/Resta "valueActual" de una estadistica teniendo como limite "valueControl" y "valueMin". Devuelve el valor que se añadio
	/// @param {String}				stat_key	Llave de estadistica
	/// @param {Real}				value		Valor para sumar/restar
	/// @param {ENUM.MALL_NUMTYPE}	numtype		Tipo de numero
	/// @param {Real}				[use_value]	Que "value" usar 0: actual, 1:lastActual, 2: Peak, 3: lastPeak, 4: equipment, 5: control, Solo porcentajes!
	/// @return {Real}
    static add = function(_KEY, _VALUE, _TYPE=MALL_NUMTYPE.REAL, _USE=0) 
	{
        var _stat = get(_KEY);
		if (is_undefined(_stat) ) return 0;
		var _add = 0;
		// Depende del number type
        switch (_TYPE) 
		{
			#region Real
			case 0: _add += _VALUE; break;
				
			#endregion
				
            #region Porcentaje
			case 1:	
				var _use=0;
				switch (_USE)
				{
					case 0: _use = _stat.actual;		break;
					case 1: _use = _stat.lastActual;	break;
					
					case 2: _use = _stat.peak;			break;
					case 3: _use = _stat.lastPeak;		break;
					
					case 4: _use = _stat.equipment;		break;
					case 5: _use = _stat.control;		break;
				}
					
				_add += (_use * _VALUE);	
			break;
			#endregion
        }
            
        set(_KEY, (_stat.actual + _add) );
        
        return (_add);
    }


	/// @desc Cambia el valueControl
	static addControl = function(_KEY, _VALUE, _TYPE)
	{
		var _stat = get(_KEY);
		with (_stat)
		{
			switch (_TYPE)
			{
				case 0:		break;
				case 1:		break;
			}
		}
		
		var _stats = getReference().getStats();
		var _stat  = _stats.get(_key);
			
		if (!is_undefined(_stat) ) 
		{
			var _control = get(_key);
			var _real, _percent;
			with (_stat)
			{
				_real	 = _control.values[NUMTYPES.REAL];
				_percent = (valueEquipment * _control.values[NUMTYPES.PERCENT] );
				valueControl = valueEquipment + _real + _perc;	
			}
		}		
		
	}
	

    /// @param {Real}	new_level	Nuevo nivel
    /// @param {String} [stat_key]	Solo si es individual
	/// @return {Struct.PartyStats}
    static setLevel = function(_LEVEL, _KEY) 
	{
		#region Global
		if (is_undefined(_KEY) )
		{
			level = _LEVEL;		
		}
		#endregion
		
		#region Individual
		else if (is_string(_KEY) )
		{
			var _stat = get(_KEY);
			_stat.level = _LEVEL;
		}
		#endregion
			
		// Subir de nivel
		eventLevel(,true);
		
        return self;
    }
    
    /// @param {Real} [add_level]	Sumar/restar el nivel actual
    /// @param {Bool} [force_level]	Fuerza a subir de nivel
    static eventLevel = function(_OPER=0, _FORCE=false) 
	{
        var _keys = mall_get_stat_keys();
		var _size = array_length(_keys);
        var _return = [];
		var _globalCheck = undefined;
		
		// operar level
		level += _OPER;
			
        // Ejecutar funcion al ejecutar
        __levelStartEvent();
        
        #region Ciclar por las estadisticas
		for (var i=0; i < _size; i += 1)
		{
			var _key  = _keys[i]; // Obtener llave
			
			// obtener structs
			var _stat = get(_key);

            var _localLevel = 1;
			var _localCheck = false;
            var _toAdd = 0;
			
            #region Nivel solo
            if (_stat.__single) 
			{
				// Actualizar nivel individual
                _stat.level += _OPER;  
				
                _localLevel = _stat.level;
				_localCheck = _stat.__check(self);	// Ver si se consiguio la condicion	
            } 
			#endregion
			
			#region Nivel global
			else 
			{
                _localLevel = level;
				// Solo una vez ya que EXP o otra estadistica puede pasar a 0 y cagar todos los demas niveles a lo estupido desgraciado
				_globalCheck ??= __levelCheck(self);
            }
            #endregion
            
            // Valor de las modificaciones
			var _notControl   = (_stat.control   - _stat.equipment);
            var _notEquipment = (_stat.equipment - _stat.peak);
			
            #region Si se cumplen las condiciones para subir de nivel o se fuerza subir de nivel
            if ((_localCheck || (_globalCheck && _localCheck==undefined) )  || _FORCE) 
			{
                // Obtener valor al subir de nivel
				_toAdd = _stat.__event(self, _stat, _localLevel);
				
				#region Iteracion
				var _toIter = _stat.__toValue.iterate();
				// to max || to min
				var _toBool = _stat.__toValue.active();
				var _toType = _stat.__toValue.type();
				
				if (_toBool) 
				{
					if (_toType) 
					{
						// to min
						_stat.actual = _stat.limMin; 
					} 
					else
					{
						// to max
						_stat.actual = _toAdd + _notControl + _notEquipment; 
					}
				}
				#endregion
				
				#region Si es la primera subida de nivel obtener el maximo anterior
				if (!__initialize) 
				{
					if (_toBool) _stat.lastPeak = (_toType) ? 
						_stat.__event(self, _stat, max(1, _localLevel - 1) ) :
						_stat.limMin; 
				}
				#endregion
				
				#region Actualizar valor maximo anterior
				else
				{
					_stat.lastPeak = _stat.peak;
				}
				#endregion
					
                // Cambiar upper, final y actual
                __setUseInLevel(_key, _toAdd, (!_toBool && !__initialize) );
                
                // Mostrar los valores en el debugger
                __mall_trace(_key + ": " + string(_toAdd) );
                
                // Poner valores para regresar
                array_push(_return, _stat.send() ); 
            }
			#endregion
        }
        
		#endregion
		
        // Ejecutar funcion al terminar de subir de nivel
        __levelFinishEvent();
        __initialize = true; // Se cumplio la primera subida de nivel
        
        return (_return );
    }
    
	#region Utils

	/// @desc Si el valor introducido es mayor que el actual de la estadistica devuelve true
    /// @param {String} stat_key
    /// @param {Real}	compare
	/// @return {Bool}
    static isAbove = function(_KEY, _VALUE) 
	{
		var _atom = get(_KEY)
        return (_atom.actual > _VALUE);
    }
    
	/// @desc Si el valor introducido es menor que el actual de la estadistica devuelve true
    /// @param {String} stat_key
    /// @param {Real}	compare
	/// @return {Bool}
    static isBelow = function(_KEY, _VALUE) 
	{
		var _atom = get(_KEY)
        return (_atom.actual < _VALUE);
    }
	
	#endregion

	#region Misc
    /// @desc Para debug
    /// @returns {string}
    static toString = function() 
	{
        /// @return {String}
		static p = function(_VALUE, _TYPE) {
            var _in = ( (_TYPE == 1) ? 
				string(_VALUE) + "%" : 
				string(_VALUE)
            );
			
            return (_in + "\n");
        }

        var _keys  = mall_get_stat_keys();  
		var _print = "";
        var i=0; repeat(array_length(_keys) ) 
		{
            var _key  = _keys[i++];
            var _stat = get(_key); 
			var _type = _stat.baseType;
            
            // Nombre
            _print += _key + "\n";
            
			#region Obtener numtype
            if (_type == 0) 
			{
				_print += "type: Real \n";
			} 
			else 
			{
				_print += "type: Percent \n"; 
			}
            
			#endregion
			
			_print += "actual.value: "		+ p(_stat.valueActual	, _type);
            _print += "max.value: "			+ p(_stat.valueMax		, _type);
            _print += "equipment.value: "	+ p(_stat.valueEquipment, _type);
			_print += "control.value: "		+ p(_stat.valueControl  , _type);
        }
        
        show_debug_message(_print);
        return _print;
    }
	
	/// @ignore
	/// @desc	Establece el valor maximo de la estadistica a este nivel con limite el mayor y menor valor de la configuracion. 
	///			(¡Solo usar cuando se sube de nivel!)
	/// @param {String}	stat_key
	/// @param {Real}	value
	/// @param {Bool}	[to_control]
    /// @return {Struct.PartyStats}
	static __setUseInLevel  = function(_KEY, _VALUE, _TO=false) 
	{
		// Que no salga de los limites
		var _stat = get(_KEY);
		with (_stat)
		{
			var _control   = control   - equipment;	// Obtener el resto del control
			var _equipment = equipment - peak;		// Obtener el resto del equipo
		
			// Cambiar valor maximo de nivel
			peak = clamp(_VALUE, limMin, limMax);
			
			// Restaurar
			equipment = peak + _equipment;
			control = equipment + _control;
			
			if (_TO) actual = control;
		}
		
		return self;
    }
    
	#endregion
	
    #endregion
    
	initialize();
}