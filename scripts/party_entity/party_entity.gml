/// @param {String} entityKey
function PartyEntity(_key) : Mall(_key) constructor
{
	displayKey = _key;
	group = "";
	
	// Estructuras
	stat    = new PartyStat();     // Estadisticas
	slot    = new PartySlot();     // Equipo y partes
	control = new PartyControl();  // Control de estados / buffos
	
	wateManager = noone; // Manager de combate actual
	turnAct     = 0;     // En que turno se mueve
	turnManager = 0;     // Numero de turnos que han pasado
	
	pass = false;  // Si debe saltar un turno
	passCount = 0; // Cuantos turnos a saltado
	passReset = 0; // Reiniciar pass a esta cantidad de turnos -1 es infinito
	
	// Que comandos puede realizar
	commands = {
		// Todas las categorias
		keys: [],
		defaults: {keys:[] }
	};	
	conduct = ""; // Como se comporta
	drops   = [];
	
	
	#region METHODS
	
	#region - Comandos
	/// @desc Crea una nueva categoria para los comandos
	/// @param {String} categoryKey
	static createCategory = function(_key)
	{
		// Evitar que sea "keys"
		if (_key == "keys") return self;
		// Agregar categoria de comandos si no existe
		commands[$ _key] ??= {keys:[] };
		// Lista de categorias
		array_push(commands.keys, _key);
		return self;
	}
	
	/// @desc  Obtiene todas las categorias
	/// @return {Array<string>}
	static getCategories = function()
	{
		return (commands.keys);
	}
	
	/// @param {String} categoryKey
	/// @param {String} commandKey
	static setCommand = function(_category, _key, _customKey)
	{
		if (dark_exists_command(_key) ) {
			// Si no existe la categoria crear
			if (!variable_struct_exists(commands, _category) ) createCategory(_category);
			
			var _toSet   = commands[$ _category];
			var _command = dark_get_command(_key);
			var _useKey  = _customKey ?? _key;
			
			if (!variable_struct_exists(_toSet, _useKey) ) {
				_toSet[$ _useKey] = _command
				
				// Añadir a la lista de comandos
				array_push(_toSet.keys, _useKey);
			}
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
	
	#region - Componentes
	/// @param {struct.PartyStat} partyStat
	static setStat = function(_partyStat) 
	{
		stat = _partyStat;
		return self;
	}
	
	/// @return {Struct.PartyStat}
	static getStat = function()
	{
		return (stat);
	}

	/// @param {struct.PartySlot} partySlot
	static setSlot = function(_partySlot)
	{
		slot = _partySlot;
		return self;
	}
	
	/// @return {struct.PartySlot}
	static getSlot = function()
	{
		return (slot);
	}

	/// @param {struct.PartyControl} partyControl
	static setControl = function(_partyControl)
	{
		control = _partyControl;
		return self;
	}
	
	/// @return {Struct.PartyControl}
	static getControl = function()
	{
		return (control);
	}
	
	/// @desc Actualizar los componentes de esta entidad (stat, control, equipment)
	static updateComponents = function()
	{
		var _this = self;
		with (stat)    from = weak_ref_create(_this);
		with (slot)    from = weak_ref_create(_this);
		with (control) from = weak_ref_create(_this);
		
		return self;
	}
	
	#endregion
	
	#region - Utils
	/// @desc Guarda los datos de esta entidad en json
	static save = function() 
	{
		var _this = self;
		var _save = {commands: {keys: []} };
		with (_save) {
			version = MALL_VERSION; // Guardar version en la que se hizo el save
			is      = _this.is;
			key = _this.key;
			displayKey = _this.displayKey;
			
			// Guardar Stats
			stat = _this.getStat().save();
			slot = _this.getSlot().save();
			control = _this.getControl().save();
		}
		
		#region Guardar comandos
		var _scom = _save.commands;
		var i=0; repeat(array_length(commands.keys) ) {
			var _ckey =  commands.keys[i], _cadd = [];
			array_push(_scom.keys, _ckey);
			
			var _comn = commands[$ _ckey];
			var j=0; repeat(array_length(_comn.keys) ) {
				var _comkey = _comn.keys[j];
				var _comstr = _comn[$ _comkey];
				// Guardar llaves
				array_push(_cadd, _comstr.key);
				
				j++;
			}
			// Añadir todas las llaves de comandos
			_scom[$ _ckey] = _cadd;
			
			i++;
		}
		
		#endregion
		
		return (_save);
	}
	
	/// @desc Carga desde un struct datos
	static load = function(_load)
	{
		if (_load.is != is) exit;
		
		key = _load.key;
		displayKey = _load.displayKey;
		
		// Guardar Stats
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
	
	
	#endregion
}