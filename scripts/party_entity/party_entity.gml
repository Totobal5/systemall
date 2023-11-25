/// @param {String} entityKey
function PartyEntity(_key) : Mall(_key) constructor
{
	displayKey = _key;
	// Llave del grupo al que pertenece
	group = "";
	
	// Estructuras
	level = __MALL_PARTY_MIN_LEVEL;
	fnLevelStart = __dummy;
	fnLevelEnd   = __dummy;
	fnCLevel = __dummy;
	
	// Estadisticas
	stats = {};
	array_foreach(mall_get_stat_keys(), function(statKey, i) {
		var _stat = mall_get_stat(statKey);
		stats[$ statKey] = new AtomStat(_stat);
		
		_stat.fnStart(self);
	})
	
	// Control y estados
	controls = {};
	controlsKeys = [];
	
	// Slots y equipo
	slots = {};
	slotsKeys = [];
	
	wateManager = noone; // Manager de combate actual
	turnAct     = 0;     // En que turno se mueve
	turnManager = 0;     // Numero de turnos que han pasado
	
	pass = false;  // Si debe saltar un turno
	passCount = 0; // Cuantos turnos a saltado
	passReset = 0; // Reiniciar pass a esta cantidad de turnos -1 es infinito
	
	// Que comandos puede realizar
	categories = {
		// Todas las categorias
		defaults: {keys:[] }
	};
	categoriesKeys = [];
	
	conduct = ""; // Como se comporta
	drops   = [];

	#region -- Stats
	static AtomStat = function(stat) constructor
	{
		/// @ignore
		is = "AtomStat";
	
		key = stat.key;
		displayKey = stat.displayKey;
		saveValue  = stat.saveValue;
		
		// -- Configuracion
		// Que pasar en la formula para subir de nivel
		vars   = {};
		single = stat.levelSingle;  // Si sube de nivel individualmente

		startAction = stat.startAction;
		endAction   = stat.endAction;
		entityUpdate = stat.entityUpdate;
		
		// Para los turnos
		turnStart = stat.fnTurnStart;
		turnEnd   = stat.fnTurnEnd  ;
		
		// Equipo
		equip    = stat.fnEquip;     // Al equipar un objeto (inicio) ejecuta esta funcion
		desequip = stat.fnDesequip;  // 
		
		// Niveles
		levelUp  =   stat.levelUp;
		checkLevel = stat.checkLevel;
		
		// Copiar iterador
		// Copiar la configuracion del otro iterador
		// Crear un iterador si no existe
		iterator = (stat.iterator != undefined) ? 
			stat.iterator.copy() : 
			new MallIterator();

		// -- Se ponen los valores inciales
		level = stat.startLevel; // Nivel de la estadistica si se usa individualmente
		base  = stat.start;
		type  = stat.type;
		
		// Valores que posee
		limitMin = stat.limitMin; // Valor maximo en que la estadistica puede estar
		limitMax = stat.limitMax; // Valor minimo en que la estadistica puede estar
	
		control   = base;    // El valor final tomando en cuenta el control
		equipment = control; // El valor final tomando en cuenta el equipamiento
	
		peak   = control; // Valor de la estadistica actual maximo respecto al nivel
		actual = control; // El valor actual de la estadistica
	
		lastPeak   = control; // El ultimo valor maximo
		lastActual = control; // El anterior valor actual
		
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
				iterator:   _this.iterator.save(),
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
	}
	
	/// @desc Obtiene un AtomStat a partir de la llave
	/// @param {String} statKey
	/// @returns {Struct.PartyEntity$$AtomStat}
	static statGet = function(_statKey)
	{
		var _atom = struct_get(stats, _statKey)
		return (_atom);
	}
	
	/// @param {String}             statKey     Llave de estadistica
	/// @param {Real}               baseValue   Valor de base
	/// @param {ENUM.MALL_NUMTYPE}  baseType    Tipo de numero
	/// @return {Struct.PartyEntity}
	static statSetBase = function(_statKey, _baseValue, _baseType) 
	{
		var i=0; repeat(argument_count div 3) {
			var _key = argument[i];
			var _val = argument[i + 1];
			var _typ = argument[i + 2];
			
			var _atom = statGet(_key);
			// Actualizar valores bases
			_atom.base = _val;
			_atom.type = _typ;
			
			#region DEBUG
			if (__MALL_PARTY_TRACE) {
			var _typeStr = toStringNumtype(_typ);
			show_debug_message($"MallRPG Party: {_key} base set to {_val}{_typeStr}");
			}
			#endregion
			
			i = i + 3;
		}

		return self;
	}

	/// @desc	Establece el valor actual de una estadistica teniendo como limites "limMin" y "control"
	/// @param	{String}            statKey  si es "all" permite cambiar el valor de todos los atomos
	/// @param	{Real}              value    Valor para establecer
	/// @param  {ENUM.MALL_NUMTYPE} numtype  Tipo de numero
	/// @return {Real}
	static statSet = function(_key, _value, _numtype=MALL_NUMTYPE.REAL)
	{
		static statKeys = mall_get_stat_keys();
		
		#region Cambiar a todas las estadisticas a este valor
		if (_key == all)  {
			var i=0; repeat(array_length(statKeys) ) {
				statSet(statKeys[i], _value, _numtype);
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
	/// @param {ENUM.STAT_NUMTARG}  [numtarg]   Que "value" usar 0: actual, 1:lastActual, 2: Peak, 3: lastPeak, 4: equipment, 5: control, Solo porcentajes!
	/// @return {Real} Devuelve el valor que se añadio
	static statAdd = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _useValue=0) 
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
					case STAT_NUMTARG.ACTUAL:  _use = _stat.actual;       break;
					case STAT_NUMTARG.LACTUAL: _use = _stat.lastActual;   break;
					
					case STAT_NUMTARG.PEAK:  _use = _stat.peak;          break;
					case STAT_NUMTARG.LPEAK: _use = _stat.lastPeak;      break;
					
					case STAT_NUMTARG.EQUIPMENT: _use = _stat.equipment;     break;
					case STAT_NUMTARG.CONTROL:   _use = _stat.control;       break;
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
	
	/// @desc Si el valor introducido es mayor que el actual de la estadistica devuelve true
	/// @param  {String} statKey
	/// @param  {Real}   compare
	/// @return {Bool}
	static statIsAbove = function(_key, _value)
	{
		var _atom = statGet(_key)
		return (_atom.actual > _value);
	}

	/// @desc Si el valor introducido es menor que el actual de la estadistica devuelve true
	/// @param  {String} statKey
	/// @param  {Real}   compare
	/// @return {Bool}
	static statIsBelow = function(_key, _value)
	{
		var _atom = statGet(_key)
		return (_atom.actual < _value);
	}

	/// @desc Devuelve true si el valor actual es el mismo que el valor "control" (peak)
	/// @param  {String} statKey
	static isMax = function(_key) 
	{
		var _atom = statGet(_key);
		return (_atom.actual == _atom.control);
	}

	/// @param {Real}   newLevel    Nuevo nivel
	/// @param {String} [statKey]   Solo si es individual
	/// @return {Struct.PartyStat}
	static statSetLevel = function(_level, _key) 
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
	static levelUp  = function(_set=false, _setLevel=0, _force=false) 
	{
		var _size   = array_length(keys);
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
		struct_remove(_return, "statKey"); // Eliminar
		
		// Revisar check global
		var _globalCheck = fnCLevel() + _force;
		if (!_globalCheck) exit;
		// Operar y Limitar niveles
		level = clamp(
			(!_set) ? level + _setLevel : _setLevel, 
			__MALL_PARTY_MIN_LEVEL, 
			__MALL_PARTY_MAX_LEVEL
			);
		
		// Funcion al iniciar el subir de nivel
		fnLevelStart();
		
		#region Ciclar por cada stat
		var i=0; repeat(array_length(keys) ) {
			// Feather ignore all
			var _key = keys[i];
			var stat = statGet(_key);
			
			var _check = undefined;  // Solo si es independiente
			var _level = 1;          // Nivel a usar
			if (stat.single) {
				stat.level  = (!_set) ? stat.level + _setLevel : _setLevel;
				_level = stat.level;
				_check = stat.fnCLevel(self);
			}
			else {
				_level = level; // Remplazar por nivel global
				_check =  true;
			}
			
			var _enterGlobal = (_globalCheck && _check != undefined);
			
			#region Subir de nivel
			if (_force || (_check || _enterGlobal) ) {
				var _controlRest = (stat.control   - stat.equipment);
				var _slotRest    = (stat.equipment - stat.peak);
				
				/// partyStat, nivel
				var _sum = stat.fnLevel(self, _level);
				
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
					stat.lastPeak = stat.level(self, max(1, _level - 1) );
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
			
			
			#endregion
			
			i = i + 1;
		}
		#endregion
		
		// Ejecutar funcion al terminar de subir de nivel
		fnLevelEnd(_entity);
		
		return (_return );
	}
	
	/// @param {string} statkey
	static levelUpStat = function(_key, _level, _vars) 
	{
		var stat = statGet(_key);
		var _controlRest = (stat.control   - stat.equipment);
		var _slotRest    = (stat.equipment - stat.peak);
		
		/// partyStat, nivel
		var _sum = stat.fnLevel(self, _level);
		
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
	
	
	#endregion
	
	#region -- Slots
	static AtomSlot = function(_active=true) constructor
	{
		is  = "AtomSlot";
		key = "";
		displayKey = "";
		
		// Objetos permitidos
		permited = {};
		active   = _active; // Si se puede usar este slot
		
		equipped = undefined; // Donde se almacenan los objetos que lleva
		previous = undefined; // Objeto anterior que se llevo
		
		// Indicar si se esta desequipando algo
		desequip = false;
		
		checkItem = function(entity, item) {return true; }
		
		/// @desc Guarda este componente
		static save = function() 
		{
			var _this = self;
			return ({
				version: MALL_VERSION,
				is :     _this.is,
				// Llaves
				key:        _this.key,
				displayKey: _this.displayKey,
				
				// Propiedades
				permited: variable_clone(permited),
				equipped: (_this.equipped == undefined) ? undefined : _this.equipped.key,
				previous: (_this.previous == undefined) ? undefined : _this.previous.key,
				active  : _this.active
				
			});
		}
		
		/// @param {Struct} loadStruct
		static load = function(_l)
		{
			// Llaves
			key =        _l.key;
			displayKey = _l.displayKey;
			
			// Importar permitidos
			permited = _l.permited;
			
			// Items
			equipped = (is_ptr(_l.equipped) ) ? undefined : pocket_data_get(_l.equipped);
			previous = (is_ptr(_l.previous) ) ? undefined : pocket_data_get(_l.previous);
			active   = _l.active;
			
			return self;
		}
	}
	
	/// @param {string} slotKey
	/// @param {bool} isActive
	static slotCreate = function(_key, _isActive=true)
	{
		var _atom = new AtomSlot(_isActive);
		_atom.key = _key;
		
		slots[$ _key] = _atom;
		array_push(slotsKeys, _key); // Guardar llaves
		
		return self;
	}
	
	/// @param {string} slotKey
	/// @return {Struct.PartyEntity$$AtomSlot}
	static slotGet = function(_key)
	{
		#region DEBUG
		if (__MALL_PARTY_DEBUG) {
		if (!struct_exists(slots, _key) ) {
		throw string("PartyEntity slotGet:: {0} no existe", _key)
		}
		}
		#endregion
		return (struct_get(slots, _key) );
	}
	
	/// @param {String}         slotKey Llave del slot
	/// @param {Function,Array} itemKey Puede ser un itemtype para aceptar todos los objetos que son de ese tipo. o un itemKey para objetos individuales
	static slotPermitedAdd = function(_slotKey, _item)
	{
		static types = MallDatabase.pocket.type ;
		static items = MallDatabase.pocket.items;
		
		// Es una array
		if (is_array(_item) ) {
			var i=0; repeat(array_length(_item) ) {
				slotPermitedAdd(_slotKey, _item[i++] ); 
			}
		}
		else {
			var _slot     = slotGet(_slotKey);
			var _permited = _slot.permited;
			// La llave es un tipo de objetos
			if (struct_exists(types, _item) ) {
				// Obtener la string de todos los objetos
				var _types     = types[$ _item];
				var _typesKeys = struct_get_names(_types);
				var i=0; repeat(array_length(_typesKeys) ) {
					var _key = _typesKeys[i];
					// Añadir objeto
					_permited[$ _key] = 0;
					i++;
				}
			}
			// Solo se pasa un objeto
			else {
				_permited[$ _item.key] = 0;
			}
		}
		return self;
	}
	
	/// @param {String} slotKey
	/// @param {String} key
	static slotPermitedRemove = function(_slotKey, _item)
	{
		static types = MallDatabase.pocket.type ;
		static items = MallDatabase.pocket.items;
		
		var _slot     = slotGet(_slotKey);
		var _permited = _slot.permited;
		// Se paso un tipo
		if (struct_exists(types, _item) ) {
			var _types = types[$ _item];
			var _tkeys = struct_get_names(_types);
			var i=0; repeat(array_length(_tkeys) ) {
				var _tkey = _tkeys[i];
				struct_remove(_permited, _tkey);
				i++;
			}
		}
		// Una llave de objeto
		else {
			struct_remove(_permited, _item.key);
		}
		return self;
	}
	
	/// @desc Equipa un objeto en el slot indicado. Si se logra equipar devuelve un struct
	/// @param {String}            slotKey En que slot equipar el objeto
	/// @param {Struct.PocketItem} itemKey Llave del objeto
	static slotEquip = function(_slotKey, _item)
	{
		var _slot    = slotGet(_slotKey);
		var _return  = {result: false, previous: undefined};
		// Se puede equipar este objeto
		if (struct_exists(_slot.permited, _item.key) ) {
			// Realizar una comprobacion de parte del slot
			if (_slot.checkItem(self, _item) ) return _return;
			// Obtener previo
			var _prev = _slot.previous
			_slot.previous = _slot.equipped;
			_slot.equipped = _item;
			
			// Actualizar entidad
			updateComponents();
			
			// Ejecutar funcion de desequipar si habia un objeto anteriormente
			if (!is_undefined(_prev) ) _prev.desequip(self);
			
			// Ejecutar funcion de equipar
			_item.equip(self);
			
			_return.result   =  true;
			_return.previous = _prev;
		}
		
		return (_return);
	}
	
	/// @param {String} slotKey
	static slotDesequip = function(_key)
	{
		static noitem = new PocketItem("");
		var _slot   = slotGet(_key);
		var _return = {result: false, previous: undefined};
		
		var _item = _slot.equipped ?? noitem;
		// Comprobar si puede ser desequipado
		if (!_item.canDesequip(self) ) return (_return);
		
		// Intercambiar equipo
		_slot.previous = _slot.equipped;
		_slot.equipped = undefined;
		
		// Actualizar entidad
		updateComponents();
		
		// Funcion de desequipar
		_item.desequip(self);
		
		_return.result   = true;
		_return.previous = _slot.previous;
		
		return (_return);
	}
	
	/// @param {String} slotKey
	/// @return {Struct.PocketItem}
	static slotGetEquipped = function(_key)
	{
		var _atom = controlGet(_key);
		return (_atom.equipped);
	}
	
	/// @param {String}            slotKey
	/// @param {Struct.PocketItem} item
	static slotIsPermited = function(_key, _itemKey)
	{
		var _atom = slotGet(_key);
		return (struct_exists(_slot.permited, _itemKey ) );
	}
	
	#endregion
	
	#region -- States y Control
	static AtomState = function(_init=false) constructor
	{
		/// @ignore
		is = "AtomState";
		
		// Configuracion
		key  =       "";    // Llave de este estado
		displayKey = "";    // 
		
		stateInit = _init; // Estado a que reinicia
		state     = _init; // Estado actual
		
		type = MALL_NUMTYPE.REAL // Numero que utiliza este estado
		
		same     = false; // Si acepta el mismo control varias veces
		controls = -1;    // -1 se pueden agregar elementos infinitos
		
		// Valores que varian [real, porcentual] son actualizados
		values = array_create(2, 0);
		// Para las estadisticas
		stats  =    {};
		statsKeys = [];
		
		// Flags que posee este atomo
		flags =    array_create(0);
		// Contenidos que posee este atomo
		contents = array_create(0);
		
		/// @return {Array<Struct.DarkEffect>}
		static getContent = function()
		{
			// Feather ignore all
			return contents;
		}
		
		/// @desc Como guarda este componente
		static save = function()
		{
			var _this = self;
			var _save  = {contents: array_create(0), flags: array_create(0)};
			var _array = array_create(0);
			with (_save) {
				version = MALL_VERSION;
				is =      _this.is;
				// Llaves
				key =        _this.key;
				displayKey = _this.displayKey;
				//
				stateInit = _this.stateInit;
				state =     _this.state; 
				// Contenidos
				values = variable_clone(_this.values);
				type =   _this.type; // Numero que utiliza este estado
				// Propiedades
				same =     _this.same;     // Si acepta el mismo control varias veces
				controls = _this.controls; // -1 se pueden agregar elementos infinitos				
				
				// Stats
				stats     = variable_clone(_this.stats);
				statsKeys = variable_clone(_this.statsKeys);
				
				var _use={this: _this};
				// Guardar contenido
				array_foreach(_this.contents, method(_use, function(effect, i) {
					array_push(contents, effect.save());
				}) );
				
				// Guardar flags
				array_foreach(_this.flags, method(_use, function(flag) {
					array_push(flags, flag);
				}) );

				return self;
			}
			
			return (_save);
		}
		
		/// @desc Como carga este componente
		/// @param {struct} loadStruct
		static load = function(_l)
		{
			// Version
			version = MALL_VERSION;

			// Llaves
			key =        _l.key;
			displayKey = _l.displayKey;
			
			// State
			stateInit = _l.stateInit;
			state =     _l.state;
			
			// Valores
			values = _l.values;
			type =   _l.type;
			
			// Propiedades
			same =     _l.same;
			controls = _l.controls;
			
			// Importar stats
			stats =      _l.stats;
			statsKeys =  _l.statsKeys;
			
			// Obtener contenido
			array_foreach(_l.content, function(effect) {
				// Crear DarkEffect
				var _script  = effect.is;
				var _neffect = new script_execute(_script)
				// Importar valores
				_neffect.load(effect);
				
				// Agregar
				array_push(contents, _neffect);
			});
			
			// Flags
			array_foreach(_l.flags,   function(flag) {
				array_push(flags, flag);
			});
		}
	}
	
	/// @desc Añade un estado nuevo
	/// @param {String} controlKey
	/// @param {Bool}   stateInit
	static controlCreate = function(_key, _init=false) 
	{
		var _atom = new AtomState(_init);
		// Establecer llave
		_atom.key = _key;
		
		controls[$ _key] = _atom;
		array_push(controlsKeys, _key);
		return _atom;
	}
	
	/// @desc Obtiene un estado en el control
	/// @param {String} controlKey
	/// @return {Struct.PartyEntity$$AtomState}
	static controlGet = function(_key)
	{
		#region DEBUG
		if (__MALL_PARTY_DEBUG) {
		if (!struct_exists(control, _key) ) {
		throw string("PartyEntity controlGet:: {0} no existe", _key)
		}
		}
		#endregion
		return (struct_get(control, _key) );
	}

	/// @desc Si existe un estado en el control
	/// @param {String} controlKey
	/// @return {Bool}
	static controlExists = function(_key)
	{
		return (struct_remove(control, _key) );
	}
	
	/// @desc Elimina un estado del control
	/// @param {String} controlKey
	static controlRemove = function(_key)
	{
		#region DEBUG
		if (__MALL_PARTY_DEBUG) {
		if (!struct_exists(control, _key) ) {
		throw string("PartyEntity controlRemove:: {0} no existe", _key);
		}	
		}
		#endregion
		struct_remove(control, _key);
		return self;
	}
	
	/// @desc Establece un nuevo valor en "values" con el tipo de numero default o diferente
	/// @param {String}            controlKey
	/// @param {Array<Real>,Real}  value
	/// @param {Enum.MALL_NUMTYPE} type
	static controlValuesSet = function(_key, _value, _type)
	{
		var _atom = controlGet(_key);
		if (is_array(_value) ) {
			_atom.values[0] = _value[0];
			_atom.values[1] = _value[1];
		} else {
			_atom.values[_type] = _value;
		}
		
		return self;
	}

	/// @desc Añade un valor al control (suma/resta)
	/// @param {String}            controlKey
	/// @param {Array<Real>,Real}  value
	/// @param {Enum.MALL_NUMTYPE} type
	static controlValuesAdd = function(_key, _value, _type)
	{
		var _atom = controlGet(_key);
		if (is_array(_value) ) {
			_atom.values[0] += _value[0];
			_atom.values[1] += _value[1];
		} else {
			_atom.values[_type] += _value;
		}
		
		return self;
	}
	
	/// @desc Establebe el control a su valor inicial
	/// @param {String} controlKey "all" para reiniciar todos
	static controlValuesReset = function(_key)
	{
		#region Reiniciar todos
		if (_key == all) {
			var _keys = controls.keys, i=0;
			repeat(array_length(_keys) ) controlValuesReset(_keys[i++] );
		}
		#endregion
		
		#region Solo 1
		else  {
			var _atom = controlGet(_key);
			_atom.values = array_create(2, 0);
		}
		#endregion
		
		return self;
	}
	
	/// @desc Indica el estado en que se encuentra un estado/estadistica
	/// @param {String} controlKey
	/// @return {Bool}
	static controlState = function(_key) 
	{
		var _atom = controlGet(_key);
		if (_atom == undefined) return undefined;
		return (_atom.state);
	}

	/// @desc Establece el estado de este control
	/// @param {String} controlKey
	/// @return {Bool}
	static controlStateSet = function(_key, _state)
	{
		var _atom = controlGet(_key);
		return (_atom.state = _state);
	}
	
	/// @param {String} controlKey
	static controlStateReset = function(_key)
	{
		var _atom = controlGet(_key);
		_atom.state = _atom.stateInit;
		return self;
	}

	/// @desc Indica si hay efectos en este estado
	/// @param  {String} controlKey
	/// @return {Bool}
	static controlHasContent = function(_key)
	{
		var _atom = controlGet(_key);
		return (array_length(_atom.content) > 0);
	}
	
	/// @desc Agrega un efecto al control que afecta (stat/state/action). Si lo agrega "true" si no "false"
	/// @param {Struct.DarkEffect} darkEffect
	/// @return {Bool}
	static controlEffectAdd = function(_effect)
	{
		#region Comprobar state
		var _stateKey = _effect.stateKey;
		// Si no existe el control crear
		if (!controlExists(_stateKey) ) {
			#region TRACE
			if (__MALL_PARTY_TRACE) {
			show_debug_message("PartyEntity controlEffectAdd:: {0} no existe y se va a crear", _stateKey); 
			}
			#endregion
			controlCreate(_stateKey);
		}
		
		#endregion
		// Obtener control
		var _control = controlGet(_stateKey);
		var _content = _control.getContent(), _contentSize = array_length(_content);
		
		#region Comprobar limite
		// no infinitos
		if (_control.controls > 0) {
			// Si supero el limites entonces salir 
			// ya que no se pueden agregar más elementos
			if (_contentSize > _control.control) {
				return false; 
			}
		}
		#endregion
		
		#region Comprobar si permite el mismo
		if (!_control.same) {
			var _call = {search: _effect.id};
			var _any  = array_any(_content, method(_call,function(effect) {return (effect.id == search); } ) );
			
			// Si existe el mismo salir ya que no pueden haber más de 1
			if (_any) return false;
		}
		
		#endregion
		
		// Al pasar todo agregar al contenido
		array_push(_content, _effect);
		// Ejecutar evento al agregar un efecto nuevo
		_effect.added(self);
		
		// Aplicar valor inicial dependiendo del tipo
		controlValuesAdd(_stateKey, _effect.value, _effect.type);
		
		// Actualizar valores de las estadisticas
		updateComponents();

		return true;
	}

	/// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos. El filtro default borra el primer elemento
	/// @param	{String}    controlKey  controlKey
	/// @param	{Function}  filter      function(effect, i) {return Bool}
	static controlEffectRemove = function(_key, _filter)
	{
		// El filtro default borra el primero de la lista
		static dfnFilter = function(effect, i) {return (i==0);}
		_filter ??= dfnFilter; // Default
		
		var _atom    = controlGet(_key);
		var _content = _atom.getContent();
		
		#region Filtrar
		var _index = array_find_index(_content, _filter);
		// No existe el elemento
		if (_index == -1) return undefined;
		
		#endregion
		
		// Obtener effecto que se va a eliminar
		var _effect = _content[_index];
		// Eliminar del array de contenido
		array_delete(_content, _index, 1);
		// Ejecutar funcion de eliminar
		_effect.remove(self);
		
		// Reducir valor
		controlValuesAdd(_key, -_effect.value, _effect.type);
		
		// Actualizar valores de las estadisticas
		updateComponents();
		
		return (_effect);
	}

	/// @param	{String} controlKey  controlKey
	static controlEffectRemoveAll = function(_key)
	{
		var _atom =    controlGet(_key);
		var _content = _atom.getContent();
		
		for (var i=0,n=array_length(_content); i<n; i++)
		{
			var _effect = _content[i];
			
			_effect.remove(self);	
			
			// Reducir valor
			controlValuesAdd(_key, -_effect.value, _effect.type);			
			
			array_delete(_content, 0, 1);
			n--;
		}
		
		// Actualizar valores de las estadisticas
		updateComponents();		
	}
	
	/// @desc Actualiza un control
	/// @param {String} controlKey "all" para actualizar a todos
	/// @param {Real}   turnType   0: Inicio del turno, 1: Final del turno, 2: Ambos
	static controlEffectUpdate = function(_key, _type=0)
	{
		static loop = false;
		
		var _return = {value: [0, 0], result: false};
		#region Actualizar solo un efecto
		if (_key != all) {
			var _atom   = controlGet(_key);
			var _return = [0, 0];
			// Obtener contenido
			var _content = _atom.getContent();
			var _size =    array_length(_content);
			if (_size > 0) {
				// Actualizar contenidos
				for (var i=0; i<_size; i = i+1) {
					var _effect =   _content[i];
					var _turnType = _effect.turnType;
					
					if (_turnType == _type) {
						var _iterator = _effect.getIterator(_type);
						// Iterar y guardar resultado
						var _iterate =  _iterator.iterate();
						var _value=_effect.value, _numtype=_effect.type;
						
						// Aun esta funcionando
						if (_iterate == 0) {
							// Ejecutar funcion de actualizar de turno de inicio
							_effect.fnTurnStart(self);
							// Aumentar valores
							controlEffectAdd(_key, _value, _numtype);
							// Agregar al valor a regresar
							_return.value[_type] += _value;
						}
						// Termino este efecto
						else if (_iterate == -1) {
							// Ejecutar funcion de termino de efecto
							_effect.fnReady(self);
							// Restar a los valores
							controlEffectAdd(_key, -_value, _numtype);
							// Agregar al valor a regresar
							_return.value[_type] -= _numtype;
							
							// Eliminar del array
							array_delete(_content, i, 1);
							_size--; // Restar al contenido
						}
					}
				}
			}
		
			// Actualizar componentes
			if (!loop) updateComponents("EffectUpdate");
		
			// Indicar que se completo esta funcion correctamente
			_return.result = true;
			
			return (_return);
		}
		
		#endregion
		
		#region Actualizar todos
		else {
			// No actualizar por cada elemento
			loop = true;
			var _rn = {};
			var i=0; repeat(array_length(controlsKeys) ) {
				var _k = controlsKeys[i];
				_rn[$ _k] = controlEffectUpdate(_k, _type);
				i++;
			}
			
			// Actualizar componentes
			updateComponents("EffectUpdate");
			loop = false; // Evitar
			
			return _rn;
		}
		
		#endregion
	}
	
	#endregion
	
	#region -- Comandos
	/// @desc Crea una nueva categoria para los comandos
	/// @param {String} categoryKey
	static createCategory = function(_key)
	{
		// Agregar categoria de comandos si no existe
		if (!struct_exists(categories, _key) ) {
			categories[$ _key] = {keys:[] };
			// Añadir a la lista
			array_push(categoriesKeys, _key);
		}

		return self;
	}
	
	/// @desc  Obtiene todas las categorias
	/// @return {Array<string>}
	static getCategories = function()
	{
		return (categoriesKeys);
	}
	
	/// @param {String}             categoryKey
	/// @param {Struct.DarkCommand} command
	static setCommand = function(_key="default", _command)
	{
		// Si no existe la categoria crear
		if (!struct_exists(categories, _key) ) createCategory(_key);
		
		// Obtener categoria
		var _commandKey = _command.key;
		var _category   = categories[$ _key];
		if (!struct_exists(_category, _commandKey) ) {
			_category[$ _commandKey] = _command;
			array_push(_category.keys, _commandKey);
		}

		return self;
	}
	
	/// @param {String} categoryKey
	/// @param {String} commandKey
	static getCommand = function(_category, _key) 
	{
		return (commands[$ _category][$ _key] );
	}
	
	/// @param {String} categoryKey
	/// @return {Array<string>}
	static getCommandKeys = function(_category)
	{
		var _command = commands[$ _category];
		return (_command.keys);
	}
	
	#endregion
	
	#region -- Utils
	/// @desc Actualiza stats
	static updateComponents = function(_from="")
	{
		var _slotStats    = {};
		var _controlStats = {};
		var _statKeys =  mall_get_stat_keys();
		var _statSize =  array_length(_statKeys), _stat, _statKey;
		var i=0, j=0, k=0;
		// Obtener estadisticas de los objetos equipados
		i=0; repeat(array_length(slotsKeys) ) {
			var _slotkey = slotsKeys[i];
			var _slot =    slotGet(_slotkey);
			if (_slot.desequip) {
				_slot.desequip=false; i++;
				continue;
			}
			
			var _item = _slot.equipped;
			// Hay un objeto equipado
			if (!is_undefined(_item) ) {
				var _itemStatsKeys = _item.statsKeys;
				j=0; repeat(array_length(_itemStatsKeys) ) {
					var _itemStatKey = _itemStatsKeys[j];
					// Si no existe crear
					if (!struct_exists(_slotStats, _itemStatKey) ) {
						_slotStats[$ _itemStatKey] = 0;
					}
					// Obtener valores de la estadisticas
					var _itemStat =  _item.stats[$ _itemStatKey];
					// Obtener valores
					var _itemValue = _itemStat[0], _itemType  = _itemStat[1];
					switch (_itemType) {
						case MALL_NUMTYPE.REAL:
							_slotStats[$ _itemStatKey] += _itemValue; 
							break;
							
						case MALL_NUMTYPE.PERCENT:
							var _stat = statGet(_itemStatKey);
							_slotStats[$ _itemStatKey] += (_stat.peak * _itemValue) / 100;

							break;
					}
					
					j++;
				}
			}
			
			i++;
		}
		
		// Actualizar estados
		i=0; repeat(array_length(controlsKeys) ) {
			var _controlKey = controlsKeys[i];
			var _control = controlGet(_controlKey);
			var _cnStats = _control.stats;
			// Ciclar por cada estadistica
			j=0; repeat(_statSize) {
				_statKey = _statKeys[j]; // llave de estadistica
				// Solo si existe el valor en el struct
				if (struct_exists(_cnStats, _statKey) ) {
					if (!struct_exists(_controlStats, _statKey) ) {
						_controlStats[$ _statKey] = 0;
					}
					var _cnStat = _cnStats[$ _statKey] ?? 0;
					var _cnReal = _cnStat[0] // Valor real       (0)
					var _cnPerc = _cnStat[1] // Valor porcentual (0)
					
					_stat = statGet(_statKey);
					// Cambiar valor del control
					_controlStats[$ _statKey] = _cnReal + ((_stat.peak * _cnPerc) / 100);
				}
				
				j++;
			}
			
			i++;
		}
		
		// Actualizar Estadisticas
		i=0; repeat(_statSize) {
			var _statKey = _statKeys[i]
			var _stat =    statGet(_statKey);
			
			// Equipamiento (no puede ser menor al limite menor
			var _equipment = _stat.peak + _slotStats[$ _statKey];
			_stat.equipment = max(_equipment, _stat.limitMin);
			
			// Control y efectos
			var _control = _controlStats[$ _statKey];
			_stat.control = max(_stat.equipment + _control, _stat.limitMin);
			
			i++;
		}
	}

	/// @desc Guarda los datos de esta entidad en json
	static save = function() 
	{
		var _this = self;
		var _save = {
			categories: {}, categoriesKeys: variable_clone(_this.categoriesKeys), 
			slots:      {}, slotsKeys:      variable_clone(_this.slotsKeys), 
			controls:   {}, controlsKeys:   variable_clone(_this.controlsKeys),
			stats: {}
		};
		
		with (_save) {
			// Guardar version en la que se hizo el save
			version = MALL_VERSION;
			is  = _this.is;
			key =        _this.key;
			displayKey = _this.displayKey;
			// Grupo al que pertenece
			group =      _this.group;
			
			// Guardar Stats
			var _use={this: _this};
			array_foreach(mall_get_stat_keys(), method(_use, function(key) {
				// Guardar estadistica
				stats[$ key] = this.statGet(key).save();
			}) );
			
			// Guardar slots
			array_foreach(_this.slotsKeys, method(_use, function(key, i) {
				slots[$ key] = this.slotGet(key).save();
			}) );
			
			// Guardar control
			array_foreach(_this.controlsKeys, method(_use, function(key, i) {
				controls[$ key] = this.controlGet(key).save();
			}) );
		
			// Guardar categorias y comandos
			array_foreach(_this.categoriesKeys, method(_use, function(categorie) {
				var _cat = this.categories[$ categorie];
				// Guardar cada comando
				categories[$ categorie] = _cat.key;
			}) );
		}

		return (_save);
	}
	
	/// @desc Carga desde un struct datos
	static load = function(_l)
	{
		// Llaves
		key =        _l.key;
		displayKey = _l.displayKey;
		group =      _l.group;
		
		// Guardar Stats
		var _use = {l: _l};
		
		// Cargar estadisticas
		array_foreach(mall_get_stat(), method(_use, function(key) {
			statGet(key).load(l);
		}) );
		
		// Cargar slots
		array_foreach(_l.slotsKeys, method(_use, function(key) {
			var _slot = l.slots[$ key];
			var _new =  slotCreate(key).load(_slot);
		}) );
		
		// Cargar control
		array_foreach(_l.controlsKeys, method(_use, function(key) {
			var _control = l.controls[$ key];
			var _new =     controlGet(key).load(_control);
		}) );
		
		// Cargar comandos
		array_foreach(_l.categoriesKeys, method(_use, function(key) {
			// crear categoria
			createCategory(key); 
			// Obtener llaves
			var _categoryKeys = l.categories[$ key];
			var i=0; repeat(array_length(_categoryKeys) ) {
				var _commandKey = _categoryKeys[i];
				var _newCommand = new script_execute(_commandKey);
				
				setCommand(key, _newCommand);
				
				i++;
			}
			
		}) );
		
		
		stat.load(_load.stat);
		slot.load(_load.slot);
		control  .load(_load.control);
		
		#region Cargar comandos
		var _lcom = _load.commands;
		var i=0; repeat(array_length(_lcom.keys) ) {
			var _ckey = _lcom.keys[i];
			
			// Añadir categorias
			array_push(commands.keys, _ckey);
			var _cadd = {keys: []};
			commands[$ _ckey] = _cadd;
			 
			// Ciclar cada categoria
			var _com = _lcom[$ _ckey]; // Es un array!
			var j=0; repeat(array_length(_com) ) {
				var _comkey = _com[j];
				// Recrear comandos y categorias
				if (dark_exists_command(_comkey) ) {
					_cadd[$ _comkey] = dark_get_command(_comkey);
					// Añadir a la lista de comandos
					array_push(_cadd.keys, _comkey);
				}
				j++;
			}
			
			i++;
		}
		
		#endregion
		
		// Actualizar componentes
		updateComponents();
	
		return self;
	}
	
	#endregion
	
	/// @param {string}           itemKey
	/// @param {real,array<real>} quantity
	/// @param {real}             probability
	static addDrop = function(_key, _value, _probability)
	{
		array_push(drops, {
			key: _key,
			
			value: !is_array(_value) ? _value : irandom_range(_value[0], _value[1]),  // Can be an array
			prob : _probability
		});
		return self;
	}

}