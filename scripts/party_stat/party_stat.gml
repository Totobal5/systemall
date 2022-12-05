/// @param {Struct.PartyEntity} partyEntity
/// @param {Real} [level]=1
/// @return {Struct.PartyStat}
function PartyStat(_entity=other, _level=1) : Mall() constructor 
{
	from = weak_ref_create(_entity);	// Crear referencia a la entidad
	keys = [];
	array_foreach(mall_get_stat_keys(), function(_key) {
		var _component = mall_get_stat(_key);
		variable_struct_set(self, _key, new createAtom(_component) );
		array_push(keys, _key);
		if (MALL_PARTY_TRACE) show_debug_message("MallRPG Party (prStat): {0} creado", _key);
	});
	
	// Nivel global
	level = _level;
	
	/// @param {Struct.PartyStats}	[stat_entity]
	/// @return {Bool}
	checkLevel = function(STAT_ENTITY) {return false;} // Condicion global para subir de nivel
	
    eventLevelStart  = function() {};	// Al iniciar  de subir de nivel
    eventLevelFinish = function() {};	// Al terminar de subir de nivel

	flags = {};
	
    #region METHODS
	
	static createAtom = function(_stat) constructor 
	{
		/// @ignore
		is = "createAtom";
	
		key = _stat.key;
		displayKey = _stat.displayKey;
	
		// -- Configuracion
		flag   = _stat.flags;		// Que pasar en la formula para subir de nivel
		single = _stat.levelSingle; // Si sube de nivel individualmente
	
		eventEquipStart  = _stat.eventObjectStart;	// Al equipar un objeto (inicio) ejecuta esta funcion
		eventEquipFinish = _stat.eventObjectFinish;	// Al equipar un objeto (final)  ejecuta esta funcion
	
		/// @param {Struct.PartyStats}		 stat_entity
		/// @param {Struct.__PartyStatsAtom} stat_atom
		/// @param {Any} [flag]
		/// @return {Real}
		event = function(_stat, _atom, _flag) {};
		event = method(self, _stat.eventLevel); // Forma en que sube de nivel
	
		/// @param {Struct.PartyStats}	[stat_entity]
		/// @param {Any} [flag]
		/// @return {Bool}
		check = function(_stat, _flag) {};
		check = method(self, _stat.checkLevel); // Condicion que debe cumplir para subir de nivel
	
		iterator = _stat.iterator.copy();
	
		// Se pone el valor inicial
		base = _stat.start;
		type = _stat.type;
	
		level = 1; // Nivel de la estadistica si se usa individualmente
		// Valores que posee
		limitMin = _stat.limitMin;	// Valor maximo en que la estadistica puede estar
		limitMax = _stat.limitMax;	// Valor minimo en que la estadistica puede estar
	
		control   = base;	 // El valor final tomando en cuenta el control
		equipment = control; // El valor final tomando en cuenta el equipamiento
	
		peak   = control; // Valor de la estadistica actual maximo respecto al nivel
		actual = control; // El valor actual de la estadistica
	
		lastPeak   = control;// El ultimo valor maximo
		lastActual = control;// El anterior valor actual
	
		#endregion
	
		#region METHODS
		/// @desc Devuelve un struct con los valores actuales
		static send = function()
		{
			var _me = self;
			return 
			{
				key: _me.key,
				control:	_me.control,
				equipment:	_me.equipment,
				peak:		_me.peak,
				actual:		_me.actual,
				lastPeak:	_me.lastPeak,
				lastActual:	_me.lastActual
			}
		}
	
		static save = function() 
		{
			var _this = self;
			return ({
				version: MALL_VERSION,
				is:         _this.is,
				level:      _this.level,
				iterator:   _this.iterator.save()
			});
		}
	
	
		static load = function(_l) 
		{
			if (_l.is != is) exit;
			switch (_l.version) {
				default:
					iterator.load(_l.iterator);
					level = _l.level;
				break;
			}

			return self;
		}
	
		#endregion
	}
	
	#region Basic
	/// @param {String}             statKey     Llave de estadistica
	/// @param {Real}               baseValue   Valor de base
	/// @param {ENUM.MALL_NUMTYPE}  baseType    Tipo de numero
	/// @return {Struct.PartyStats}
	static setBase = function() 
	{
		var i=0; repeat(argument_count div 3) {
			var _key = argument[i];
			var _val = argument[i + 1];
			var _typ = argument[i + 2];
			
			var _atom = get(_key);
			// Actualizar valores bases
			_atom.base = _val;
			_atom.type = _typ;
			
			if (MALL_PARTY_TRACE) {
				var _typStr = toStringNumtype(_typ);
				show_debug_message("MallRPG Party: {0} base set to {1}{2}", _key, _val, _typStr);
			}
			
			i = i + 3;
		}

		return self;
	}


	/// @desc Las flags sirven para que en las funciones se pueda hacer un switch dependiendo del entity
	/// @param {String}	stat_key	Llave de estadistica
	/// @param {Any*}	flag		Flag para colocar en la estadistica
	static setFlag = function(_KEY, _FLAG)
	{
		flags[$ _KEY] = _FLAG
		return self;
	}


	/// @param {String}	stat_key	Llave de estadistica
	/// @return {Any}
	static getFlag = function(_KEY)
	{
		return (flags[$ _KEY] );
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
			checkLevel = method(self, _CHECK);
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

	#endregion
	
	#region Controls
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
		#region Cambiar a todas las estadisticas a este valor
		if (_KEY == all) 
		{
			var i=0; repeat(array_length(keys) ) {
				set(keys[i], _VALUE, _TYPE);
				i = i + 1;
			}
		} 
		#endregion
		
		#region Cambiar solo 1
		else 
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
					actual = clamp(_percent, limitMin, control);
					break;
				}
			
				return (actual);
			}
		}
		#endregion
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
		
		// Obtener cuanto se modifico el valor
		var _rest = _stat.control - _stat.actual;
        return (_rest);
    }


	/// @desc actualiza el valor del control
	static updateControl   = function(_KEY)
	{
		if (!weak_ref_alive(from) ) exit;
		var _stat	 = get(_KEY);
		var _control = from.ref.getControl().get(_KEY);
		var _real = _control.values[0], _percent = _control.values[1];
		
		if (!is_undefined(_stat) )
		{
			with (_stat)
			{
				var _sumR = _real;
				var _sumP = (equipment * _percent) / 100;
				
				// Actualizar el valor del control
				control = equipment + _sumR + _sumP;

				// Mensajes
				__mall_trace("Stat Control Sum: " + string(_KEY) + " [" + string(_sumR) + "] - [" + string(_sumP)+"%]" );
				__mall_trace("Stat Control Fin: " + string(_KEY) + " " + string(control) );
			}
		}
		return self;
	}


	/// @desc actualiza el valor del equipment
	static updateEquipment = function(_KEY)
	{
		// Feather ignore all
		var _stat = get(_KEY);
		var _keys = mall_get_equipment_keys();
		var _sum = 0;
		if (!weak_ref_alive(from) ) exit;
		var _entity = from.ref;
		// Ejecutar evento antes de equipar
		_stat.eventEquipStart(_entity, _stat);
		
		var _equipment = _entity.getEquipment();
		for (var i=0, n=array_length(_keys); i < n; i = i + 1) {
			var _key = _keys[i];
			// Obtener equipos
			var _equip = _equipment.get(_key);
			// Si desequipa usar el anterior
			if (_equip.desequip) continue;
			
			var _item = _equip.equipped;
			var _value, _type;
			
			if (is_undefined(_item) ) continue;
			
			// Obtener valor de la estadisticas
			var _t = _item.stats[$ _KEY];
						
			if (!is_undefined(_t) ) {
				// Obtener valores
				_value = _t[0];
				_type  = _t[1];
			
				switch (_type) {
					case MALL_NUMTYPE.REAL:		_sum += _value; break;
					case MALL_NUMTYPE.PERCENT:	_sum += (_stat.peak * _value / 100); break;
				}
			}
		}
		
		// Mensajes
		__mall_trace("Stat Equipment Sum: " + string(_KEY) + " " + string(_sum) );
		__mall_trace("Stat Equipment Fin: " + string(_KEY) + " " + string(_stat.equipment) );
		
		// Actualizar valor
		_stat.equipment = _stat.peak + _sum;
		if (_stat.equipment < _stat.limitMin) {_stat.equipment = _stat.limitMin; }

		// Actualizar el control
		updateControl(_KEY);
		
		// Evento que se ejecuta al final de equipar un objeto
		_stat.eventEquipFinish(_entity, _stat);
		
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


	/// @param {Bool}	[set_or_add=false]	Sumar o establecer el nivel  (false add)
    /// @param {Real}	[add_level=0]		Sumar/restar el nivel actual (0)
    /// @param {Bool}	[force_level=false]	Fuerza a subir de nivel		 (false)
    static eventLevel = function(_SET=false, _LEVEL=0, _FORCE=false) 
	{
		var _size = array_length(keys);
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
		level = (!_SET) ? level + _LEVEL : _LEVEL;
		
		// Ejecutar funcion al ejecutar
		eventLevelStart();
		
		#region Ciclar por cada stat
		var i=0; repeat(array_length(keys) )
		{
			// Feather ignore all
			var _key = keys[i];
			var stat = get(_key);
			
			var _localCheck = undefined;
			var _localLevel = 1;
			if (stat.single)
			{
				stat.level  = (!_SET) ? stat.level + _LEVEL : _LEVEL;
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
				
				// equipment = peak + items
				stat.equipment = stat.peak + _equipment;
				
				// control = peak + equipment
				stat.control   = stat.peak + _equipment + _control;
				
				// el primero deja peak, equipment y control igual
				var _iter = stat .iterator;
				var _work = _iter.iterate();
				if (_work == 2)
				{
					stat.actual = (_iter.type) ? 
						stat.control :
						stat.limitMin;
				}
				
				if (!initialize) 
				{
					stat.lastPeak = stat.event(self, stat, max(1, _localLevel - 1) );
					
					if (_iter.active)
					{
						stat.actual = (_iter.type) ?
							stat.control  :
							stat.limitMin ;
					}
					else
					{
						// Dejar en el maximo solo en el inicio
						stat.actual		= stat.control;
						stat.lastActual = stat.control;
					}
				}
				
				// Mostrar los valores en el debugger
				__mall_trace("Event Level Set " + _key + ": [" + string(stat.control ) + "] ");
				
				// Poner valores para regresar
				_return[$ _key] = stat.send(); 
			}
			
			i = i+1;
        }
        
		#endregion
		
        // Ejecutar funcion al terminar de subir de nivel
        eventLevelFinish();
        initialize = true; // Se cumplio la primera subida de nivel
        
        return (_return );
    }
    
	#endregion
	
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
	
	
	/// @param {Real}	compare
	static isAboveLevel = function(_value)
	{
		return (level > _value);
	}


	/// @param {Real}	compare
	static isBelowLevel = function(_value)
	{
		return (level < _value);
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
    }


	/// @desc Guarda los datos de estadistica en json
	static save = function() 
	{
		var _this = self;
		var _tosave = {level: _this.level, flags: _this.flags};
		var i=0; repeat(array_length(keys) ) {
			var _key  = keys[i];
			var _stat = get(_key);
			// Guardar
			_tosave[$ _key] = _stat.save();
			
			i = i + 1;
		}
		
		return (_tosave );
	}
	
	
	/// @desc Carga desde un struct datos
	static load = function(_toload) 
	{
		level = _toload.level;
		flags = _toload.flags;
		var i=0; repeat(array_length(keys) ) {
			var _key  = keys[i];
			var _stat = _toload[$ _key];
			get(_key).load(_stat);
		}
	}
	
	#endregion
	
    #endregion
}