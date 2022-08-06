function PartyControl() constructor 
{
    #region PRIVATE
	__entity = weak_ref_create(self);
	
	__keys = [];
	
	#endregion
	
    #region METHODS
	/// @ignore
	/// @desc Iniciar el control
    static initialize = function() 
	{
		var _foreach =  method(undefined, function(_MALL, _KEY, i, _PASS) {
			var _initial = _MALL.__initial, _atom;
			
			_atom = (!_PASS) ? 
				new __PartyControlAtom(false,		_initial[1], _MALL.__modsNumber) :
				new __PartyControlAtom(_initial[0], _initial[1], _MALL.__limits)
			variable_struct_set(self, _KEY, _atom);
			array_push(__keys, _KEY);
		});
		mall_stat_foreach (_foreach, 0);
		mall_state_foreach(_foreach, 1);
    }
	
    /// @param	{String}	control_key
    /// @param	{Real}		value
    /// @param	{Real}		number_type
    /// @desc	Establece un nuevo valor en "values" con el tipo de numero default o diferente
    static set = function(_KEY, _VALUE, _TYPE) 
	{
        var _atom = get(_KEY);
		_TYPE ??= _atom.__defaultType;	// Usar default
        _atom.__values[_TYPE] = _VALUE; 

		return self;
    }

    /// @param	{String}	control_key
    /// @param	{Any*}		operate
    /// @param	{Real}		number_type
	/// @desc Añade un valor al control (suma/resta)
    static add = function(_KEY, _OPER, _TYPE) 
	{
        var _atom = get(_KEY);
		_TYPE ??= _atom.__defaultType;	// Usar default
		_atom.__values[_TYPE] += _OPER;

        return self;
    }
    
    /// @param	{String} control_key
	/// @return {Struct.__PartyControlAtom}
    static get = function(_KEY) 
	{
        return (self[$ _KEY] );
    }

    /// @param {String} control_key
	/// @desc Establebe el control a su valor inicial
    static reset = function(_KEY) 
	{
        var _atom = get(_KEY);
        _atom.__values = array_create(2, 0);

        return self;
    }

	/// @desc Devuelve todos los controles al valor inicial
    static resetAll = function() 
	{
		var i=0; repeat(array_length(__keys) ) 
		{
			var _key = __keys[i];
			reset(_key);	
			
			i += 1;
		}

        return self;
    }

	/// @desc Indica si el estado/estadistica esta siendo afectado por algo
	/// @param	{String} control_key
	/// @return {Bool}
	static isAffected = function(_KEY)
	{
		var _atom = get(_KEY);
		return (array_length(_atom.__content) > 0)
	}
    
	
	#region Efectos
	/// @desc Agrega un efecto al control que afecta (stat/state/action). Si lo agrega "true" si no "false"
    /// @param {Struct.DarkEffect}	dark_effect
	/// @return {Bool}
    static addEffect = function(_DARK_EFFECT) 
	{	
		// No es un efecto de dark
		if (!is_dark_effect(_DARK_EFFECT) ) return false;
		
		var _key = _DARK_EFFECT.getKey();	// Obtener a quien afecta
		var _control = get(_key);
		
		// Evitar errores
		if (!is_undefined(_control) )
		{
			var _content = _control.__content;
			
			#region Comprobar limite
			if (_control.__limit > 0)	// no infinitos
			{
				// Si supero el limites entonces salir
				if (array_length(_content) > _control.__limit) return false;
			}			
			#endregion
			
			#region Comprobar si permite el mismo
			if (_control.__same)
			{
				var i=0; repeat(array_length(_content) )
				{
					var _effect = _content[i];
					// Si es el mismo tipo entonces salir
					if (_effect.__id == _DARK_EFFECT.__id) 
					{
						return false;
					}
					
					i += 1;
				}
			}
			
			#endregion
			
			array_push(_content, _DARK_EFFECT);
			
			// Indicar que esta siendo afectado por algo
			if (array_length(_content) > 0)
			{
				_control.__affected = true;
			}
			
			// Aplicar valor inicial
			add(_key, _DARK_EFFECT.__init[0], _DARK_EFFECT.__init[1] );
			var _entity = __entity.ref;
			var _action = _DARK_EFFECT.startEvent(_entity);
			switch (_action)
			{
				case "update control":
					var _stats = _entity.__stats;
				break;
			}
		}
		
        return true;
    }
    
	/// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos.
    /// @param	{String}	control_key		stat/state mall key
    /// @param	{Function}	filter			function(DARK_EFFECT, I) {return Bool}
	/// @return {Bool}
    static removeEffect = function(_KEY, _FILTER) 
	{
        var _control = get(_KEY);
		
		if (!is_undefined(_control) )
		{
			var _content = _control.__content;
			
			// Si no hay elementos salir
			if (array_length(_content) <= 0) return false;
			
			var i=0; repeat(array_length(_content) )
			{
				var _effect = _content[i];
				if (_FILTER(_effect, i) ) break;
				i += 1;
			}
			
			array_delete(_content, i, 1);

			// Feather ignore GM2043
			add(_effect.__key, -_effect.__value[0], _effect.__value[1] );
			updateStat(_key);
			
			return true;
		}
		
		return false;
    }
	
	/// @desc	Actualiza un control
    /// @param	{String} control_key
	/// @return {Array<Any>}
    static update = function(_KEY) 
	{
        var _return  = [0, 0];
		var _control = get(_KEY);
		
		if (!is_undefined(_control) ) return [_return, false];
		
		// Obtener
		var _content = _control.get();
		var _lenght  = array_length(_content);
		
		for (var i=0; i < _lenght; i+=1)
		{
			/// @type {Struct.DarkEffect}
			var _effect = _content[i];
			var _turns  = _effect.__turns;
			
			#region Trabajar turnos
			
			// Quedan turnos
			if (_turns.count < _turns.limit)
			{
				_effect.updateEvent();
				var _value = _effect.__value[0];
				var _type  = _effect.__value[1];
				
				add(_KEY, _value, _type);
				_return[_type] += _value;
				
				_turns.count += 1;
			}
			// No quedan turnos eliminar
			else
			{
				// Permite reiniciar
				if (_turns.reset)
				{
					if (_turns.resetCount < _turns.resetLimit)
					{
						// Ejecutar evento de reinicio de cuenta
						_effect.resetEvent();
						var _value = _effect.__value[0];
						var _type  = _effect.__value[1];
				
						add(_KEY, _value, _type);
						_return[_type] += _value;
						_turns.count = 0;
						_turns.resetCount += 1;
					}
					else
					{
						_turns.reset = false;
					}
				}
				// Eliminar
				else
				{
					_effect.finish();
					var _value = _effect.get();
					var _num  = _value[0];
					var _type = _value[1];
					// Disminuye el valor del control
					add(_KEY, -_num, _type);
					
					array_delete(_content, i, 1);
					_lenght--;
				}
			}
			
			#endregion
		}
		return [_return, _work];
    }
    
	/// @desc Devuelve un struct con los valores {key: [ [value, percent, boolean], [value, percent, boolean] ] }
	/// @return {Struct}
    static updateAll  = function() 
	{
		var _values = {};
		var i=0; repeat(array_length(__allKeys) ) 
		{
			var _key = __allKeys[i];
			_values[$ _key] = update(_key);
		}
		
        return (_values);
    }
    
	/// @desc Actualiza el "valueControl" de una estadistica
	static updateStat = function(_key)
	{
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

	#endregion

	/// @param {String} state_stat_key
	/// @return {Bool}
    static exists = function(_key) 
	{
        return (variable_struct_exists(self, _key) );
    }
	
	/// @param {String}	group_key
	/// @param {Real}	group_index
	static setKey = function(_key, _index)
	{
		__key	= _key;
		__index = _index;
		return self;
	}
 
 	/// @desc Propio de cada PartyControl, crea una referencia rapida para conectarse a su entity
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