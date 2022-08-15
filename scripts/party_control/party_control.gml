/// @param {Struct.PartyEntity}	party_entity
function PartyControl(_ENTITY) : __PartyComponent(_ENTITY) constructor 
{
	with (_ENTITY) control = other;
	stats	  = _ENTITY.getStats();
	equipment = _ENTITY.getEquipment();
	
    #region METHODS
	/// @ignore
	/// @desc Iniciar el control
    static initialize = function() 
	{
		if (__initialize) exit;
		var _foreach =  method(,function(_KEY, _MALL) {
			variable_struct_set(self, _KEY, new __PartyControlAtom(_KEY, _MALL) );
			array_push(__keys, _KEY);
			
			if (MALL_PARTY_SHOW_MESSAGE) __mall_trace("State Control " + string(_KEY) + " creado");
		});
		mall_stat_foreach (_foreach);
		mall_state_foreach(_foreach);
    }

    #region Utils
    /// @param	{String} control_key
	/// @return {Struct.__PartyControlAtom}
    static get = function(_KEY) 
	{
        return (self[$ _KEY] );
    }

    /// @desc	Establece un nuevo valor en "values" con el tipo de numero default o diferente
    /// @param	{String} control_key
    /// @param	{Array<Real>} value
    static set = function(_KEY, _VALUE) 
	{
        var _atom = get(_KEY);
		_atom.values[0] = _VALUE[0];
		_atom.values[1] = _VALUE[1];
		return self;
    }

	/// @desc Añade un valor al control (suma/resta)
    /// @param	{String} control_key
    /// @param	{Array<Real>} value
    static add = function(_KEY, _VALUE) 
	{
        var _atom = get(_KEY);
		_atom.values[0] += _VALUE[0];
		_atom.values[1] += _VALUE[1];
        return self;
    }
	
	/// @desc Añade un valor al control (suma/resta)
	/// @param	{String} control_key
	/// @param	{Array<Real>} value
	static sub = function(_KEY, _VALUE)
	{
		var _atom = get(_KEY);
		_atom.values[0] -= _VALUE[0];
		_atom.values[1] -= _VALUE[1];
        return self;
	}

	/// @desc Establebe el control a su valor inicial
    /// @param {String} control_key
    static reset = function(_KEY) 
	{
        var _atom = get(_KEY);
        _atom.values = array_create(2, 0);

        return self;
    }
	
	/// @desc Devuelve todos los controles al valor inicial
	static resetAll = function()
	{
		var i=0; repeat(array_length(__keys) ) 
		{
			var _key = __keys[i];
			reset(_key);
			i = i+1;
		}
		
		return self;
	}
	
	#endregion

	/// @desc Indica si el estado/estadistica esta siendo afectado por algo
	/// @param	{String} control_key
	/// @return {Bool}
	static isAffected = function(_KEY)
	{
		var _atom = get(_KEY);
		return (array_length(_atom.content) > 0);
	}

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
			var _content = _control.content;
			
			#region Comprobar limite
			if (_control.control > 0)	// no infinitos
			{
				// Si supero el limites entonces salir
				if (array_length(_content) > _control.control) return false;
			}			
			#endregion
			
			#region Comprobar si permite el mismo
			if (!_control.same)
			{
				var i=0; repeat(array_length(_content) )
				{
					var _effect = _content[i];
					// Si es el mismo tipo entonces salir
					if (_effect.__id == _DARK_EFFECT.__id) return false;
					i = i+1;
				}
			}
			
			#endregion
			
			array_push(_content, _DARK_EFFECT);
			
			// Indicar que esta siendo afectado por algo
			if (array_length(_content) > 0) _control.isAffected = true;
			
			// Aplicar valor inicial
			add(_key, _DARK_EFFECT.value);
			_DARK_EFFECT.eventStart(getEntity() );

			stats.updateEquipment(_KEY);
			stats.updateControl  (_KEY);
		}
		
        return true;
    }
    
	/// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos.
    /// @param	{String}	control_key		stat/state mall key
    /// @param	{Function}	filter			function(DARK_EFFECT, I) {return Bool}
	/// @return {Bool}
    static removeEffect = function(_KEY, _FILTER, _FLAGS) 
	{
        var _control = get(_KEY);
		
		if (!is_undefined(_control) )
		{
			var _content = _control.content;
			
			// Si no hay elementos salir
			if (array_length(_content) <= 0) return false;
			
			var i=0; repeat(array_length(_content) )
			{
				var _effect = _content[i];
				if (_FILTER(_effect, i, _FLAGS) ) break;
				i = i+1;
			}
			
			array_delete(_content, i, 1);

			// Feather ignore GM2043
			sub(_effect.key, _effect.value);
			_effect.eventRemove();
			
			stats.updateEquipment(_KEY);
			stats.updateControl  (_KEY);
			return true;
		}
		
		return false;
    }
	
	/// @desc	Actualiza un control
    /// @param	{String} control_key
    static update = function(_KEY, _TYPE=0) 
	{
        var _return  = [0, 0];
		var _control = get(_KEY);
		
		if (!is_undefined(_control) ) return {value: _return, work: false};
		
		// Obtener
		var _content = _control.getContent();
		var _lenght  = array_length(_content);
		
		for (var i=0; i < _lenght; i = i+1)
		{
			/// @type {Struct.DarkEffect}
			var _effect = _content[i];
			
			if (_effect.inTurn!=2)
			{
				if (_effect.inTurn != _TYPE) continue;
			}

			switch (_TYPE)
			{
				#region Turn Start
				case 0:
				var _iter = _effect.iteratorStart;
				var _upd  = _iter.iterate();
				
				if (_upd == 0)
				{
					_effect.eventTurnStart(__entity.ref);
					add(_KEY, _effect.value);
					
					_return[0] += _effect.value[0];
					_return[1] += _effect.value[1];
				}
				else if (_upd == -1)
				{
					_effect.eventFinish(__entity.ref);
					sub(_KEY, _effect.value);
					array_delete(_content, i, 1);
					_lenght--;
				}
				break;
				#endregion
				
				#region Turn Finish
				case 1:
				var _iter = _effect.iteratorStart;
				var _upd  = _iter.iterate();
				
				if (_upd == 0)
				{
					_effect.eventTurnFinish();
					add(_KEY, _effect.value);
					
					_return[0] += _effect.value[0];
					_return[1] += _effect.value[1];
				}
				else if (_upd == -1)
				{
					_effect.eventFinish();
					sub(_KEY, _effect.value);
					array_delete(_content, i, 1);
					_lenght--;
				}				
				
				break;
				#endregion
			}
		}
		stats.updateEquipment(_KEY);
		stats.updateControl  (_KEY);
		
		return {value: _return, work: true};
    }
    
	static updateAll  = function(_TYPE=0) 
	{
		var _values = {};
		var i=0; repeat(array_length(__keys) ) 
		{
			var _key = __keys[i];
			_values[$ _key] = update(_key, _TYPE);
			i = i+1;
		}
		
        return (_values);
    }

	/// @param {String} state_stat_key
	/// @return {Bool}
    static exists = function(_key) 
	{
        return (variable_struct_exists(self, _key) );
    }
	
	static getComponents = function()
	{
		stats	  = __entity.ref.getStats();
		equipment = __entity.ref.getEquipment();
	}
	
	#endregion
	
	initialize();
}