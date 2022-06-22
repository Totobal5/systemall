/// @param {Bool}	[stats_unique]
/// @param {Bool}	[states_unique]
function PartyControl(_stats_unique=false, _states_unique=true) : MallComponent("") constructor 
{
    #region PRIVATE
	__key	= "";	// Referencia al grupo que pertenece la entity
	__index = -1;	// Referencia a la posicion en el grupo que tiene la entity
	
	__allKeys = [];
	__statUnique  = _stats_unique ;  // Si se permiten multiples ben/des a las estadisticas
    __stateUnique = _states_unique;  // Si se permiten más de un mismo estado
	#endregion
	
    #region METHODS
	/// @ignore
	/// @desc Iniciar control
    static initialize = function() 
	{
		var _foreach =  method(undefined, function(_mall, _key, i, _pass) {
			var _initial = _mall.__initial, _atom;
			var _type  = _initial[NUMVALUE.TYPE];
			
			if (_pass.type == 0)
			{
				#region Stat
				// Las estadisticas no utilizan el boleano
				_atom = new __PartyControlAtom(_type, false, _pass.unique, _mall.__limits);
				
				#endregion
			}
			else
			{
				#region State
				// Los estados utilizan el boleano
				var _boolean = _initial[NUMVALUE.VALUE];
				_atom = new __PartyControlAtom(_type, _boolean, _pass.unique,  _mall.__limits);
				#endregion
			}
			
			variable_struct_set(self, _key, _atom);
			array_push(__allKeys, _key);
		});
		
		mall_stat_foreach (__key, _foreach, {type: 0, unique:  __statUnique} );
		mall_state_foreach(__key, _foreach, {type: 1, unique: __stateUnique} );
    }
    
    /// @param	{String}		state_stat_key
    /// @param	{Real}			value
    /// @param	{Enum.NUMTYPES} number_type
    /// @desc Establece un nuevo valor en "values" con el tipo de numero default o diferente
    static set = function(_key, _value, _type) 
	{
        var _control = get(_key);
		_type ??= _control.__type;
        _control.values[_type] = _value; 

		return self;
    }
    
    /// @param	{String} state_stat_key
	/// @return {Struct.__PartyControlAtom}
    static get = function(_key) 
	{
        return (self[$ _key] );
    }
    
	/// @param	{String} state_stat_key
	/// @desc Indica si el estado/estadistica esta siendo afectado por algo
	/// @return {Bool}
	static isAffected = function(_key)
	{
		var _atom = get(_key);
		return (_atom.__isAffected() );
	}
	
    /// @param	{String}		state_stat_key
    /// @param	{Any*}			operate
    /// @param	{Enum.NUMTYPES}	number_type
	/// @desc Añade un valor al control (suma/resta)
    static add = function(_key, _operate, _type) 
	{
        var _control = get(_key);
	
		#region si es numtype
		if (is_array(_operate) )
		{
			_type    = numtype_type (_operate);
			_operate = numtype_value(_operate);
		}
		else _type ??= _control.__type;
		
		#endregion
		
		_control.values[_type] += _operate;

        return self;
    }
    
    /// @param {String} state_stat_key
	/// @desc Establebe el control a su valor inicial
    static reset = function(_key) 
	{
        var _control = get(_key);
        _control.values[0] = 0;
		_control.values[1] = 0;

        return self;
    }
    
	/// @desc Devuelve todos los controles al valor inicial
    static resetAll = function() 
	{
		var i=0; repeat(array_length(__allKeys) ) 
		{
			var _key = __allKeys[i++];
			reset(_key);	
		}

        return self;
    }
    
    /// @param {Struct.DarkEffect}	effect_constructor
    /// @desc Agrega un efecto al control que afecta (stat/state/action). Si lo agrega "true" si no "false"
	/// @return {Bool}
    static addEffect  = function(_effect) 
	{	
		// No es un efecto de dark
		if (!is_dark_effect(_effect) ) return self;
		
		var _key	 = _effect.getKey();
		var _control = get(_key);
		
		// Evitar errores
		if (!is_undefined(_control) )
		{
			var _content = _control.content;	
			if (is_array(_content) )
			{
				#region Guarda varios
				// Que no supere el limite
				if (_control.limit > 0) // limite activo
				{
					if (array_length(_content) > _control.limit) return false;	// hay demasiados
				}				
				
				if (!_control.same)
				{
					// No repetidos
					var i=0; repeat(array_length(_content) )
					{
						var _ineffect = _content[i++];
						if (_ineffect.__id == _effect.__id) return false;	// No se puede agregar
					}
				}
				
				// Agregar al array
				array_push(_content, _effect);
				
				#endregion
			}
			else
			{	
				#region Guarda solo uno
				reset(_key);
				_control.content = _effect;	// Establece el efecto
				#endregion
			}
			
			// Indicar que esta siendo afectado
			_control.affected = true;
			
			// Aplicar valor inicial
			add(_key,  _effect.getInit() );
			updateStat(_key);			
		}
		
        return true;
    }
    
    /// @param	{String}	state_stat_key
    /// @param	{Function}	[filter]		function(dark_effect, i) {return true}
	/// @desc Elimina un efecto, si el control permite varios entonces se debe pasar un filtro. Devuelve "true" si borra "false" si no.
    static removeEffect = function(_key, _function) 
	{
        var _control = get(_key);
		if (is_undefined(_control) ) return false;
		
		var _content = _control.content;
		if (is_array(_content) )
		{
			if (is_undefined(_function) ) throw "Si es array se debe pasar un filtro"
			var i=0; repeat(array_length(_content) )
			{
				var _effect = _content[i];
				if (_function(_effect, i) ) break;	// Se borro
				i++;
			}
			// Borrar del array
			array_delete(_content, i, 1);
			if (array_empty(_content) ) _control.use = false;	// Si ya no hay efectos
		}
		else
		{
			var _effect = _control.content;
			_control.content = undefined;
			_control.use = false;	
		}
		var _value = _effect.get();
		add(_effect.__key, -_value[0], _value[1] );
		updateStat(_key);
		
		return true;
    }
    
    /// @param	{String} state_stat_key
	/// @desc	Devuelve un array con los valores [value, finish?]
	/// @return {Array}
    static update = function(_key) 
	{
        var _return  = [0, 0];
		var _control = get(_key);
		
		if (!is_undefined(_control) ) return [_return, false];
		
		// Obtener
		var _content = _control.content;
		
		if (is_array(_content) )
		{
			#region Varios
			var _len = array_length(_content);
			for (var i=0; i < _len; i++)
			{
				var _effect = _content[i];
				var _turn = _effect.__turns;
				var _work = _turn.work();

				if (_work)
				{
					#region quedan turnos
					_effect.update();
					var _value = _effect.get();
					var _num  = _value[0];
					var _type = _value[1];
				
					add(_key, _num, _type);	// Aumenta el valor del control
					_return[_type] += _num;
					
					#endregion
				}
				else
				{
					#region terminó
					_effect.finish();
					var _value = _effect.get();
					var _num  = _value[0];
					var _type = _value[1];					
					// Disminuye el valor del control
					add(_key, -_num, _type);	
					
					array_delete(_content, i, 1);
					_len--;
					
					#endregion
				}
			}
			
			// Si ya no hay poner en true
			_work = (array_length(_content) <= 0);
			
			#endregion
		}
		else
		{
			#region Solo 1
			var _turn = _content.__turns;
			var _work = _turn.work();
			
			if (_work)
			{
				#region Quedan turnos
				_content.update();
				var _value = _content.get();
				var _num  = _value[0];
				var _type = _value[1];
				
				add(_key, _num, _type);
				_return[_type] += _num;
				
				#endregion
			}
			else
			{
				#region Terminó
				_save = _control.values[_control.type];
				_content.finish();
						
				// Reiniciar valores
				reset(_key);
				#endregion
			}
			
			#endregion
		}
		
		// Actualizar la estadistica
		updateStat(_key);
		
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