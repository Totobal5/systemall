/// @desc Represents an equipment slot instance owned by an entity.
/// @param {Struct.MallSlot} slot_template Slot template to instantiate.
/// @param {Struct.MallEntity} parent_entity Entity that owns this instance.
function MallSlotInstance(_template, _entity) constructor
{
	/// @desc MallSlot template referenced by this instance.
	/// @type {Struct.MallSlot}
	template = _template;
	
	/// @desc Entity that owns this slot instance.
	/// @type {Struct.MallEntity}
	parent_entity = _entity;
	
	/// @desc Maximum number of items this instance can equip.
	/// @type {Real}
	max_items = template.max_items;
	
	/// @desc Currently equipped item keys.
	/// @type {Array<String>}
	equipped_items = [];
	
	/// @desc Snapshot of equipped item keys before the latest change.
	/// @type {Array<String>}
	last_equipped_items = [];
	
	/// @desc Permitted item keys for this slot instance.
	/// @type {Struct}
	permitted = variable_clone(template.permitted);
	
	/// @desc Whether the slot is currently active.
	/// @type {Bool}
	is_active = !template.is_disabled;
	
	/// @desc Whether the slot is currently damaged.
	/// @type {Bool}
	is_damaged = template.is_damaged;

	/// @desc Key of another slot required for this slot to remain active.
	/// @type {String}
	depends_on_slot = template.depends_on_slot;

	#region EVENTS
	
	/// @desc Runs once when the instance is created for an entity.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance Current instance.
	event_on_start = method(parent_entity, mall_get_event( template[$ "event_on_start"] ) );
	
	/// @desc (Not currently implemented by the engine.)
	/// @returns {undefined}
	event_on_end = method(parent_entity, mall_get_event( template[$ "event_on_end"] ) );
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance Current instance.
	/// @returns {undefined}
	event_on_update = method(parent_entity, mall_get_event( template[$ "event_on_update"] ) );
	
	// Turn events.
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance Current instance.
	/// @returns {undefined}
	event_on_turn_update = method(parent_entity, mall_get_event( template[$ "event_on_turn_update"] ) );
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance Current instance.
	/// @returns {undefined}
	event_on_turn_start = method(parent_entity, mall_get_event( template[$ "event_on_turn_start"] ) );
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance Current instance.
	/// @returns {undefined}
	event_on_turn_end = method(parent_entity, mall_get_event( template[$ "event_on_turn_end"] ) );
	
	// Equipment events.
	
	/// @desc Runs after an item has been successfully equipped in this slot.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance The slot where the item was equipped.
	/// @param {Struct.MallItem} item_template The item that was equipped.
	/// @returns {undefined}
	event_on_equip = method(parent_entity, mall_get_event( template[$ "event_on_equip"] ) );
	
	/// @desc Runs after an item has been successfully unequipped from this slot.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance The slot where the item was unequipped.
	/// @param {Struct.MallItem} item_template The item that was unequipped.
	/// @returns {undefined}
	event_on_desequip = method(parent_entity, mall_get_event( template[$ "event_on_desequip"] ) );

	/// @desc Validates whether an item can be equipped. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance The slot where the item would be equipped.
	/// @param {Struct.MallItem} item_template The item to validate.
	/// @returns {Bool}
	event_can_equip = method(parent_entity, __mall_get_event_check_true( template[$ "event_can_equip"] ) );
	
	/// @desc Validates whether the current item can be unequipped. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance The slot from which the item would be unequipped.
	/// @param {Struct.MallItem} item_template The item to validate.
	/// @returns {Bool}
	event_can_desequip = method(parent_entity, __mall_get_event_check_true( template[$ "event_can_desequip"] ) );
	
	/// @desc Runs when the entity attacks.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance The slot participating in the attack.
	/// @param {Struct.MallEntity} target The attack target.
	/// @returns {undefined}
	event_on_attack = method(parent_entity, mall_get_event( template[$ "event_on_attack"] ) );

	/// @desc Runs when the entity is attacked.
	/// @context Struct.MallEntity
	/// @param {Struct.EntitySlotInstance} slot_instance The slot participating in the defense.
	/// @param {Struct.MallEntity} attacker The attacker.
	/// @returns {undefined}
	event_on_defend = method(parent_entity, mall_get_event( template[$ "event_on_defend"] ) );

	#endregion

	#region METHODS

	/// @desc Attempts to equip an item in this slot.
	/// @param {String} item_key Item key to equip.
	/// @returns {{success: Bool}}
	static Equip = function(_item_key)
	{
		var _result = { success: false };
		/// @type {Struct.MallItem|Undefined}
		var _item_to_equip = mall_get_item(_item_key);
		
		// Validate that the item exists, is permitted, and the slot still has capacity.
		if (is_undefined(_item_to_equip) || !struct_exists(permitted, _item_key) || array_length(equipped_items) >= template.max_items) 
		{
			return _result;
		}
		
		// Validate both slot and item-side rules before mutating state.
		var _can_equip_slot = event_can_equip(self, _item_to_equip);
		var _can_equip_item = _item_to_equip.event_can_equip(parent_entity, self);
		
		if (_can_equip_slot && _can_equip_item)
		{
			// Preserve the previous state before applying the new equipment change.
			last_equipped_items = variable_clone(equipped_items);
			array_push(equipped_items, _item_key);
			
			// Trigger equipment events after the item becomes active in the slot.
			event_on_equip(self, _item_to_equip);
			_item_to_equip.event_on_equip(parent_entity, self);
			
			_result.success = true;
		}
		
		return _result;
	}
	
	/// @desc Attempts to unequip a specific item from this slot.
	/// @param {String} item_key Item key to unequip.
	/// @returns {{success: Bool, unequipped_item: String|undefined}}
	static Desequip = function(_item_key)
	{
		var _result = { success: false, unequipped_item: undefined };
		/// @type {Struct.MallItem|Undefined}
		var _item_to_remove = mall_get_item(_item_key);
		var _item_index = array_get_index(equipped_items, _item_key);

		// Validate that the item exists and is currently equipped in this slot.
		if (is_undefined(_item_to_remove) || _item_index == -1)
		{
			return _result;
		}

		// Validate both slot and item-side rules before mutating state.
		var _can_desequip_slot = event_can_desequip(self, _item_to_remove);
		var _can_desequip_item = _item_to_remove.event_can_desequip(parent_entity, self);

		if (_can_desequip_slot && _can_desequip_item)
		{
			// Preserve the previous state before removing the item.
			_result.unequipped_item = _item_key;
			
			// Trigger unequip events before the item is removed from the slot list.
			event_on_desequip(self, _item_to_remove);
			_item_to_remove.event_on_desequip(parent_entity, self);
			
			last_equipped_items = variable_clone(equipped_items);
			array_delete(equipped_items, _item_index, 1);
			
			_result.success = true;
		}
		
		return _result;
	}

	/// @desc Exports the current slot instance state.
	/// @returns {{equipped_items: Array<String>, is_active: Bool}}
	static Export = function()
	{
		var _this = self;
		return {
			equipped_items:	_this.equipped_items,
			is_active:		_this.is_active
		};
	}
	
	/// @desc Imports the slot instance state.
	/// @param {{equipped_items: Array<String>, is_active: Bool}} data State data to import.
	/// @returns {undefined}
	static Import = function(_data)
	{
		equipped_items =	_data[$ "equipped_items"]	?? [];
		is_active =			_data[$ "is_active"]		?? !template.is_disabled;
	}

	#endregion
}
