/// @desc Defines the base template for a "slot" in an entity where items can be equipped.
/// @param {String} key
function MallSlot(_key) : MallBehavior(_key) constructor
{
	/// @desc How many items can be equipped in this slot.
	/// @type {Real}
	max_items = 1;
	
	/// @desc Whether the slot is disabled by default.
	/// @type {Bool}
	is_disabled = false;
	
	/// @desc Whether the slot is damaged (can have negative effects).
	/// @type {Bool}
	is_damaged = false;
	
	/// @desc The key of another slot it depends on to be active.
	/// @type {String}
	depends_on_slot = "";
	
	/// @desc A struct with the keys of permitted items/types. If empty, all are accepted.
	/// @type {Struct}
	permitted = {};
	
	#region EVENTS
	/// @desc Runs once when the slot instance is created for an entity.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	event_on_start = "";
	
	/// @desc (Not currently implemented by the engine.)
	event_on_end = "";
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	event_on_update = "";
	
	// Turn events.
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	event_on_turn_update = "";
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	event_on_turn_start = "";
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	event_on_turn_end = "";
	
	// Equipment events.
	
	/// @desc Runs after an item has been successfully equipped in this slot.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallItem} item_template The item that was equipped.
	event_on_equip = "";
	
	/// @desc Runs after an item has been successfully unequipped from this slot.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallItem} item_template The item that was unequipped.
	event_on_desequip = "";

	/// @desc Validates whether an item can be equipped. Must return a boolean.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallItem} item_template The item to check.
	/// @returns {Bool}
	event_can_equip = "";
	
	/// @desc Validates whether the current item can be unequipped. Must return a boolean.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallItem} item_template The item to check.
	/// @returns {Bool}
	event_can_desequip = "";
	
	// Attack events.
	
	/// @desc Runs when the entity attacks.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallEntity} target The attack target.
	event_on_attack = "";
	
	/// @desc Runs when the entity is attacked.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallEntity} attacker The attacker.
	event_on_defend = "";

	#endregion

	#region PRIVATE

	/// @ignore
	/// @desc Helper method to populate the list of permitted items.
	/// @param {String|Array} data The key or array of keys to add.
	static __PopulatePermitted = function(_data)
	{
		if (is_array(_data) )
		{
			var i=0; repeat(array_length(_data) ) { __PopulatePermitted( _data[i++] ); }
		}
		else if (is_string(_data) )
		{
			if (mall_exists_type(_data) )
			{
				var _type_items = mall_get_type(_data);
				var i=0; repeat(array_length(_type_items) ) { permitted[$ _type_items[i++] ] = 0; }
			}
			else
			{
				permitted[$ _data] = 0;
			}
		}
	}
	
	/// @ignore
	/// @desc Loads event strings to be used later.
	/// @param {Struct} data The struct containing the slot data.
	static __LoadFunctions = function(_data)
	{
		event_on_start =        _data[$ "event_on_start"]    ?? "";
		event_on_end =          _data[$ "event_on_end"]      ?? "";
		event_on_update =       _data[$ "event_on_update"]   ?? "";
		event_on_turn_update =  _data[$ "event_on_turn_update"] ?? "";
		event_on_turn_start =   _data[$ "event_on_turn_start"]  ?? "";
		event_on_turn_end =     _data[$ "event_on_turn_end"]    ?? "";
		event_on_equip =        _data[$ "event_on_equip"]      ?? "";
		event_on_desequip =     _data[$ "event_on_desequip"]    ?? "";
		event_can_equip =       _data[$ "event_can_equip"]    ?? "";
		event_can_desequip =    _data[$ "event_can_desequip"]  ?? "";
		event_on_attack =       _data[$ "event_on_attack"]      ?? "";
		event_on_defend =       _data[$ "event_on_defend"]      ?? "";
	}
	
	#endregion
	
	#region API
	
	/// @desc Configures the slot from a data struct.
	/// @param {Struct} data The struct containing the slot data.
	/// @returns {Struct.MallSlot}
	static FromData = function(_data)
	{
		max_items =         _data[$ "max_items"]        ?? 1;
		is_disabled =       _data[$ "is_disabled"]      ?? false;
		is_damaged =        _data[$ "is_damaged"]       ?? false;
		depends_on_slot =   _data[$ "depends_on_slot"]  ?? "";
		
		// Load permitted item/type keys.
		if (struct_exists(_data, "permitted") ) { __PopulatePermitted(_data[$ "permitted"]); }
		
		// Load event keys.
		__LoadFunctions(_data);
		
		return self;
	}
	
	#endregion
}