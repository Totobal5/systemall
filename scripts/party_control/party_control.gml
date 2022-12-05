/// @param {Struct.PartyEntity}	partyEntity
function PartyControl(_entity=other) : Mall() constructor 
{
	// Crear referencia a la entidad
	from = weak_ref_create(_entity);
	keys = [];
	var _t=function(_key) {
		var _component = mall_get_stat(_key);
		variable_struct_set(self, _key, new __PartyControlAtom(_component) );
		array_push(keys, _key);
		
		if (MALL_PARTY_TRACE) {show_debug_message("MallRPG Party (prControl): {0} creado", _key); }
	}
	array_foreach(mall_get_state_keys(), _t);
	array_foreach(mall_get_stat_keys (), _t);
	
    #region METHODS
	
	static createAtom = function(_control) constructor 
	{
		// Configuracion
		key = _control.key
		init = _control.init;   // Valor al que reinicia la estadistica/estado
		type = _control.type;   // Tipo de numero que utiliza normalmente

		same    = _control.same;        // Si acepta el mismo control varias veces
		control = _control.controls; // -1 se pueden agregar elementos infinitos
		
		// Valores que varian en el tiempo [real, percentual] son actualizados por los effectos.
		values = array_create(2, 0);
	
		// Contenidos
		content = [];
	
		// Si algo evita que esta en el valor de bool
		isAffected = false;
	
		#region METHODS
		/// @return {Array<Struct.DarkEffect>}
		static getContent = function()
		{
			return content;
		}
	
	
		/// @param {Real} value
		/// @param {Enum.MALL_NUMTYPE} number_type
		static set = function(_VALUE, _TYPE)
		{
			_TYPE ??= type;
			values[_TYPE] = _VALUE;
		}
	
	
		/// @param {Real} value
		/// @param {Enum.MALL_NUMTYPE} number_type
		static add = function(_VALUE, _TYPE)
		{
			_TYPE ??= type;
			values[_TYPE] += _VALUE;
		}
	
	
		static save = function()
		{
			var _this = self;
			with ({}) {
				values  = _this.value;
				content = array_map(_this.content, function(v) {
					return (v.save() );
				});
				
				return self;
			}
		}
		
		
		static load = function(_l)
		{
				
		}
		
		#endregion
	}
	
		#region BASIC
	/// @param {String} control_key
	/// @return {Bool}
    static exists = function(_key) 
	{
        return (variable_struct_exists(self, _key) );
    }

	
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
    /// @param {String} control_key (all para reiniciar todos)
    static reset = function(_KEY) 
	{
		#region Reiniciar todos
		if (_KEY == all) 
		{
			var i=0; repeat(array_length(keys) ) {
				var _key = keys[i];
				reset(_key);
				i = i + 1;
			}
		}
		#endregion
		
		#region Solo 1
		else 
		{
			var _atom = get(_KEY);
			_atom.values = array_create(2, 0);
		}
		#endregion
		
		return self;
	}
	
	#endregion
		
		
		#region CONTROL
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
		if	(!weak_ref_alive(from) ) ||
			(!is_dark_effect(_DARK_EFFECT) ) return false;
		
		var _key = _DARK_EFFECT.getKey();	// Obtener a quien afecta
		var _control = get(_key);
		// Evitar errores
		if (is_undefined(_control) ) __mall_error("Party Control: Este control no existe");
		var _content = _control.getContent();
		
		#region Comprobar limite
		// no infinitos
		if (_control.control > 0)
		{
			// Si supero el limites entonces salir
			if (array_length(_content) > _control.control) {return false; }
		}			
		#endregion
			
		#region Comprobar si permite el mismo
		if (!_control.same)
		{
			var i=0; repeat(array_length(_content) )
			{
				var _effect = _content[i];
				// Si es el mismo tipo entonces salir
				if (_effect.id == _DARK_EFFECT.id) return false;
				i = i+1;
			}
		}
			
		#endregion
		
		// Al pasar todo agregar al contenido
		array_push(_content, _DARK_EFFECT);
		_control.isAffected = true; // Indicar que esta siendo afectado por algo
		
		// Aplicar valor inicial
		add(_key, _DARK_EFFECT.value);
		_DARK_EFFECT.eventStart(getFrom() );	// Ejecutar evento de inicio

		// Intentar actualizar equipamiento y control
		var _stats = from.ref.getStats();
		_stats.updateEquipment(_key);
		_stats.updateControl  (_key);

        return true;
    }


	/// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos.
    /// @param	{String}	control_key		stat/state mall key
    /// @param	{Function}	filter			function(DARK_EFFECT, I, ARGUMENTS) {return Bool}
	/// @param	{Any}		[flags]			valores para pasar al filtro
	/// @return {Bool}
    static removeEffect = function(_KEY, _FILTER, _FLAGS) 
	{
		// Filtro default borra el primero de la lista
		static dfil = function(effect, i, more) {
			if (i==0) return true;
		}
		_FILTER ??= dfil;
		
        var _control = get(_KEY);
		if (is_undefined(_control) ) return false;
		
		var _content = _control.getContent();
		// Si no hay contenido salir
		if (array_length(_content) <= 0) return false;
		
		#region Filtrar
		var i=0, _pass=false; repeat(array_length(_content) )
		{
			var _t=_content[i];
			if (_FILTER(_t, i, _FLAGS) ) {_pass = true; break;}
			
			i = i + 1;
		}
		// Si no encontro nada salir
		if (!_pass) return false;
		
		#endregion
		
		// Eliminar efecto
		array_delete(_content, i, 1);
		sub(_t.key, _t.value);
		_t.eventRemove();	// Ejecutar evento al remover el efecto
		
		// Actualizar estadisticas de equipamiento y control
		if (weak_ref_alive(from) ) {
			var _stats = from.ref.getStats();
			_stats.updateEquipment(_KEY);
			_stats.updateControl  (_KEY);
		}
		
		return true;
    }


	/// @desc	Actualiza un control
    /// @param	{String} control_key (all para todos)
	/// @param	{Real} turn_type 0: Inicio del turno, 1: Final del turno, 2: Ambos
    static update = function(_KEY, _TYPE=0) 
	{
		#region Actualizar solo 1
		if (_KEY != all) 
		{
			var _struct  = {value: [0, 0], work: false};
	        var _return  = [0, 0];
			var _control = get(_KEY);
			// No existe salir
			if (is_undefined(_control) ) {return _struct; }
		
			// Obtener
			var _content = _control.getContent();
			var n  = array_length(_content);
		
			// Si no hay contenidos salir
			if (n <= 0) return _struct;
		
			var _entity = entity.ref;
			for (var i=0; i < n; i = i+1)
			{
				var dark = _content[i];
				var dval =  dark.value;
				// Tipo de turno 2 no se considera, 
				// salta si no es el mismo tipo que se esta actualizando
				if ((dark.turnType != 2) && (dark.turnType != _TYPE) ) continue;
			
				var _iter  = getIterator(_TYPE); // Obtener iterador
				var _event = getEvent(_TYPE);  // Obtener evento a usar 
				var _update = _iter.iterate(); // Iterar y guardar resultado
			
				#region Actualizar
				if (_update == 0)
				{
					_event(_entity); // evento para actualizar
					add(_KEY, dval);
				
					// Actualizar devuelta
					_return[0] += dval[0];
					_return[1] += dval[1];
				}
				#endregion
			
				#region Terminar iteraciones
				else if (_update == -1)
				{
					dark.eventFinish(_entity);	// Evento al terminar
					sub(_KEY, dval);
					array_delete(_content, i, 1); // eliminar de los contenidos
					n = n - 1;
				}
			
				#endregion
			}
		
			// Actualizar estadisticas de equipamiento y control
			if (weak_ref_alive(from) ) {
				var _stats = from.ref.getStats();
				_stats.updateEquipment(_KEY);
				_stats.updateControl  (_KEY);
			}
		
			return {value: _return, work: true};
		}
		
		#endregion
		
		#region Actualizar todos
		else 
		{
			var i=0, val={}; repeat(array_length(keys) ) 
			{
				var key = keys[i];
				val[$ key] = update(key, _TYPE);
				i = i + 1;
			}
		
			return (val);
		}
		
		#endregion
	}

	#endregion


		#region Misq
	/// @desc Guarda los datos del control en json
	static save = function() 
	{
		var _this = self;
		var _tosave = {flags: _this.flags};
		var i=0; repeat(array_length(keys) ) {
			var _key = keys[i];
			_tosave[$ _key] = get(_key).save();
			i = i + 1;
		}
		
		return (_tosave );
	}


	static load = function() 
	{
		
		
	}

	#endregion

	#endregion
}