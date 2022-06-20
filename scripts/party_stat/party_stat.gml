/// @param {Real}	[start_level]
/// @return {Struct.PartyStats}
function PartyStats(_level=1) : MallComponent("") constructor 
{
	#region PRIVATE
	__key	= "";	// Referencia al grupo que pertenece la entity
	__index = -1;	// Referencia a la posicion en el grupo que tiene la entity
    __start = false;

	// Condiciones y callbacks
	__condition = function() {};
    __startCallback = function() {};	// Al iniciar  de subir de nivel
    __endCallback   = function() {};	// Al terminar de subir de nivel

	#endregion
	
	level = _level;	// Nivel global

	#endregion
	
    #region METHODS
	/// @ignore
	/// @desc Crear cada estadistica
    static initialize = function() 
	{
		mall_stat_foreach(__key, method(,function(_mall, _key) {
			var _statComponent = new __PartyStatsAtom(_key, _mall);
			variable_struct_set(self, _key, _statComponent);
			
			if (MALL_PARTY_SHOW_MESSAGE) print("Mall Party: %s Creado!", _key);
		}) );
	}

	/// @param {String} stat_key
	/// @returns {Struct.__PartyStatsAtom}
	static get = function(_key) {
		return (self[$ _key] );
	}
	
	/// @param {String} stat_key
	/// @desc Ejecuta el displayMethod del stat.
	static display = function(_key)
	{
		return (get(_key).__return() );	
	}

	/// @ignore
	/// @param {String}	stat_key
	/// @param {Real}	value
	/// @param {Bool}	[to_actual]
	/// @desc Establece el valor maximo de la estadistica a este nivel con limite el mayor y menor valor de la configuracion. (¡Solo usar cuando se sube de nivel!)
    /// @return {Struct.PartyStats}
	static __set  = function(_key, _value, _to=false) 
	{
		// Que no salga de los limites
		var _stat = get(_key);
		with (_stat)
		{
			var _control   = valueControl   - valueEquipment;	// Obtener el resto del control
			var _equipment = valueEquipment - valueMax;		// Obtener el resto del equipo
		
			// Cambiar valor maximo de nivel
			valueMax = clamp(_value, limit[0], limit[1] );
			
			// Restaurar
			valueEquipment = valueMax + _equipment;
			valueControl   = valueEquipment + _control;
			
			if (_to) valueActual = valueControl;
		}
		
		return self;
    }
    
	/// @param	{String}	stat_key
	/// @param	{Real}		value
	/// @desc	Establece el valor actual de una estadistica teniendo como limit "valueControl" y "valueMin"
    /// @return {Struct.PartyStats}
	static set = function(_key, _value) 
	{
		var _stat = get(_key);
        with (_stat) 
		{
			valueLast   = valueActual;
			valueActual = clamp(_value, valueMin, valueControl);	
		}
		
        return self;
    }

	/// @param {String}	stat_key	Llave de estadistica
	/// @param {Real}	value		Valor para sumar/restar. Puede ser numtype
	/// @param {Real}	number_type	Tipo de numero
	/// @param {Real}	[use_value]	Que "value" usar 0: actual, 1:Last, 2: Equipment, 3: Control. Solo porcentajes!
	/// @desc	Suma/Resta "valueActual" de una estadistica teniendo como limite "valueControl" y "valueMin". Devuelve el valor que se añadio
	/// @return {Real}
    static add = function(_key, _value, _type=NUMTYPES.REAL, _use_value=0) 
	{
        var _stat = get(_key), _add = 0;
		
		// Si existe la estadistica
        if (!is_undefined(_stat) ) {
			#region Numtype
			if (is_array(_value) ) {
				_type   = numtype_type (_value);
				_value  = numtype_value(_value);
			}
			#endregion
			
			// Depende del number type
            switch (_type) {
                case NUMTYPE.PERCENT:	
					#region Porcentaje
					var _use = 0;
					#region Valor a usar
					switch (_use_value)
					{
						case 0: _use = _stat.valueActual;		break;
						case 1: _use = _stat.valueLast;		break;
						case 2: _use = _stat.valueEquipment;	break;
						case 3: _use = _stat.valueControl;		break;
					}
					
					#endregion

					_add += (_use * _value);	
					#endregion
					break;
					
				default:	_add += _value;	break;
            }
            
            set(_key, (_stat.valueActual + _add) );
        }
        
        return (_add);
    }

    /// @param {String}	stat_key	Llave de estadistica
    /// @param {Real}	base_value	Respetar numtype global!!
	/// @return {Struct.PartyStats}
    static setBase = function(_key, _base) {
		if (argument_count > 2) 
		{
			var i=0; repeat( (argument_count - 2) div 2) 
			{
				setBase(argument[i++], argument[i++] );	
			}
		}
		else 
		{
			get(_key).base = _base;
		}

        return self;
    }
    
	/// @param {String}		stat_key
    /// @param {Function}	condition
    /// @desc permite establecer la condicion para subir de nivel global o individual
	/// @return {Struct.PartyStats}
    static setCondition = function(_key, _condition) 
	{
        // Comprobamos individual
		var _stat = get(_key);
		if (_stat.single) 
		{
			_stat.condition = method(_stat, _condition);
		}
		else 
		{
			__condition = method(undefined, _condition);	
		}

        return self;
    }
    
    /// @param {Function}	start_callback
    /// @param {Function}	end_callback
	/// @return {Struct.PartyStats}
    static setLevelCallback = function(_start, _end) 
	{
        __startCallback = method(undefined, _start);
        __endCallback   = method(undefined,   _end);
        
        return self;
    }
    
    /// @param {Real}	new_level	Nuevo nivel
    /// @param {String} [stat_key]	Solo si es individual
	/// @return {Struct.PartyStats}
    static setLevel = function(_lvl, _key) 
	{
		var _stat = get(_key);
		if (_stat.single) 
		{
			_stat.level = _lvl;	
		}
		else 
		{
			level = _lvl;
		}
		
		// Subir de nivel
		levelUp(0, true);
		
        return self;
    }
    
    /// @param {Real} [add_level]	Sumar/restar el nivel actual
    /// @param {Bool} [force_level]	Fuerza a subir de nivel
    static levelUp = function(_operate=0, _force=false) {
        var _keys = mall_get_stats();
        var _statGroup = mall_get_group(__key);  // Obtener estadisticas     
        var _return = [];
		var _globalCheck = undefined;
		
		level += _operate;
			
        // Ejecutar funcion al ejecutar
        __startCallback();
        
        // Ciclar por las estadisticas
		for (var i=0, _len=array_length(_keys); i < _len; i++)
		{
			var _key = _keys[i];							// Obtener llave
            var _statMaster = _statGroup.getStat(_key);	// Obtener configuracion del grupo  
            
            // Si no existe evitar
            if (is_undefined(_statMaster) ) continue;
            
			// Obtener struct
            var _stat = get(_key);
            
            var _useLevel = 1;
			var _localCheck = false;
            var _toMax = false;
            var _toMin = false;
            var _toAdd = 0;
			
            #region Comprobar si sube de nivel solo o no
            if (_stat.single) 
			{
                _stat.level += _operate;  // Actualizar nivel individual
                _useLevel = _stat.level;
                
                _localCheck = _stat.condition();
            } else 
			{
                _useLevel = level;
				// Solo una vez ya que EXP o otra estadistica puede pasar a 0 y cagar todos los demas niveles a lo estupido desgraciado
				_globalCheck ??= __condition();
            }
            
            #endregion
            
            // Agregar valor
            var _rest = (_stat.valueEquipment - _stat.valueMax);
            // Si se cumplen las condiciones para subir de nivel
            if ((_localCheck || (_globalCheck && _localCheck==undefined) )  || _force) 
			{
                // Evitar errores al no establecer base
				_toAdd = _statMaster.execute(_useLevel, _stat, self);
				_toMax = _stat.toMax.work();
				_toMin = _stat.toMin.work();
  
                if (_toMax  && !_toMin) _stat.valueActual = _toAdd + _rest;   // Poner en el valor final
                if (!_toMax &&  _toMin) _stat.valueActual = _stat.valueMin;
				
				// Primer subida de nivel
				if (!__start) {
					if (_toMin) {
						_stat.valueMaxLast = _statMaster.execute(max(1, _useLevel - 1), _stat, self);	
					}
					else {
						_stat.valueMaxLast = _stat.limit[0];	
					}
				}
				else _stat.valueMaxLast = _stat.valueMax;	
					
                // Primera subida de nivel
                var _check = (!_toMax && !_toMin);
                
                // Cambiar upper, final y actual
                __set(_key, _toAdd, (_check && !__start) );
                
                // Mostrar los valores en el debugger
                if (MALL_PARTY_SHOW_MESSAGE) show_debug_message(_key + ": " + string(_toAdd) );
                
                // Poner valores para regresar
                array_push(_return, _stat.send() ); 
            }
        }
        
        // Ejecutar funcion al terminar de subir de nivel
        __endCallback();
        
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
	
	/// @param {String}	group_key
	/// @param {String}	index
	static setKey = function(_key, _index)
	{
		__key	= _key;
		__index = _index;
		return self;
	}

    /// @desc Para debug
    /// @returns {string}
    static toString = function() {
        /// @return {String}
		static p = function(_value, _type) {
            var _in = ( (_type == NUMTYPES.PERCENT) ? 
				string(_value) + "%" : 
				string(_value)
            );
			
            return (_in + "\n");
        }

        var _keys  = mall_get_stats();  
		var _print = "";
        var i=0; repeat(array_length(_keys) ) 
		{
            var _key  = _keys[i++];
            var _stat = get(_key); 
			var _type = numtype_type(_stat.base);
            
            // Nombre
            _print += _key + "\n";
            
			#region Obtener numtype
            if (_type == NUMTYPES.REAL) 
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
  
	/// @desc Propio de cada PartyStat, crea una referencia rapida para conectarse a su entity
	/// @return {Struct.PartyEntity}
	getReference = function()
	{
		static ref = undefined;
		static lastkey   = __key;
		static lastindex = __index;
		
		if (ref == undefined)	
		{
			ref = party_get(__key, __index);	
		}
		else
		{
			// Si varian la llave y el indice
			if (lastkey != __key && lastindex != __index)
			{
				ref = party_get(__key, __index);	
			}
		}
		
		return (ref);
	}
		
    #endregion
    
	initialize();
}