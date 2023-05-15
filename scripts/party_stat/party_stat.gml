/// @param {Struct.PartyEntity} partyEntity
/// @param {Real} [level]=1
/// @return {Struct.PartyStat}
function PartyStat(_entity=other, _level=1) : Mall() constructor 
{
	// Crear referencia a la entidad
	from = is_instanceof(_entity, PartyEntity) ? weak_ref_create(_entity) : undefined;
	keys = [];
	array_foreach(mall_get_stat_keys(), function(_key) {
		var _component = mall_get_stat(_key);
		variable_struct_set(self, _key, new createAtom(_component) );
		array_push(keys, _key);
		if (MALL_PARTY_TRACE) show_debug_message("MallRPG Party (prStat): {0} creado", _key);
	});
	
	// Nivel global
	level = _level;
	vars  = {}    ;
	
	/// @desc Condicion global para subir de nivel
	/// @param {Struct.PartyStats} [statEntity]
	/// @return {Bool}
	checkLevel = "";
	
	/// @desc Al subir de nivel
	funLevel   = "";

	#region METHODS
	
	/// @param {struct.MallStat} mallStat
	static createAtom = function(_stat) constructor
	{
		/// @ignore
		is = "createAtom";
	
		key = _stat.key;
		displayKey = _stat.displayKey;
		saveValue  = _stat.saveValue;
		
		// -- Configuracion
		
		vars   = {}; //_stat.vars;   // Que pasar en la formula para subir de nivel
		single = _stat.levelSingle;  // Si sube de nivel individualmente

		funStart = _stat.funStart;  //
		funEnd   = _stat.funEnd  ;  //
		funEquip    = _stat.funEquip;     // Al equipar un objeto (inicio) ejecuta esta funcion
		funDesequip = _stat.funDesequip;  // 
		
		funLevel   = _stat.funLevel  ;
		checkLevel = _stat.checkLevel;
		
		// Copiar iterador
		if (_stat.iterator != undefined) {
			iterator = _stat.iterator.copy();  // Copiar la configuracion del otro iterador
		} else {
			iterator = _stat.iteratorCreate(); // Crear un iterador si no existe
		}
	
		// -- Se ponen los valores inciales
		level = _stat.startLevel; // Nivel de la estadistica si se usa individualmente
		base  = _stat.start;
		type  = _stat.type;
		
		// Valores que posee
		limitMin = _stat.limitMin;	// Valor maximo en que la estadistica puede estar
		limitMax = _stat.limitMax;	// Valor minimo en que la estadistica puede estar
	
		control   = base;	 // El valor final tomando en cuenta el control
		equipment = control; // El valor final tomando en cuenta el equipamiento
	
		peak   = control; // Valor de la estadistica actual maximo respecto al nivel
		actual = control; // El valor actual de la estadistica
	
		lastPeak   = control;    // El ultimo valor maximo
		lastActual = control;    // El anterior valor actual
		
		#region Methods
		/// @desc Devuelve un struct con los valores actuales
		static send = function()
		{
			var _this = self;
			return ({
				key: _this.key,
				control  : _this.control  ,
				equipment: _this.equipment,
				peak     : _this.peak  ,
				actual   : _this.actual,
				
				lastPeak  : _this.lastPeak  ,
				lastActual: _this.lastActual
			});
		}
	
		/// @desc Como guarda este componente
		static save = function() 
		{
			var _this = self;
			return ({
				version: MALL_VERSION,
				is:         _this.is,
				level:      _this.level,
				iterator:   _this.iterator,
				actual:     _this.saveValue ? _this.actual : 0
			});
		}
	
		/// @desc Como carga este componente
		/// @param {struct} loadStruct
		static load = function(_l) 
		{
			if (_l.is != is) exit;
			switch (_l.version) {
				default:
					iterator.load(_l.iterator);
					level = _l.level;
					if (saveValue) actual = _l.actual ?? peak;
				break;
			}

			return self;
		}
		
		/// @desc Ejecuta la funcion para cuando se equipa algo
		/// @param {struct.PartyEntity} partyEntity
		exEquip    = function(_entity)
		{
			static nofn = function(_entity) {};
			var fn = method(self, dark_get_function(funEquip) ?? nofn);
			return (fn(_entity) );
		}
		
		/// @desc Ejecuta la funcion para cuando se desequipa algo
		/// @param {struct.PartyEntity} partyEntity
		exDesequip = function(_entity)
		{
			static nofn = function(_entity) {};
			var fn = method(self, dark_get_function(funDesequip) ?? nofn);
			return (fn(_entity) );
		}
		
		/// @desc Ejecuta funcion de inicio
		/// @param {struct.PartyEntity} partyEntity
		exStart = function(_entity)
		{
			static nofn = function(_entity) {}
			var fn = method(self, dark_get_function(funStart) ?? nofn);
			return (fn(_entity) );
		}
		
		// -- Para el nivel
		/// @param {struct.PartyStat} partyStat
		/// @param {real}             level
		exLevel = function(_partyStat, _level)
		{
			static nofn = function(_partyStat, _level) {return  0;}
			var fn = method(self, dark_get_function(funLevel) ?? nofn);
			return (fn(_partyStat, _level) );
		}
		
		/// @param {struct.PartyEntity} partyEntity
		exCheckLevel = function(_entity)
		{
			static nofn = function(_entity) {return false;}
			var fn = method(self, dark_get_function(checkLevel) ?? nofn);
			return (fn(_entity) );
		}
		
		#endregion
	}
	
	#region Basic
	/// @param {String}             statKey     Llave de estadistica
	/// @param {Real}               baseValue   Valor de base
	/// @param {ENUM.MALL_NUMTYPE}  baseType    Tipo de numero
	/// @return {Struct.PartyStat}
	static setBase = function(_statKey, _baseValue, _baseType) 
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
	
	/// @desc
	/// @param {String} statKey Llave de estadistica
	/// @param {String} varKey  Llave de estadistica
	/// @param {Any*}   value   Flag para colocar en la estadistica
	static setVarAtom = function(_statKey, _varKey, _value)
	{
		var _stat = get(_statKey);
		if (_stat != undefined) {
			_stat.vars[$ _varKey] = _value;
		}
		return self;
	}

	/// @desc
	/// @param {String} statKey Llave de estadistica
	/// @param {String} varKey  Llave de estadistica
	static getVarAtom = function(_statKey, _varKey)
	{
		var _stat = get(_statKey);
		if (_stat != undefined) {
			return (_stat.vars[$ _varKey] );
		}
		return (undefined);
	}
	
	
	/// @desc Permite establecer la condicion para subir de nivel global o individual
    /// @param {string} darkFunction
	/// @param {String} [statKey]
	/// @return {Struct.PartyStat}
    static setCheckLevel = function(_darkFun, _statKey) 
	{
		#region Global
		if (_statKey == undefined) {
			checkLevel = _darkFun;
		}
		#endregion
		
		#region Individual
		else if (is_string(_statKey) )
		{
			var _stat = get(_statKey);
			if (_stat.single) _stat.checkLevel = _darkFun;
		}
	
		#endregion
		
        return self;
    }
    
    /// @param {string} levelStart
    /// @param {string} levelEnd
	/// @return {Struct.PartyStat}
    static setFunLevel = function(_fun) 
	{
        funLevel = _fun;
        return self;
    }
	
	#endregion
	
	#region Controls
	/// @desc Obtiene un PartyStatAtom a partir de la llave
	/// @param {String} statKey
	/// @returns {Struct.PartyStat$$createAtom}
	static get = function(_key) 
	{
		var _atom = variable_struct_get(self, _key);
		return (_atom);
	}

	/// @desc	Establece el valor actual de una estadistica teniendo como limites "limMin" y "control"
	/// @param	{String}            statKey  si es "all" permite cambiar el valor de todos los atomos
	/// @param	{Real}              value    Valor para establecer
    /// @param  {ENUM.MALL_NUMTYPE} numtype  Tipo de numero
	/// @return {Real}
	static set = function(_key, _value, _numtype=MALL_NUMTYPE.REAL) 
	{
		#region Cambiar a todas las estadisticas a este valor
		if (_key == all)  {
			var i=0; repeat(array_length(keys) ) {
				set(keys[i], _value, _numtype);
				i = i + 1;
			}
		} 
		#endregion
		
		#region Cambiar solo 1
		else  {
			var _stat = get(_key);
			if (is_undefined(_stat) ) return 0;
		
			with (_stat) {
				switch (_numtype) {
					case MALL_NUMTYPE.REAL:
						lastActual = actual;
						actual     = clamp(_value, limitMin, control);
					break;
				
					case MALL_NUMTYPE.PERCENT:
						var _percent = (control * _value) / 100;
						lastActual = actual;
						actual     = clamp(_percent, limitMin, control);
					break;
				}
			
				return (actual);
			}
		}
		#endregion
    }

	/// @desc Suma/Resta "valueActual" de una estadistica teniendo como limite "valueControl" y "valueMin". Devuelve el valor que se añadio
	/// @param {String}             statKey     Llave de estadistica
	/// @param {Real}               value       Valor para sumar/restar
	/// @param {ENUM.MALL_NUMTYPE}  numtype     Tipo de numero
	/// @param {Real}               [useValue]  Que "value" usar 0: actual, 1:lastActual, 2: Peak, 3: lastPeak, 4: equipment, 5: control, Solo porcentajes!
	/// @return {Real} Devuelve el valor que se añadio
    static add = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _useValue=0) 
	{
        var _stat = get(_key);
		if (is_undefined(_stat) ) return 0;
		
		var _add = 0;
		// Depende del number type
        switch (_numtype)  {
			#region Real
			case 0: 
				_add += _value; 
				// Sumar
				set(_key, round(_stat.actual + _add) );
			break;
				
			#endregion
				
            #region Porcentaje
			case 1:	
				var _use=0;
				switch (_useValue) {
					case 0: _use = _stat.actual;       break;
					case 1: _use = _stat.lastActual;   break;
					
					case 2: _use = _stat.peak;          break;
					case 3: _use = _stat.lastPeak;      break;
					
					case 4: _use = _stat.equipment;     break;
					case 5: _use = _stat.control;       break;
				}
				// Sacar porcentaje
				_add += (_use * _value) / 100;
				// Sumar
				set(_key, round(_stat.actual + _add) );
			break;
			#endregion
        }
		
		// Obtener cuanto se modifico el valor
		var _rest = _stat.control - _stat.actual;
        return (_rest);
    }


	/// @desc actualiza el valor del control
	/// @param {string} statKey
	static updateByControl  = function(_key)
	{
		// Si no existe la entidad salir
		if (!weak_ref_alive(from) ) exit;
		// Asegurar que exista la estadistica
		if (MALL_ERROR) {
			if (!mall_exists_stat(_key) ) show_error(string("MallRPG PartyStat (updateControl): No existe {0}", _key), true); 
		}
		
		var _stat	 = get(_key);
		var _control = getEntityControl().get(_key); // Obtener PartyControl desde la entidad
		
		var _real    = _control.values[0];
		var _percent = _control.values[1];
		
		with (_stat) {
			var _sumR = _real;                        // Suma real
			var _sumP = (equipment * _percent) / 100; // Suma porcentual
				
			// Actualizar el valor del control
			control = equipment + _sumR + _sumP;

			// Mensajes
			if (MALL_PARTY_TRACE) {
				show_debug_message("MallRPG PartyStat (updateControl): sumar a {0} los [{1}, {2}%]", _sumR, _sumP);
				show_debug_message("MallRPG PartyStat (updateControl): {0} valor final {1}", control);
			}
		}
		
		return self;
	}

	/// @desc actualiza el valor del equipment
	/// @param {string} statKey
	static updateBySlot     = function(_statKey, _desequip=false)
	{
		// Feather ignore all
		if (!weak_ref_alive(from) ) exit;
		var _stat = get(_statKey);
		var _keys = mall_get_slot_keys();
		var _sum  = 0;
		var _entity = getEntity();
		
		// Obtener slots
		var _slot = _entity.getSlot();
		for (var i=0, n=array_length(_keys); i < n; i = i + 1) {
			var _key = _keys[i];
			
			// Obtener equipos
			var _equip = _slot.get(_key);
			
			// Si desequipa usar el anterior
			if (_equip.desequip) continue;
			
			var _item = _equip.equipped;
			// Si no hay nada equipado
			if (is_undefined(_item) ) continue;
			
			// Obtener valor de la estadisticas
			var _t = _item.stats[$ _statKey];
			if (!is_undefined(_t) ) {
				// Obtener valores
			   var _value = _t[0];
			   var _type  = _t[1];
			
				switch (_type) {
					case MALL_NUMTYPE.REAL:		_sum += _value; break;
					case MALL_NUMTYPE.PERCENT:	_sum += (_stat.peak * _value / 100); break;
				}
			}
		}
		
		if (MALL_PARTY_TRACE) {
			show_debug_message("MallRPG Stat (updateBySlot): sumar a {0} los {1}", _sum);
			show_debug_message("MallRPG Stat (updateBySlot): valor final de {0}: {1}", _stat.equipment);
		}
		
		// Actualizar valor
		_stat.equipment = max(_stat.peak + _sum, _stat.limitMin);
		
		// Actualizar el control
		updateByControl(_statKey);
		
		// Evento que se ejecuta al final de
		if (!_desequip) {
			_stat.exEquip   (_entity); // equipar un objeto
		} else {
			_stat.exDesequip(_entity); // desequipar un objeto
		}
		
		return self;
	}


    /// @param {Real}	newLevel    Nuevo nivel
    /// @param {String} [statKey]   Solo si es individual
	/// @return {Struct.PartyStat}
    static setLevel = function(_level, _key) 
	{
		#region Global
		if (_key == undefined) {
			level = _level
		}
		#endregion
		
		#region Individual
		else if (is_string(_key) )
		{
			var _stat = get(_key);
			_stat.level = _level;
		}
		#endregion
			
		// Forzar subida de nivel
		LevelUp(false, 0, true);
		
        return self;
    }

	/// @param {Bool} [setOrAdd]=false  Sumar o establecer el nivel. false: Add
	/// @param {Real} [level]   =0      nivel
	/// @param {Bool} [force]   =false  Fuerza a subir de nivel
    static LevelUp  = function(_set=false, _setLevel=0, _force=false) 
	{
		var _size   = array_length(keys);
		var _entity = getEntity();
		
		// Para feather
		var _return = {
			statKey: {
				key: "",
				
				control   :  0,
				equipment :  0,
				peak      :  0,
				actual    :  0,
				lastPeak  :  0,
				lastActual:  0
			},
		};
		variable_struct_remove(_return, "statKey"); // Eliminar
		
		// Revisar check global
		var _globalCheck = exCheckLevel(_entity) + _force;
		if (!_globalCheck) exit;
		
		// operar level
		level = (!_set) ? level + _setLevel : _setLevel;

		#region Ciclar por cada stat
		var i=0; repeat(array_length(keys) ) {
			// Feather ignore all
			var _key = keys[i];
			var stat = get(_key);
			
			var _check = undefined;  // Solo si es independiente
			var _level = 1;          // Nivel a usar
			if (stat.single) {
				stat.level  = (!_set) ? stat.level + _setLevel : _setLevel;
				_level = stat.level;
				_check = stat.exCheckLevel(_entity);
			}
			else {
				_level = level; // Remplazar por nivel global
				_check =  true;
			}
			
			var _enterGlobal = (_globalCheck && _check != undefined);
			
			
			if (_force || (_check || _enterGlobal) ) {
				var _controlRest = (stat.control   - stat.equipment);
				var _slotRest    = (stat.equipment - stat.peak);
				
				/// partyStat, nivel
				var _sum = stat.exLevel(self, _level);
				
				// Actualizar valores
				stat.peak = clamp(_sum, stat.limitMin, stat.limitMax);
				
				// equipment = peak + items
				stat.equipment = stat.peak + _slotRest;
				
				// control = peak + equipment
				stat.control   = stat.peak + _slotRest + _controlRest;
				
				// el primero deja peak, equipment y control igual
				var _iter =  stat.iterator ;
				var _work = _iter.iterate();
				
				// Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo
				if (_work == 2) {
					stat.actual = (_iter.type) ? 
						stat.control :
						stat.limitMin;
				}
				
				#region Primera llamada
				if (!_iter.firstCall) {
					stat.lastPeak = stat.exLevel(self, max(1, _level - 1) );
					if (_iter.active) {
						// Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo
						stat.actual = (_iter.type) ? 
							stat.control :
							stat.limitMin;
					}
					else {
						stat.actual     = stat.control;
						stat.lastActual = stat.control; 
					}
					_iter.firstCall = true;
				}
				#endregion
				
				// Mostrar los valores en el debugger
				if (MALL_PARTY_TRACE) {
					show_debug_message("MallRPG PartyStat (LevelUp): {0} set a {1}", _key, stat.control);
				}
				
				// Poner valores para regresar
				_return[$ _key] = stat.send();
			}
			
			i = i + 1;
        }
		#endregion
		
		// Ejecutar funcion al terminar de subir de nivel
		exLevel(_entity);
		
		return (_return );
    }
    
	#endregion
	
	#region Utils
	
	/// @param {struct.PartyEntity} partyEntity
	exLevel      = function(_entity)
	{
		static df=function(_entity) {} 
		var fn = method(self, dark_get_function(funLevel) ?? df);
		return (fn(_entity) );
	}
	
	/// @param {struct.PartyEntity} partyEntity
	exCheckLevel = function(_entity)
	{
		static df=function(_entity) {};
		var fn = method(self, dark_get_function(checkLevel) ?? df);
		return (fn(_entity) );
	}
	
	/// @desc Si el valor introducido es mayor que el actual de la estadistica devuelve true
	/// @param  {String} statKey
	/// @param  {Real}   compare
	/// @return {Bool}
	static isAbove = function(_key, _value) 
	{
		var _atom = get(_key)
		return (_atom.actual > _value);
	}
	
	/// @desc Si el valor introducido es menor que el actual de la estadistica devuelve true
	/// @param  {String} statKey
	/// @param  {Real}   compare
	/// @return {Bool}
	static isBelow = function(_key, _value) 
	{
		var _atom = get(_key)
		return (_atom.actual < _value);
	}
	
	/// @desc Devuelve true si el valor actual es el mismo que el valor "control" (peak)
	static isMax = function(_key) 
	{
		var _atom = get(_key);
		return (_atom.actual == _atom.control);
	}
	
	/// @param {Real} compare
	/// @return {Bool}
	static isAboveLevel = function(_value)
	{
		return (level > _value);
	}

	/// @param {Real} compare
	/// @return {Bool}
	static isBelowLevel = function(_value)
	{
		return (level < _value);
	}

	/// @return {Struct.PartyEntity}
	static getEntity = function() 
	{
		return (from.ref);
	}
	
	/// @return {Struct.PartyControl}
	static getEntityControl = function()
	{
		return (from.ref).getControl();
	}
	
	/// @return {Struct.PartySlot}
	static getEntitySlot    = function() 
	{
		return (from.ref).getSlot();
	}
	
	static LevelUpStat = function(_key, _level, _vars) 
	{
		var stat = get(_key);
		var _controlRest = (stat.control   - stat.equipment);
		var _slotRest    = (stat.equipment - stat.peak);
		
		/// partyStat, nivel
		var _sum = stat.exLevel(self, _level);
		
		// Actualizar valores
		stat.peak = clamp(_sum, stat.limitMin, stat.limitMax);
		
		// equipment = peak + items
		stat.equipment = stat.peak + _slotRest;
		
		// control = peak + equipment
		stat.control   = stat.peak + _slotRest + _controlRest;
		
		// el primero deja peak, equipment y control igual
		var _iter =  stat.iterator ;
		var _work = _iter.iterate();
		
		// Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo
		if (_work == 2) {
			stat.actual = (_iter.type) ? 
				stat.control :
				stat.limitMin;
		}
	}
	
	/// @desc Guarda los datos de estadistica en json
	static save = function() 
	{
		var _this = self;
		var _save = {};
		with(_save) {
			version = MALL_VERSION;
			is      = _this.is    ;
			
			level = _this.level;
			vars  = _this.vars;
		}
		
		var i=0; repeat(array_length(keys) ) {
			var _key  = keys[i];
			var _stat = get(_key);
			// Guardar
			_save[$ _key] = _stat.save();
			
			i = i + 1;
		}
		
		return (_save);
	}
	
	/// @desc Carga desde un struct datos
	static load = function(_l) 
	{
		if (_l.is != is) exit;
		level = _l.level;
		vars  = _l.vars ;
		// Cargar iteradores y niveles individuales
		var i=0; repeat(array_length(keys) ) {
			var _key  = keys[i];
			var _stat  = get(_key); 
			var _statL = _l[$ _key]; 
			
			// Cargar nivel
			_stat.level = _statL.level;
			// Iterator
			_stat.iterator.load(_statL.iterator);
			// Subir de nivel
			LevelUpStat(_key, level);

			_stat.actual = (_stat.saveValue) ? _statL.actual : _stat.control;
			i++;
		}
		var _p=0;
	}
	
	
	#endregion
	
	#endregion
	
	#region Ejecutar funciones de inicio
	var p=0; repeat(array_length(keys) ) {
		var _key  = keys[p];
		var _stat = get(_key);
		_stat.exStart(_entity);
		p = p + 1;
	}
	
	#endregion
}