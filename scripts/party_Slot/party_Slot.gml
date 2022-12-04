/// @param {Struct.PartyEntity}	party_entity
function PartySlot(_entity=other) : Mall() constructor 
{	
	from = weak_ref_create(_entity);		// Crear referencia a la entidad
	keys = [];

	array_foreach(mall_get_slot_keys(), function(_key)  {
		var _component = mall_get_slot(_key);
		variable_struct_set(self, _key, new createAtom(_component) );
		array_push(keys, _key);
		if (MALL_TRACE_PARTY) {show_debug_message("MallRPG Party (prSlot): {0} creado", _key); }
	});
	
	#region METHODS
	
	static createAtom = function(_slot) constructor {
		/// @ignore
		is = instanceof(self);

		key = _slot.key;
		displayKey = _slot.displayKey;
	
		items  = {};
		active = true;	// Si se puede usar
	
		equipped = undefined; // Donde se almacenan los objetos que lleva
		previous = undefined; // Objeto anterior que se llevo
		desequip = false; // Si fue desequipado anteriormente
	
		eventCompare = _slot.eventCompare;
	
		#region METHODS
		static send = function()
		{
			return {
				key: other.key,
				active: other.active,
			
				equipped: other.equipped,
				previous: other.equipped,
			};
		}
	
	
		static save = function() 
		{
			var _this = self;
			var _tosave = {};
			with (_tosave) {
				equipped = (!is_undefined(_this.equipped) ) ? _this.equipped.key : undefined;
				previous = (!is_undefined(_this.previous) ) ? _this.previous.key : undefined;
			}
		
			return (_tosave);
		}
	
	
	
		static load = function(_toload)
		{
			equipped = (!is_ptr(_toload.equipped) ) ? pocket_data_get(_toload.equipped) : undefined;
			previous = (!is_ptr(_toload.previous) ) ? pocket_data_get(_toload.previous) : undefined;
		}
	
		#endregion		
	}
	
	
	/// @param {String} equipment_key
	static get = function(_key) 
	{
        return (self[$ _key] );
    } 
	
	
	/// @param {String} equipment_key
	/// @param {String} item_key Puede ser un itemtype
	static setPermited = function(_key, _item_key)
	{
		var _equipment = get(_key);
		// Si se paso un tipo
		if (variable_struct_exists(global.__mallPocketTypes, _item_key) )
		{
			// Permitir a todos los objetos
			_equipment.items = global.__mallPocketTypes[$ _item_key];
		}
		else
		{
			// Si existe el objeto
			if (variable_struct_exists(global.__mallPocketData, _item_key) )
			{
				_equipment.items[$ _item_key] = _item_key;
			}
		}
		
		return self;
	}
	
	
	/// @param {String} equipment_key
	/// @param {String} itemtype_key
	static removePermited = function(_key, _item_key)
	{
		var _equipment = get(_key);
		variable_struct_remove(_equipment, _item_key);
		return self;
	}
	
	
	/// @desc Si se logra equipar devuelve un struct
	/// @param {String} equipment_key
	/// @param {String} item_key
	static equip = function(_key, _item_key) 
	{
		// Feather ignore all
		var _ret = {can: false, prev: undefined};
		var _equipment = get(_key);
		// Errors
		if (is_undefined(_equipment) ) {
			__mall_trace("Equipment equip: No existe llave");
			return _ret;
		}
		// Obtener datos de este objeto
		var _item = pocket_data_get(_item_key);
		
		// Si puede equipar este objeto
		if (variable_struct_exists(_equipment.items, _item.key) )
		{
			// Equipar objeto y actualizar el previo
			_equipment.previous = _equipment.equipped;
			_equipment.equipped = _item;
				
			// Actualiza todas las estadisticas que este objeto afecta
			var _skeys = variable_struct_get_names(_item.stats);
			if (!weak_ref_alive(from) ) exit;
			
			var _stats = from.ref.getStats();
			var i=0; repeat(array_length(_skeys) )
			{
				var _stat = _skeys[i];
				_stats.updateEquipment(_stat);
				i = i + 1;
			}
			
			// Si pudo equipar algo
			_ret.can  = true;
			_ret.prev = _equipment.previous;
			
			return _ret;
		}
		
		return _ret;
    } 
	
	
	/// @param {String} equipment_key
	static desequip = function(_key) 
	{
		static noitem = new PocketItem("");
		var _ret = {can: false, prev: undefined};
		var _equipment = get(_key);
		
		if (is_undefined(_equipment) ) {
			__mall_error("Equipment desequip: No existe llave"); 
			return _ret; 
		}
		
		var _item = _equipment.equipped ?? noitem;
		/*// No procesar
		if (is_undefined(_item) ) {
			_ret.can = true;
			__mall_trace("Equipment desequip: No objeto es indefinido");
			return _ret; 
		}*/
		
		_equipment.previous = _equipment.equipped;
		_equipment.equipped = undefined;
		_equipment.desequip = true; // Marcar que se esta desequipando algo
		
		#region Actualizar estadisticas
		var _skeys = variable_struct_get_names(_item.stats);
		if (!weak_ref_alive(from) ) exit;
			
		var _stats = from.ref.getStats();
		var i=0; repeat(array_length(_skeys) )
		{
			var _stat = _skeys[i];
			_stats.updateEquipment(_stat);
			i = i + 1;
		}
		
		// Sacar marca
		_equipment.desequip = false;
		
		#endregion
		
		_ret.can  = true;
		_ret.prev = _equipment.previous;
		return (_ret);		
    } 
	
	
	static update = function() 
	{
		var _keys = mall_get_stat_keys();
		var _stats = from.ref.getStats();
		var i = 0; repeat(array_length(_keys) ) {
			var _key = _keys[i];
			_stats.updateEquipment(_key);
			i = i + 1;
		}
		
		return self;
	}
	
	/// @param {String} item_key
	/// @returns {Bool}
	static isEquipped = function(_KEY) 
	{
		var _item = get(_KEY).equipped;
        return (_item.key == _KEY);
    }
	
	
	/// @param {String} equipment_key
	/// @param {String} item_key
	/// @returns {Struct}
	/// Compara las estadisticas del objeto actual con otro objeto obteniendo la diferencia en estadisticas
	static compareItem = function(_key, _item_key) 
	{
		if (!weak_ref_alive(from) ) exit;
		var _equipment = get(_key);
		var _equipped = _equipment.equipped;
		var _compare  = pocket_data_get(_item_key);

		var _stats = from.ref.getStats();
		return (_equipment.eventCompare(_stats, _equipment, _compare) );
	}
	
	
	/// @desc Regresa las estadisticas sin este objeto equipado.
	/// @param {String} equipment_key
	/// @returns {Struct}
	static compareNoItem = function(_key) 
	{
		static noitem = new PocketItem("");
		if (!weak_ref_alive(from) ) exit;
		var _equipment = get(_key);
		var _stats = from.ref.getStats();
		return (_equipment.eventCompare(_stats, noitem, noitem) );
	}
	
	
	static save = function() 
	{
		var _this = self;
		var _tosave = {flags: _this.flags};
		var i=0; repeat(array_length(keys) ) {
			var _key = keys[i];	
			_tosave[$ _key] = get(_key).save();
			i = i + 1;
		}
		
		return (_tosave);
	}
	
	
	
	static load = function(_toload)
	{
		flags = _toload.flags;
		var i=0; repeat(array_length(keys) ) {
			var _key = keys[i];
			var _loadEquip = _toload[$ _key];
			var _equip = get(_key);
			
			_equip.load(_loadEquip);
			i = i + 1;
		}
		
		update(); // Actualizar
	}
	
	

	#endregion
}