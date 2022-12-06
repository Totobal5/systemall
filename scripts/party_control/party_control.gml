/// @param {Struct.PartyEntity}	partyEntity
function PartyControl(_entity=other) : Mall() constructor 
{
	// Crear referencia a la entidad
	from = weak_ref_create(_entity);
	keys = [];

	// Crear atomos
	array_foreach(mall_get_state_keys(), function(v) {
		var _component = mall_get_state(v);
		variable_struct_set(self, v, new createAtom(_component) );
		array_push(keys, v);
		
		if (MALL_PARTY_TRACE) {show_debug_message("MallRPG Party (prControl): {0} creado", v); }	
	});
	array_foreach(mall_get_stat_keys (), function(v) {
		var _component = mall_get_stat(v);
		variable_struct_set(self, v, new createAtom(_component) );
		array_push(keys, v);
		
		if (MALL_PARTY_TRACE) {show_debug_message("MallRPG Party (prControl): {0} creado", v); }
	});
	
    #region METHODS
	
	static createAtom = function(_control) constructor 
	{
		/// @ignore
		is = "PartyControl$$createAtom";
		
		// Configuracion
		key  = _control.key
		init = _control.init;   // Valor al que reinicia la estadistica/estado
		type = _control.type;   // Tipo de numero que utiliza normalmente

		same     = _control.same;        // Si acepta el mismo control varias veces
		controls = _control.controls;    // -1 se pueden agregar elementos infinitos
		
		// Valores que varian en el tiempo [real, percentual] son actualizados por los effectos.
		values  = array_create(2, 0);
	
		// Contenidos
		content = array_create(0);
	
		// Si algo evita que esta en el valor de bool
		isAffected = false;
	
		#region METHODS
		/// @return {Array<Struct.DarkEffect>}
		static getContent = function()
		{
			return content;
		}
	
		static find = function(_id)
		{
			var i=0; repeat(array_length(content) )
			{
				var _effect = content[i];
				// Si es el mismo tipo entonces salir
				if (_effect.id == _id) return true;
				i = i+1;
			}
			
			return false;
		}
		
		/// @param {Real} value
		/// @param {Enum.MALL_NUMTYPE} number_type
		static set = function(_VALUE, _TYPE)
		{
			if (_TYPE == undefined) _TYPE = type;
			values[_TYPE] = _VALUE;
		}
	
	
		/// @param {Real} value
		/// @param {Enum.MALL_NUMTYPE} number_type
		static add = function(_VALUE, _TYPE)
		{
			if (_TYPE == undefined) _TYPE = type;
			values[_TYPE] += _VALUE;
		}
	
	
		/// @desc Como guarda este componente
		static save = function()
		{
			var _this = self;
			var _save  = {};
			var _array = array_create(0);
			with (_save) {
				version = MALL_VERSION;
				is      = _this.is    ;
				
				values  = _this.value;
				content = _array     ;
				
				return self;
			}
			
			var i=0; repeat(array_length(content) ) {
				var _effect = content[i];
				array_push(_array, _effect.save() );
				i = i + 1;
			}
			
			return (_save);
		}
		
		/// @desc Como carga este componente
		/// @param {struct} loadStruct
		static load = function(_l)
		{
			if (_l.is != is) exit;
			values = _l.values;
			var i=0; repeat(array_length(_l.content) ) {
				var _e = _l.content[i];
				var _n = new DarkEffect(_l.key, 0, 0, 0, 0, 0);
				_n.commandKey = _e.commandKey;
				_n.value = _e.value;
				_n.turnStart = _e.turnStart;
				_n.turnEnd   = _e.turnEnd  ;
				_n.remove    = _e.remove   ;
				// Cargar iteradores
				_n.iteratorStart.load(_e.iteratorStart);
				_n.iteratorEnd.load(_e.iteratorEnd)    ;
				
				// Agregar efecto recreado
				array_push(content, _n);
				
				i = i + 1;
			}
		}
		
		#endregion
	}
	
		#region BASIC
	/// @param {String} controlKey
	/// @return {Bool}
	static exists = function(_key) 
	{
        return (variable_struct_exists(self, _key) );
    }

	/// @desc	Establece un nuevo valor en "values" con el tipo de numero default o diferente
	/// @param	{String}           controlKey
	/// @param	{Array<Real>,Real} value
	static set = function(_key, _value, _type) 
	{
		var _atom = get(_key);
		if (is_array(_value) ) {
			_atom.values[0] = _value[0];
			_atom.values[1] = _value[1];
		} else {
			_atom.values[_type] = _value;
		}
		return self;
    }

	/// @param	{String} controlKey
	/// @return {Struct.PartyControl$$createAtom}
	static get = function(_KEY) 
	{
        return (self[$ _KEY] );
    }

	/// @desc Añade un valor al control (suma/resta)
	/// @param	{String}           controlKey
	/// @param	{Array<Real>,Real} value
	static add = function(_key, _value, _type) 
	{
		var _atom = get(_key);
		if (is_array(_value) ) {
			_atom.values[0] += _value[0];
			_atom.values[1] += _value[1];
		} else {
			_atom.values[_type] += _value;
		}
		return self;
    }

	/// @desc Establebe el control a su valor inicial
	/// @param {String} controlKey (all para reiniciar todos)
	static reset = function(_key) 
	{
		#region Reiniciar todos
		if (_key == all) {
			var i=0; repeat(array_length(keys) ) {
				var _k = keys[i];
				reset(_k);
				i = i + 1;
			}
		}
		#endregion
		
		#region Solo 1
		else  {
			var _atom = get(_key);
			_atom.values = array_create(2, 0);
		}
		#endregion
		
		return self;
	}
	
	#endregion
		
		
		#region CONTROL
	/// @desc Indica si el estado/estadistica esta siendo afectado por algo
	/// @param	{String} controlKey
	/// @return {Bool}
	static isAffected = function(_KEY)
	{
		var _atom = get(_KEY);
		return (array_length(_atom.content) > 0);
	}

	/// @desc Agrega un efecto al control que afecta (stat/state/action). Si lo agrega "true" si no "false"
    /// @param {Struct.DarkEffect}	darkEffect
	/// @return {Bool}
    static addEffect = function(_darkEffect)
	{	
		// No es un efecto de dark
		if	(!weak_ref_alive(from) ) ||
			(!is_dark_effect(_darkEffect) ) return false;
		
		var _key     = _darkEffect.getKey(); // Obtener a quien afecta
		var _control = get(_key);
		if (MALL_PARTY_TRACE) {
			if (_control == undefined) show_debug_message(MALL_MSJ_DV+" PartyControl (addEffect): {0} no existe", _key);
		}
		
		var _content     = _control.getContent();
		var _contentSize = array_length(_content);
		
		#region Comprobar limite
		// no infinitos
		if (_control.controls > 0) {
			// Si supero el limites entonces salir
			if (_contentSize > _control.control) {
				return false; 
			}
		}
		#endregion
			
		#region Comprobar si permite el mismo
		if (!_control.same) {
			// Si existe el mismo salir
			if (_control.find(_darkEffect.id) ) {
				return false;
			}
		}
			
		#endregion
		
		// Al pasar todo agregar al contenido
		array_push(_content, _darkEffect);
		// Indicar que esta siendo afectado por algo
		_control.isAffected = true;
		// Aplicar valor inicial dependiendo del tipo
		add(_key, _darkEffect.value, _darkEffect.type);
		
		var _entity = getEntity();
		// Ejecutar evento de inicio
		_darkEffect.exAdded(_entity);

		// Intentar actualizar equipamiento y control
		var _stat = _entity.getStat();
		_stat.updateBySlot   (_key);
		_stat.updateByControl(_key);

        return true;
    }


	/// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos.
    /// @param	{String}    controlKey  stat/state mall key
    /// @param	{Function}  filter      function(darkEffect, i, vars) {return Bool}
	/// @param	{Any}       [vars]      valores para pasar al filtro
	/// @return {Bool}
    static removeEffect = function(_key, _filter, _vars) 
	{
		// Filtro default borra el primero de la lista
		static defaultFilter = function(effect, i, more) {
			if (i==0) return true;
		}
		_filter ??= defaultFilter;
		var _control = get(_key);
		if (_control == _control) return false;
		// Obtener contenido
		var _content = _control.getContent();
		
		#region Filtrar
		var _pass = false;
		var i=0; repeat(array_length(_content) ) {
			var _effect =_content[i];
			if (_filter(_effect, i, _vars) ) {
				_pass = true; break;
			}
			
			i = i + 1;
		}
		// Si no encontro nada salir
		if (!_pass) return false;
		
		#endregion
		
		// Eliminar efecto
		array_delete(_content, i, 1);
		// Si no hay más efectos
		if (array_length(_content) <= 0) _control.isAffected = false;
		
		var _effectKey = _effect.key;
		// Eliminar valor del efecto
		add(_effectKey, -_effect.value, _effect.type);
		
		if (weak_ref_alive(from) ) {
			var _entity = getEntity();
			// Ejecutar evento al remover el efecto
			_effect.exRemove(_entity);
		
			// Actualizar estadisticas de equipamiento y control
			if (mall_exists_stat(_effectKey) ) {
				var _stat = _entity.getStat();
				_stat.updateBySlot   (_effectKey);
				_stat.updateByControl(_effectKey);
			}
		}

		return true;
    }


	/// @desc	Actualiza un control
    /// @param	{String} controlKey all para actualizar a todos
	/// @param	{Real}   turnType   0: Inicio del turno, 1: Final del turno, 2: Ambos
    static update = function(_key, _type=0) 
	{
		var _struct  = {value: [0, 0], result: false};
		
		#region Actualizar solo 1
		if (_key != all) {
			var _control = get(_key);
			// Si no existe
			if (_control == undefined) return _struct;
			var _return  = [0, 0];

			// Obtener
			var _content     = _control.getContent();
			var _contentSize = array_length(_content);
		
			// Si no hay contenidos salir
			if (_contentSize <= 0) {
				_control.isAffected = false; // Marcar que no es afectado por nada
				return _struct
			}
			if (!weak_ref_alive(from) ) return _struct;
			
			// Obtener entity
			var _entity = getEntity();
			for (var i=0; i < _contentSize; i = i + 1) {
				var _effect   = _content[i];
				var _turnType = _effect.turnType;
				
				if (_turnType == _type) {
					// Obtener iterador
					var _iterator = _effect.getIterator(_type);
					var _iterate  = _iterator.iterate();  // Iterar y guardar resultado
					var _value   = _effect.value;
					var _numtype = _effect.type ;
					
					// Actualizar
					if (_iterate == 0) {
						// Ejecutar funcion
						_effect.exTurn(_turnType, _entity);
						add(_key, _value, _numtype);
						
						_struct.value[_type] += _value;
					}
					// Termino
					else if (_iterate == -1) {
						// Ejecutar funcion de completado
						_effect.exReady(_entity);
						
						// Restar
						add(_key, -_value, _numtype);
						struct.value[_type] -= _value;
						
						array_delete(_content, i, 1); // Eliminar del array
						_contentSize--;
					}
				}
			}
		
			// Actualizar estadisticas de equipamiento y control
			if (mall_exists_stat(_key) ) {
				var _stats = _entity.getStat();
				_stats.updateBySlot   (_key);
				_stats.updateByControl(_key);
			}
			
			// Indicar que se completo correctamente
			_struct.result = true;
			return _struct;
		}
		
		#endregion
		
		#region Actualizar todos
		else 
		{
			_struct = {};
			var i=0; repeat(array_length(keys) ) {
				var key = keys[i];
				_struct[$ key] = update(key, _type);
				i = i + 1;
			}
		
			return (_struct);
		}
		
		#endregion
	}

	#endregion


		#region Misq
	/// @return {Struct.PartyEntity}
	static getEntity = function() 
	{
		return (from.ref);
	}
	
	/// @return {Struct.PartyStat}
	static getEntityStat = function()
	{
		return (from.ref).getStat();
	}
	
	/// @return {Struct.PartySlot}
	static getEntitySlot = function() 
	{
		return (from.ref).getSlot();
	}		
		
		
	/// @desc Guarda los datos del control
	static save = function() 
	{
		var _this = self;
		var _save = {}
		with (_save) {
			version = MALL_VERSION;
			is      = _this.is    ;
			
			vars = _this.vars;
		}
		var i=0; repeat(array_length(keys) ) {
			var _key = keys[i];
			_save[$ _key] = get(_key).save();
		}
		
		return (_save);
	}

	/// @desc Carga datos de control
	/// @param {struct} loadStruct
	static load = function(_l) 
	{
		if (_l.is != is) exit;
		vars = _l.vars;
		var i=0; repeat(array_length(keys) ) {
			var _key = keys[i];
			var _con = _l[$ _key];
			
			// Cargar del struct
			get(_key).load(_con);
		}
	}

	#endregion

	#endregion
}