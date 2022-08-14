/// @param {Struct.PartyEntity} party_entity
/// @param {Real} [level=1]
/// @return {Struct.PartyStats}
function PartyStats(_ENTITY, _LEVEL=1) : __PartyComponent(_ENTITY) constructor 
{
	with (_ENTITY) stats = other;
	__is = instanceof(self);

	level = _LEVEL;	// Nivel global
	/// @param {Struct.PartyStats}	[stat_entity]
	/// @return {Bool}
	checkLevel = function(STAT_ENTITY) {return false;};	// Condicion global para subir de nivel
	
    eventLevelStart  = function() {};	// Al iniciar  de subir de nivel
    eventLevelFinish = function() {};	// Al terminar de subir de nivel

	control   = _ENTITY.getControl();
	equipment = _ENTITY.getEquipment();
	flags = {};
	
    #region METHODS
	/// @ignore
	/// @desc Crear cada estadistica
    static initialize = function() 
	{
		mall_stat_foreach(method(undefined, function(_STAT, _KEY) {
			var _statAtom = new __PartyStatsAtom(_KEY, _STAT);
			variable_struct_set(self, _KEY, _statAtom);
			array_push(__keys, _KEY);
			
			if (MALL_PARTY_SHOW_MESSAGE) __mall_trace("Stat " + string(_KEY) + " creado");
		}) );
	}
	
	#region Basic
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
			_atom.base = _VALUE;
			_atom.type = _TYPE;
			i = i+1;
		}

        return self;
    }
	
	/// @param {String}	stat_key	Llave de estadistica
	/// @param {Any*}	flag		Flag para colocar en la estadistica
	static setFlag = function(_KEY, _FLAG)
	{
		var _atom = get(_KEY);
		_atom.flag = _FLAG;
		return self;
	}
	
	/// @param {String}	stat_key	Llave de estadistica
	/// @return {Any}
	static getFlag = function(_KEY)
	{
		return (get(_KEY).flag);
	}
	
	/// @desc permite establecer la condicion para subir de nivel global o individual
    /// @param {Function}	level_check
	/// @param {String}		[stat_key]
	/// @return {Struct.PartyStats}
    static setCheckLevel = function(_CHECK, _KEY) 
	{
		#region Global
		if (is_undefined(_KEY) )
		{
			checkLevel = method(undefined, _CHECK);
		}
		#endregion
		
		#region Individual
		else if (is_string(_KEY) )
		{
			var _stat = get(_KEY);
			if (_stat.single) _stat.check = method(_stat, _CHECK);
		}
	
		#endregion
		
        return self;
    }
    
    /// @param {Function}	level_start_event	
    /// @param {Function}	level_finish_event	
	/// @return {Struct.PartyStats}
    static setEventLevel = function(_START, _FINISH) 
	{
        eventLevelStart  = method(undefined,  _START);
        eventLevelFinish = method(undefined, _FINISH);
        
        return self;
    }

    /// @param {Function}	level_start_event	
	static setEventLevelStart  = function(_START)
	{
		eventLevelStart = method(undefined, _START);
		return self;
	}

    /// @param {Function}	level_finish_event	
	static setEventLevelFinish = function(_FINISH)
	{
		eventLevelFinish = method(undefined, _FINISH);
		return self;
	}

	/// @desc Ejecuta el displayMethod del stat
	/// @param {String} stat_key
	static getDisplay = function(_KEY)
	{
		return (get(_KEY).displayMethod );	
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
				actual = clamp(_VALUE, limitMin, control);
				break;
				
				case MALL_NUMTYPE.PERCENT:
				var _percent = (control * _VALUE) / 100;
				lastActual = actual;
				actual = clamp(_VALUE, limitMin, control);
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

	/// @desc actualiza el valor del control
	static updateControl   = function(_KEY)
	{
		var _stat	 = get(_KEY);
		var _control = control.get(_KEY);
		
		if (!is_undefined(_stat) )
		{
			with (_stat)
			{
				var _sumR = (equipment + _control.values[0] );
				var _sumP = (equipment * _control.values[1] ) / 100;
				control = _sumR + _sumP;
			}
		}
		return self;
	}
	
	/// @desc actualiza el valor del equipment
	static updateEquipment = function(_KEY, _INVERT=false)
	{
		var _stat = get(_KEY);
		var _equipment = equipment.get(_KEY);
		
		if (!is_undefined(_stat) )
		{
			var _item = _equipment.equipped, _value=0, _type=MALL_NUMTYPE.REAL;
			if (_item != undefined)
			{
				if (!_INVERT)
				{
					_value = _item.statsNormal[$ _KEY][0];
					_type  = _item.statsNormal[$ _KEY][1];
				}
				else
				{
					_value = _item.statsInvert[$ _KEY][0];
					_type  = _item.statsInvert[$ _KEY][1];
				}
			}

			with (_stat)
			{
				switch (_type)
				{
					case MALL_NUMTYPE.REAL:
					var _sum  = (peak + _value);
					equipment = _sum;
					break;
					
					case MALL_NUMTYPE.PERCENT:
					var _sumP = (peak * _value) / 100;
					equipment = _sum;
					break;
				}
			}
		}
		
		return self;
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
    static eventLevel = function(_LEVEL=0, _FORCE=false) 
	{
		var _size = array_length(__keys);
		// Para feather
		var _return = {statKey: {
			key: "",
			control:	0,
			equipment:	0,
			peak:		0,
			actual:		0,
			lastPeak:	0,
			lastActual:	0
		}};
		variable_struct_remove(_return, "statKey");
		
		var _globalCheck = undefined;
		
		// operar level
		level = level + _LEVEL;
		
		// Ejecutar funcion al ejecutar
		eventLevelStart();
		
		#region Ciclar por cada stat
		var i=0; repeat(array_length(__keys) )
		{
			// Feather ignore all
			var _key = __keys[i];
			var stat = get(_key);
			
			var _localCheck = undefined;
			var _localLevel = 1;
			if (stat.single)
			{
				stat.level += _LEVEL;
				_localLevel = stat.level;
				_localCheck = stat.check(self);
			}
			else
			{
				_localLevel    = level;
				_globalCheck ??= checkLevel(stat);
			}
			
			var _control   = (stat.control   - stat.equipment);
			var _equipment = (stat.equipment - stat.peak);
			if (_FORCE || (_localCheck || (_globalCheck && _localCheck!=undefined) ) )
			{
				var _sum = stat.event(self, stat, _localLevel);
				// Actualizar valores
				stat.peak = clamp(_sum, stat.limitMin, stat.limitMax);
				stat.equipment = _sum + _equipment;
				stat.control   = _sum + _equipment + _control;
				
				var _iter = stat.iterator.iterate();
				if (_iter == 2)
				{
					stat.actual = (_iter.type) ? 
						stat.control :
						stat.limitMin;
				}
				
				if (!__initialize) 
				{
					stat.lastPeak   = stat.event(self, stat, max(1, _localLevel - 1) );
					if (_iter == 2)
					{
						stat.lastActual = (_iter.type) ? 
							stat.lastPeak + _equipment + _control :
							stat.limitMin;
					}
				}
				
				// Mostrar los valores en el debugger
				__mall_trace(_key + ": " + string(_toAdd) );
				
				// Poner valores para regresar
				_return[$ _key] = stat.send(); 
			}
        }
        
		#endregion
		
        // Ejecutar funcion al terminar de subir de nivel
        eventLevelFinish();
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
			var _type = _stat.type;
            
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
			
			_print += "actual "		+ p(_stat.actual	, _type);
            _print += "peak "		+ p(_stat.peak		, _type);
            _print += "equipment "	+ p(_stat.equipment	, _type);
			_print += "control "	+ p(_stat.control	, _type);
        }
        
        show_debug_message(_print);
        return _print;
    }
	
	/// @desc Un foreach para cada llave
	static Stream = function(_FUN, _MORE)
	{
		var i=0; repeat(array_length(__keys) )
		{
			var _key = __keys[i];
			_FUN(get(_key), _key, i, _MORE);
			i = i+1;
		}
	}

	static getComponents = function()
	{
		control	  = __entity.ref.getControl();
		equipment = __entity.ref.getEquipment();
	}

	#endregion
	
    #endregion
    
	initialize();
}