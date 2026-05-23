/// @desc Represents an equipment slot instance owned by an entity.
/// @param {String} key The key of the slot template this instance references.
/// @param {Struct.MallEntity} parent_entity Entity that owns this instance.
function MallSlotInstance(_key, _entity) : MallSlot(_key) constructor
{
	/// @ignore 
	__cache = { instance: {}, template: {}, item: {} };

	/// @type {Struct.WeakRef<Struct.MallEntity>} The entity this effect instance is attached to.
	owner = weak_ref_create(_entity);
	
	/// @type {Array<String>} Currently equipped item keys.
	equipped_items = [];
	
	/// @type {Array<String>} Snapshot of equipped item keys before the latest change.
	last_equipped_items = [];

	#region EVENTS
	
	/// @desc Runs once when the instance is created for an entity.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Current instance.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_start
	
	/// @desc Runs when the instance is destroyed.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Current instance.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_end
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Current instance.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_update
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Current instance.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_turn_update
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Current instance.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_turn_start
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Current instance.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_turn_end
	
	/// @desc Runs after an item has been successfully equipped in this slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot The slot where the item was equipped.
	/// @param {Struct.MallItem} item The item that was equipped.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_equip
	
	/// @desc Runs after an item has been successfully unequipped from this slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot The slot where the item was unequipped.
	/// @param {Struct.MallItem} item The item that was unequipped.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_desequip

	/// @desc Validates whether an item can be equipped. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot The slot where the item would be equipped.
	/// @param {Struct.MallItem} item The item to validate.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	/// @returns {Bool}
	// event_can_equip
	
	/// @desc Validates whether the current item can be unequipped. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot The slot from which the item would be unequipped.
	/// @param {Struct.MallItem} item The item to validate.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	/// @returns {Bool}
	// event_can_desequip
	
	/// @desc Runs when the entity attacks.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot The slot participating in the attack.
	/// @param {Struct.MallEntity} target The attack target.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_attack

	/// @desc Runs when the entity is attacked.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot The slot participating in the defense.
	/// @param {Struct.MallEntity} attacker The attacker.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	// event_on_defense

	#endregion

	#region PRIVATE API

	/// @ignore
	/// @desc Saves the current equipped items snapshot before mutating the slot.
	/// @returns {Array<String>} Snapshot of equipped items before the change.
	static __SnapshotEquippedItems = function()
	{
		last_equipped_items = variable_clone(equipped_items);
		return variable_clone(last_equipped_items);
	}

	/// @ignore
	/// @desc Validates whether an item can be equipped in this slot.
	/// @param {Struct.MallItem|Undefined} item_template Item template to validate.
	/// @param {String} item_key Item key to validate.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	/// @returns {Bool}
	static __CanEquipItem = function(_item_template, _item_key, _slot_template)
	{
		if (is_undefined(_item_template) ) return false;
		if (!struct_exists(permitted, _item_key) ) return false;
		if (array_length(equipped_items) >= max_items) return false;

		return OnCanEquip(_item_template, _slot_template);
	}

	/// @ignore
	/// @desc Validates whether an item can be unequipped from this slot.
	/// @param {Struct.MallItem|Undefined} item_template Item template to validate.
	/// @param {Real} item_index Index of the item inside equipped_items.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.
	/// @returns {Bool}
	static __CanDesequipItem = function(_item_template, _item_index, _slot_template)
	{
		if (is_undefined(_item_template) || _item_index == -1) return false;
		return OnCanDesequip(_item_template, _slot_template);
	}

	/// @desc If the event exists in the cache.
	/// @param {String} slot_event_key The slot event key to check.
	/// @param {String} item_event_key The item event key to check.
	/// @param {String} template_event_key The template event key to check.
	/// @returns {Bool}
	static __ExistsInCache = function(_key_instance, _key_item, _key_template)
	{
		return	struct_exists_from_hash(__cache.instance, _key_instance) && 
				struct_exists_from_hash(__cache.template, _key_template) &&
				struct_exists_from_hash(__cache.item, _key_item);
	}

	#endregion

	#region PUBLIC API

	/// @desc Validates whether the current item can be equipped. Must return bool.
	/// @param {Struct.MallItem} item The item to validate.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.	
	static OnCanEquip = function(_item_template, _slot_template)
	{
		if (!weak_ref_alive(owner) ) return false;

		if (__ExistsInCache(event_can_equip, _item_template.event_can_equip, _slot_template.event_can_equip) )
		{
			var _slot_event = struct_get_from_hash(__cache.instance, event_can_equip);
			var _item_event = struct_get_from_hash(__cache.item, _item_template.event_can_equip);
			var _template_event = struct_get_from_hash(__cache.template, _slot_template.event_can_equip);
		}
		else
		{
			// Trigger the slot event.
			var _slot_event = method(owner.ref, mall_get_event_check_true(event_can_equip) );
			struct_set_from_hash(__cache.instance, event_can_equip, _slot_event);

			// Trigger the item event.
			var _item_event = method(_item_template, mall_get_event_check_true(_item_template.event_can_equip) );
			struct_set_from_hash(__cache.item, _item_template.event_can_equip, _item_event);

			// Trigger the template event.
			var _template_event = method(self, mall_get_event_check_true(_slot_template.event_can_equip) );
			struct_set_from_hash(__cache.template, _slot_template.event_can_equip, _template_event);
		}

		var _can_equip_slot = _slot_event(self, _item_template, _slot_template);
		var _can_equip_item = _item_event(owner.ref, self);
		var _can_equip_template = _template_event(owner.ref, _item_template);

		return (_can_equip_slot && _can_equip_item && _can_equip_template);
	}

	/// @desc Validates whether the current item can be equipped. Must return bool.
	/// @param {Struct.MallItem} item The item to validate.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.	
	static OnCanDesequip = function(_item_template, _slot_template)
	{
		if (!weak_ref_alive(owner) ) return false;
		
		if (__ExistsInCache(event_can_desequip, _item_template.event_can_desequip, _slot_template.event_can_desequip) )
		{
			var _slot_event = struct_get_from_hash(__cache.instance, event_can_desequip);
			var _item_event = struct_get_from_hash(__cache.item, _item_template.event_can_desequip);
			var _template_event = struct_get_from_hash(__cache.template, _slot_template.event_can_desequip);
		}
		else
		{
			// Trigger the slot event.
			var _slot_event = method(owner.ref, mall_get_event_check_true(event_can_desequip) );
			struct_set_from_hash(__cache.instance, event_can_desequip, _slot_event);

			// Trigger the item event.
			var _item_event = method(_item_template, mall_get_event_check_true(_item_template.event_can_desequip) );
			struct_set_from_hash(__cache.item, _item_template.event_can_desequip, _item_event);

			// Trigger the template event.
			var _template_event = method(self, mall_get_event_check_true(_slot_template.event_can_desequip) );
			struct_set_from_hash(__cache.template, _slot_template.event_can_desequip, _template_event);
		}

		var _can_desequip_slot = _slot_event(self, _item_template, _slot_template);
		var _can_desequip_item = _item_event(owner.ref, self);
		var _can_desequip_template = _template_event(owner.ref, _item_template);

		return (_can_desequip_slot && _can_desequip_item && _can_desequip_template);
	}

	/// @desc Runs after an item has been successfully equipped in this slot.
	/// @param {Struct.MallItem} item The item that was equipped.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.	
	static OnEquip = function(_item_template, _slot_template)
	{
		if (!weak_ref_alive(owner) ) return;

		if (__ExistsInCache(event_on_equip, _item_template.event_on_equip, _slot_template.event_on_equip) )
		{
			var _slot_event = struct_get_from_hash(__cache.instance, event_on_equip);
			var _item_event = struct_get_from_hash(__cache.item, _item_template.event_on_equip);
			var _template_event = struct_get_from_hash(__cache.template, _slot_template.event_on_equip);
		}
		else
		{
			// Trigger the slot event.
			var _slot_event = method(owner.ref, mall_get_event(event_on_equip) );
			struct_set_from_hash(__cache.instance, event_on_equip, _slot_event);

			// Trigger the item event.
			var _item_event = method(_item_template, mall_get_event(_item_template.event_on_equip) );
			struct_set_from_hash(__cache.item, _item_template.event_on_equip, _item_event);

			// Trigger the template event.
			var _template_event = method(self, mall_get_event(_slot_template.event_on_equip) );
			struct_set_from_hash(__cache.template, _slot_template.event_on_equip, _template_event);
		}

		// Call the events.
		
		// Slot Event
		_slot_event(self, _item_template, _slot_template);
		// Item Event
		_item_event(owner.ref, self);
		// Template Event
		_template_event(owner.ref, _item_template);
	}

	/// @desc Runs after an item has been successfully equipped in this slot.
	/// @param {Struct.MallItem} item The item that was equipped.
	/// @param {Struct.MallSlot} slot_template The slot template this instance references.	
	static OnDesequip = function(_item_template, _slot_template)
	{
		if (!weak_ref_alive(owner) ) return;

		if (__ExistsInCache(event_on_desequip, _item_template.event_on_desequip, _slot_template.event_on_desequip) )
		{
			var _slot_event = struct_get_from_hash(__cache.instance, event_on_desequip);
			var _item_event = struct_get_from_hash(__cache.item, _item_template.event_on_desequip);
			var _template_event = struct_get_from_hash(__cache.template, _slot_template.event_on_desequip);
		}
		else
		{
			// Trigger the slot event.
			var _slot_event = method(owner.ref, mall_get_event(event_on_desequip) );
			struct_set_from_hash(__cache.instance, event_on_desequip, _slot_event);

			// Trigger the item event.
			var _item_event = method(_item_template, mall_get_event(_item_template.event_on_desequip) );
			struct_set_from_hash(__cache.item, _item_template.event_on_desequip, _item_event);

			// Trigger the template event.
			var _template_event = method(self, mall_get_event(_slot_template.event_on_desequip) );
			struct_set_from_hash(__cache.template, _slot_template.event_on_desequip, _template_event);
		}

		// Call the events.
		
		// Slot Event
		_slot_event(self, _item_template, _slot_template);
		// Item Event
		_item_event(owner.ref, self);
		// Template Event
		_template_event(owner.ref, _item_template);
	}

	/// @desc Attempts to equip an item in this slot. Return a 'MallResult' with a custom var 'item'.
	/// @param {String} item_key Item key to equip.
	/// @returns {Struct.MallResult}
	static Equip = function(_item_key)
	{
		/// @ignore
		static __hash = variable_get_hash("item");
		// Make the result struct.
		var _result = new MallResult().SetVar(__hash, undefined);

		/// @type {Struct.MallItem|Undefined}
		var _item_to_equip = mall_get_item(_item_key);
		var _slot_template = mall_get_slot(key);
		
		if (__CanEquipItem(_item_to_equip, _item_key, _slot_template) )
		{
			// Preserve the previous state before applying the new equipment change.
			_result.SetVar(__hash, __SnapshotEquippedItems() );
			array_push(equipped_items, _item_key);
			
			// Trigger equipment events after the item becomes active in the slot.
			OnEquip(_item_to_equip, _slot_template);

			_result.success = true;
		}
		
		return _result;
	}
	
	/// @desc Attempts to unequip a specific item from this slot. Return a 'MallResult' with a custom var 'item'.
	/// @param {String} item_key Item key to unequip.
	/// @returns {Struct.MallResult}
	static Desequip = function(_item_key)
	{
		/// @ignore
		static __hash = variable_get_hash("item");
		// Make the result struct.
		var _result = new MallResult();

		/// @type {Struct.MallItem|Undefined}
		var _item_to_remove = mall_get_item(_item_key);
		var _item_index = array_get_index(equipped_items, _item_key);
		var _slot_template = mall_get_slot(key);

		if (__CanDesequipItem(_item_to_remove, _item_index, _slot_template) )
		{
			// Preserve the previous state before removing the item.
			_result.SetVar(__hash, _item_key);
			
			// Trigger unequip events before the item is removed from the slot list.
			OnDesequip(_item_to_remove, _slot_template);

			__SnapshotEquippedItems();
			array_delete(equipped_items, _item_index, 1);
			
			_result.success = true;
		}
		
		return _result;
	}

	/// @desc Exports the current slot instance state.
	/// @returns {Struct}
	static Export = function()
	{
		with (method(self, MallSlot.Export) () )
		{
			// Do not copy owner never.
			equipped_items =		variable_clone(equipped_items);
			last_equipped_items =	variable_clone(last_equipped_items);

			return self;
		}
	}
	
	/// @desc Imports the slot instance state.
	/// @param {Struct} data State data to import.
	static Import = function(_data)
	{
		method(self, MallSlot.Import) (_data);
		
		equipped_items =		variable_clone(_data[$ "equipped_items"] ?? []);
		last_equipped_items =	variable_clone(_data[$ "last_equipped_items"] ?? []);
	}

	#endregion
}