/// @param {Struct.PartyEntity}	party_entity
function PartySlot(_entity=other) : Mall() constructor 
{	
	/// @ignore Crear referencia a la entidad
	from = is_instanceof(_entity, PartyEntity) ? weak_ref_create(_entity) : undefined;
	/// @ignore Llaves
	keys = [];
	array_foreach(mall_get_slot_keys(), function(_key)  {
		var _component = mall_get_slot(_key);
		variable_struct_set(self, _key, new createAtom(_component) );
		array_push(keys, _key);
		if (MALL_PARTY_TRACE) {show_debug_message("MallRPG Party (prSlot): {0} creado", _key); }
	});
	
	#region METHODS
	
	/// @param {Struct.MallSlot} slotComponent
	static createAtom = function(_slot) constructor 
	{
		/// @ignore
		is = "PartySlot$$createAtom";

		key        = _slot.key;
		displayKey = _slot.displayKey;
		
		/// @ignore Items permetidos
		permited = {};
		active   = _slot.init;  // Si se puede usar
		
		equipped = undefined; // Donde se almacenan los objetos que lleva
		previous = undefined; // Objeto anterior que se llevo
		
		/// @ignore Indicar que se desequipa o no
		desequip = false;
		
		/// @ignore
		checkItem  = _slot.checkItem ;
		funCompare = _slot.funCompare;
		
		#region METHODS
		/// @ignore
		static fnDefaultCompare = function(_entity, _itemA, _itemB)
		{
			return {noUse: true}
		}
		
		static send = function()
		{
			return {
				key: other.key,
				active: other.active,
			
				equipped: other.equipped,
				previous: other.equipped,
			};
		}
		
		/// @param {struct.PartyStat}  entity
		/// @param {struct.PocketItem} item
		exCheckItem = function(_entity, _item)
		{
			static fun = dark_get_function(checkItem) ?? function(_entity, _item) {return true};
			return (fun(_entity, _item) );
		}

		/// @param {struct.PartyStat}  entity
		/// @param {struct.PocketItem} itemA
		/// @param {struct.PocketItem} itemB
		exCompare  = function(_entity, _itemA, _itemB)
		{
			static fun = dark_get_function(funCompare) ?? defaultCompare;
			return (fun(_entity, _itemA, _itemB) );
		}
		
		/// @desc Guarda este componente
		static save = function() 
		{
			var _this = self;
			return ({
				version: MALL_VERSION,
				is     : _this.is    ,
				
				equipped: (_this.equipped == undefined) ? undefined : _this.equipped.key,
				previous: (_this.previous == undefined) ? undefined : _this.previous.key,
				active  : _this.active
				
			});
		}
		
		/// @param {Struct} loadStruct
		static load = function(_l)
		{
			if (_l.is != is) exit;
			equipped = (is_ptr(_l.equipped) ) ? undefined : pocket_data_get(_l.equipped);
			previous = (is_ptr(_l.previous) ) ? undefined : pocket_data_get(_l.previous);
			active   = _l.active;
			
			return self;
		}
	
		#endregion
	}
	
	/// @param {String} slotKey
	/// @return {Struct.PartySlot$$createAtom}
	static get = function(_key) 
	{
        return (self[$ _key] );
    } 
		
	/// @param {String} slotKey  Llave del slot
	/// @param {String,Array} key      Puede ser un itemtype para aceptar todos los objetos que son de ese tipo. o un itemKey para objetos individuales
	static setPermited = function(_slotKey, _key)
	{
		static types = MallDatabase.pocket.type ;
		static items = MallDatabase.pocket.items;
		
		if (is_array(_key) ) {
			var i=0; repeat(array_length(_key) ) {
				setPermited(_slotKey, _key[i++] );
			}
		} else {
			var _slot = get(_slotKey);
			if (_slot == undefined) return self;
			var _slotPermited = _slot.permited;
		
			// Si se paso un tipo
			if (variable_struct_exists(types, _key) ) {
				var _types = types[$ _key]; // Obtener la string de todos los objetos
				var _keys  = variable_struct_get_names(_types);
				var i=0; repeat(array_length(_keys) ) {
					var _k = _keys[i];
					_slotPermited[$ _k] = 0;
					i = i + 1;
				}
			}
			// Se paso un objeto
			else if (variable_struct_exists(items, _key) ) {
				_slotPermited[$ _key] = 0;
			}
		}
		return self;
	}
	
	/// @param {String} slotKey
	/// @param {String} key
	static removePermited = function(_slotKey, _key)
	{
		static types = MallDatabase.pocket.type ;
		static items = MallDatabase.pocket.items;
		
		var _slot = get(_slotKey);
		if (_slot == undefined) return self;
		var _slotPermited = _slot.permited;
		// Si se paso un tipo
		if (variable_struct_exists(types, _key) ) {
			var _types = types[$ _key]; // Obtener la string de todos los objetos
			var _keys  = variable_struct_get_names(_types);
			
			var i=0; repeat(array_length(_keys) ) {
				var _k = _keys[i];
				variable_struct_remove(_slotPermited, _k);
				i = i + 1;
			}
		}
		// Se paso un objeto
		else if (variable_struct_exists(items, _key) ) {
			variable_struct_remove(_slotPermited, _key);
		}

		return self;
	}
	
	
	/// @desc Equipa un objeto en el slot indicado. Si se logra equipar devuelve un struct
	/// @param {String} slotKey En que slot equipar el objeto
	/// @param {String} itemKey Llave del objeto
	static equip = function(_key, _item_key) 
	{
		// Feather ignore all
		var _slot = get(_key);
		if (MALL_ERROR) {
			if (is_undefined(_slot) ) {
				var _str = string(MALL_MSJ_DV + "PartySlot (Equip): no existe {0}", _key);
				show_error(_str, true);
			}
		}
		
		var _ret = {result: false, previous: _slot.previous};

		// Obtener datos de este objeto
		var _item = pocket_data_get(_item_key);

		// Si puede equipar este objeto
		if (!is_undefined(_item) && variable_struct_exists(_slot.permited, _item.key) ) {
			var _entity = getEntity();
			// Check propio del slot respecto a un objeto
			if (!_slot.exCheckItem(_entity, _item) ) return _ret;
			
			var _previous = _slot.previous;
			// Equipar objeto y actualizar el previo
			_slot.previous = _slot.equipped;
			_slot.equipped = _item;

			// Actualiza todas las estadisticas que este objeto afecta
			var _itemKeys = variable_struct_get_names(_item.stats);
			var _stats    = getEntityStat();
			var i=0; repeat(array_length(_itemKeys) ) {
				var _stat = _itemKeys[i];
				_stats.updateBySlot(_stat);
				i = i + 1;
			}
			
			// Si habia un objeto ejecutar funcion de desequipar
			if (_previous != undefined) _previous.exDesequip(_entity);
			
			// Ejecutar funcion de equipo del objeto nuevo
			_item.exEquip(_entity);
			
			// Si pudo equipar algo
			_ret.result   = true;
			_ret.previous = _slot.previous;
		}
		
		return _ret;
    } 
	
	/// @param {String} slotKey
	static desequip = function(_key) 
	{
		static noitem = new PocketItem("", "");
		var _ret  = {result: false, previous: undefined};
		var _slot = get(_key);
		if (MALL_ERROR) {
			if (is_undefined(_slot) ) {
				var _str = string(MALL_MSJ_DV + "PartySlot (desequip): no existe {0}", _key);
				show_error(_str, true);
			}
		}
		
		// Si no hay un objeto equipado pasar un dummy object
		var _item = _slot.equipped ?? noitem;
		_slot.previous = _slot.equipped;
		_slot.equipped = undefined;
		
		// Marcar que se esta desequipando algo
		_slot.desequip = true; 
		
		#region Actualizar estadisticas
		// Actualiza todas las estadisticas que este objeto afecta
		var _itemKeys = variable_struct_get_names(_item.stats);
		var _stats    = getEntityStat();
		var i=0; repeat(array_length(_itemKeys) ) {
			var _stat = _itemKeys[i];
			_stats.updateBySlot(_stat, true);
			i = i + 1;
		}
		
		// Sacar marca
		_slot.desequip = false;
		
		// Ejecutar funcion de desequipar
		var _entity = getEntity();
		_item.exDesequip(_entity);
		
		#endregion
		
		_ret.result   = true;
		_ret.previous = _slot.previous;
		
		return (_ret);
    } 
	
	/// @desc Actualiza todas las estadisticas
	static update = function() 
	{
		var _keys  = mall_get_stat_keys();
		var _stats = getEntityStat();
		var i = 0; repeat(array_length(_keys) ) {
			var _key = _keys[i];
			_stats.updateBySlot(_key);
			i = i + 1;
		}
		
		return self;
	}
	
	/// @param {String} slotKey
	/// @returns {Bool}
	static isEquipped = function(_key) 
	{
		var _slot = get(_key);
        return (_slot.equipped != undefined);
    }

	/// @param {String} slotKey
	/// @returns {Bool}
	static isEmpty = function(_key) {
		var _slot = get(_key);
		return (_slot.equipped == undefined);
	}

	/// @param {String} slotKey
	/// @param {String} typeKey
	static isPermited = function(_key, _typeKey)
	{
		var _slot = get(_key);
		return (variable_struct_exists(_slot.permited, _typeKey) );
	}
	
	
	/// Compara las estadisticas del objeto actual con otro objeto obteniendo la diferencia en estadisticas
	/// @param {String} slotKey
	/// @param {String} itemkey
	/// @returns {Struct}
	static compareItem = function(_key, _itemKey) 
	{
		if (!weak_ref_alive(from) ) exit;
		var _slot = get(_key);
		
		var _itemA = _slot.equipped;            // Equipado
		var _itemB = pocket_data_get(_itemKey); // A Equipar

		var _entity = getEntity();
		return (_slot.exCompare(_entity, _itemA, _itemB) );
	}
	
	/// @desc Regresa las estadisticas sin este objeto equipado.
	/// @param {String} equipment_key
	/// @returns {Struct}
	static compareNoItem = function(_key) 
	{
		static noitem = new PocketItem("");
		var _slot = get(_key);
		
		var _item   = _slot.equipped;
		var _entity = getEntity();
		return (_slot.exCompare(_entity, _item, noitem) );
	}
	
	
	#region Utils
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
	
	/// @return {Struct.PartyStat}
	static getEntityStat    = function()
	{
		return (from.ref).getStat();
	}
	
	
	/// @desc Guardar datos del slot
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
			i = i + 1;
		}
		
		return (_save);
	}
	
	/// @desc Carga datos
	/// @param {Struct} loadStruct
	static load = function(_l)
	{
		if (_l.is != is) exit;
		vars = _l.vars;
		
		var i=0; repeat(array_length(keys) ) {
			var _key = keys[i]   ;
			var _con = _l[$ _key];
			
			get(_key).load(_con);
			
			i = i + 1;
		}
		
		// Actualizar
		update();
	}
	
	#endregion

	#endregion
}