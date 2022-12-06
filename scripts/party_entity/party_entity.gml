/// @param {String} entityKey
function PartyEntity(_key) : Mall(_key) constructor
{
	displayKey = _key;
	group = "";
	
	// Estructuras
	stat    = new PartyStat();     // Estadisticas
	slot    = new PartySlot();     // Equipo y partes
	control = new PartyControl();  // Control de estados / buffos
	
	turnCombat  = 0; // En que turno se mueve
	turnControl = 0; // Numero de turnos que han habido 
	
	pass = false;  // Si debe saltar un turno
	passCount = 0; // Cuantos turnos a saltado
	passReset = 0; // Reiniciar pass a esta cantidad de turnos -1 es infinito
	
	// Que comandos puede realizar
	commands = {
		defaults: {keys:[] }
	};	
	
	#region METHODS
	/// @param {String} category_key
	static setCommandCategory = function(_key)
	{
		commands[$ _key] ??= {keys:[] };  // Agregar categoria de comandos si no existe
		return self;
	}
	
	/// @param {String} dark_command_key
	/// @param {String} category_key
	static setCommand = function(_key, _category="defaults")
	{
		if (dark_exists(_key) ) {
			var _set = commands[$ _category];
			if (!variable_struct_exists(_set, _key) ) {
				_set[$ _key] = dark_get_command(_key);
				array_push(_set.keys, _key);
			}
		}
		return self;
	}
	
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
	
	
	#region Utils
	/// @desc Guarda los datos de esta entidad en json
	static save = function() 
	{
		var _this = self;
		var _save = {};
		with (_save) {
			version = MALL_VERSION; // Guardar version en la que se hizo el save
			key = _this.key;
			displayKey = _this.displayKey;
			
			// Guardar Stats
			stats     = _this.getStats().save()    ;
			control   = _this.getControl().save()  ;
			equipment = _this.getEquipment().save();
		}
		
		return (_save);
	}
	
	/// @desc Carga desde un struct datos
	static load = function(_load)
	{
		if (_load.is != is) exit;
		
		key = _load.key;
		displayKey = _load.displayKey;
		
		// Guardar Stats
		stats    .load(_load.    stats);
		control  .load(_load.  control);
		equipment.load(_load.equipment);
	
		// Actualizar componentes
		updateComponents();
	
		return self;
	}
	
	#endregion
	
	#endregion
}