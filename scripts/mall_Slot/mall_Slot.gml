/// @desc Defines the base template for a "slot" in an entity where items can be equipped.
/// @param {String} key
function MallSlot(_key) : MallBehavior(_key) constructor
{
	/// @type {Real} How many items can be equipped in this slot.
	max_items = 1;
	
	/// @type {Bool} Whether the slot is disabled by default.
	is_disabled = false;
	
	/// @type {Bool} Whether the slot is damaged (can have negative effects).
	is_damaged = false;
	
	/// @type {String|Array<String>} The key of another slot it depends on to be active.
	depends_on_slot = "";
	
	/// @type {Struct} A struct with the keys of permitted items/types. If empty, all are accepted.
	permitted = {};
	
	#region EVENTS
	// Template Events works as an global even for every instance of the template.
	// so the context is the template itself and it receive the instance as parameter.

	/// @desc Runs on every start of something that use it.
	/// @context Struct.MallSlot
	/// @param {Struct.MallEntity} entity The entity that is calling the event.
	/// @param {Struct.MallSlotInstance} slot_instance The slot instance of this template.
	// event_on_start
	
	/// @desc Runs on every end of something that use it.
	/// @context Struct.MallSlot
	/// @param {Struct.MallEntity} entity The entity that is calling the event.
	/// @param {Struct.MallSlotInstance} slot_instance The slot instance of this template.
	// event_on_end
	
	/// @desc Runs on every callback that update something.
	/// @context Struct.MallSlot
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot instance being updated.
	// event_on_update
	
	/// @desc Runs on each turn update of the 'MallBattleManager'.
	/// @context Struct.MallSlot
	/// @param {Struct.MallEntity} entity The owning entity.
	// event_on_turn_update
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallSlot
	/// @param {Struct.MallEntity} entity The owning entity.
	// event_on_turn_start
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallSlot
	/// @param {Struct.MallEntity} entity The owning entity.
	// event_on_turn_end
	
	// Equipment events.
	
	/// @desc Runs after an item has been successfully equipped in this slot.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallItem} item_template The item that was equipped.
	// event_on_equip
	
	/// @desc Runs after an item has been successfully unequipped from this slot.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallItem} item_template The item that was unequipped.
	// event_on_desequip

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
	
	/// @desc Runs when the entity attacks.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallEntity} target The attack target.
	event_on_attack = "";
	
	/// @desc Runs when the entity is attacked.
	/// @context Struct.MallSlotInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallEntity} attacker The attacker.
	event_on_defense = "";

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
	static __LoadEvents = function(_data)
	{
		method(self, MallBehavior.__LoadEvents) (_data);
		
		event_can_equip =		variable_get_hash(_data[$ "event_can_equip"]		?? "");
		event_can_desequip =	variable_get_hash(_data[$ "event_can_desequip"] 	?? "");
		event_on_attack =		variable_get_hash(_data[$ "event_on_attack"]		?? "");
		event_on_defense =		variable_get_hash(_data[$ "event_on_defense"]		?? "");

		return self;
	}
	
	#endregion
	
	#region API
	
	/// @desc Exports the slot data to a struct, typically for saving or database storage.
	/// @returns {Struct} Struct with the slot data.
	static Export = function()
	{
		var _this = self;
		with(method(self, MallBehavior.Export)())
		{
			// Core properties.
			max_items =			_this.max_items;
			is_disabled =		_this.is_disabled;
			is_damaged =		_this.is_damaged;
			depends_on_slot =	_this.depends_on_slot;
			
			// Permitted items/types.
			permitted = variable_clone(_this.permitted);
			
			// Events
			event_can_equip =		_this.event_can_equip;
			event_can_desequip =	_this.event_can_desequip;
			event_on_attack =		_this.event_on_attack;
			event_on_defense =		_this.event_on_defense;

			return self;
		}
	}
	
	/// @desc Configures the slot from a data struct.
	/// @param {Struct} data The struct containing the slot data.
	static Import = function(_data)
	{
		// Parent configuration.
		method(self, MallBehavior.Import) (_data);

		max_items =         _data[$ "max_items"]        ?? max_items;
		is_disabled =       _data[$ "is_disabled"]      ?? is_disabled;
		is_damaged =        _data[$ "is_damaged"]       ?? is_damaged;
		depends_on_slot =   _data[$ "depends_on_slot"]  ?? depends_on_slot;
		
		// Load permitted item/type keys.
		if (struct_exists(_data, "permitted") ) { __PopulatePermitted(_data[$ "permitted"]); }
		
		return self;
	}
	
	#endregion
}