/// @desc Represents a playable or non-playable entity in the system.
/// @param {String} template_key Template key used to build this entity.
/// @param {String} instance_id Unique ID for this entity instance.
function MallEntity(_template_key, _instance_id) : MallBehavior(_template_key) constructor
{
	/// @ignore Flag used to optimize batched state updates.
	__is_updating_all_states = false;
    
	// -- Identity --
	id = _instance_id;
	template_key = _template_key;
	group_key = "";
    
	// --- Combat properties ---
	exp_value = 0;
	loot_table_key = "";
	bonus_drops = [];
	// AI brain instance.
	ai_instance = undefined;
    // Entity faction.
	faction = "NEUTRAL";
    // Threat level.
	aggro = 0;
    // Commands learned on level milestones.
	learnset = [];
	
	// Custom variables outside the Mall core model.
	vars = {};
	
	// --- Instance state ---
	level =		1;
	stats =		{};
	slots =		{};
	states =	{};
	commands =	{};
	flags =		{};
	
	#region EVENTS
	
	/// @desc Runs at the end of LevelUp, after stats are recalculated.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat Stat instance that is leveling up.
	event_on_level_up = "";
	
	/// @desc Runs at the start of LevelUp to validate whether leveling is allowed. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Real} levels_to_add Number of levels requested.
	event_on_level_check = "";
	
	/// @desc Runs so AI can select an action. Must return a battle action struct.
	/// @context Struct.MallEntity
	/// @param {Struct} battle_context Battle context.
	event_on_action_select = "";

	/// @desc Runs after an item is equipped in any slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Affected slot instance.
	/// @param {Struct} result Equip operation result.
	event_on_equip = "";

	/// @desc Runs after an item is unequipped from any slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Affected slot instance.
	/// @param {Struct} result Unequip operation result.
	event_on_desequip = "";
	
	#endregion

	#region PRIVATE LOAD METHODS
	
	/// @ignore
	/// @desc Loads event functions from the template.
	static __LoadFunctions = function(_template)
	{
		event_on_level_up = method(self, mall_get_event(_template[$ "event_on_level_up"]) );
		event_on_level_check = method(self, __mall_get_event_check_true(_template[$ "event_on_level_check"] ) );
		
		event_on_action_select = method(self, mall_get_event(_template[$ "event_on_action_select"] ) );
		
		event_on_equip = method(self, mall_get_event(_template[$ "event_on_equip"] ) );
		event_on_desequip = method(self, mall_get_event(_template[$ "event_on_desequip"] ) );
	}
	
	/// @ignore
	/// @desc Loads stat instances and applies base values.
	/// @param {Struct} _template Entity template.
	static __LoadStats = function(_template)
	{
		var _all_stat_keys = mall_get_stat_keys();
		var _all_stat_length = array_length(_all_stat_keys);

		// Add every system stat to this entity.
		for (var i = 0; i < _all_stat_length; i++) 
		{
			var _stat_key = _all_stat_keys[i];
			var _stat_instance = new MallStatInstance(mall_get_stat(_stat_key), self);
			
			stats[$ _stat_key] = _stat_instance;
			
			// Run start event on initialization.
			var _start_event = _stat_instance.event_on_start;
			if (is_callable(_start_event) ) _start_event(_stat_instance);
		}
		
		// Load base values.
		if (struct_exists(_template, "stats") ) 
		{
			var _template_stats = _template[$ "stats"];
			var _template_stat_keys = struct_get_names(_template_stats);
			var _template_stat_length =	array_length(_template_stat_keys);
			
			for (var i = 0; i < _template_stat_length; i++) 
			{
				var _stat_key = _template_stat_keys[i];
				if (struct_exists(stats, _stat_key) ) 
				{
					var _stat_data = _template_stats[$ _stat_key];
					
					// Normalize numbers into the expected stat config struct.
					if (is_numeric(_stat_data) )
					{
						_stat_data = {
							base: _stat_data,
							growth: 0,
							curve: "linear"
						};
					}
					
					// Assign stat properties.
					stats[$ _stat_key].base_value = _stat_data.base;
					stats[$ _stat_key].growth = _stat_data.growth ?? 0;
					stats[$ _stat_key].curve_name = _stat_data.curve ?? "linear";
					
					// Resolve growth curve reference.
					if (mall_asset_exists(stats[$ _stat_key].curve_name) )
					{
						stats[$ _stat_key].growth_curve = mall_asset_get(stats[$ _stat_key].curve_name);
					}
					else
					{
						// Fallback to linear if the curve asset is missing.
						stats[$ _stat_key].growth_curve = mall_asset_get("linear");
						stats[$ _stat_key].curve_name = "linear";
					}
				}
			}
		}
	}
	
	/// @ignore
	/// @desc Loads slot instances, updates permitted items, and equips initial items.
	/// @param {Struct} _template Entity template.
	static __LoadSlots = function(_template)
	{
		var _all_slot_keys = mall_get_slot_keys();
		var _all_slot_length = array_length(_all_slot_keys);
		
		for (var i = 0; i < _all_slot_length; i++) 
		{
			var _slot_key = _all_slot_keys[i];
			var _slot_instance = new MallSlotInstance(mall_get_slot(_slot_key), self);
			
			slots[$ _slot_key] = _slot_instance;
			
			// Run start event on initialization.
			var _start_event = _slot_instance.event_on_start;
			if (is_callable(_start_event) ) _start_event(_slot_instance);			
		}
		
		if (struct_exists(_template, "slots") ) 
		{
			var _template_slots = _template[$ "slots"];
			var _template_slot_keys = struct_get_names(_template_slots);
			var _template_slot_keys_length = array_length(_template_slot_keys);
			
			for (var i = 0; i < _template_slot_keys_length; i++) 
			{
				var _slot_key = _template_slot_keys[i];
				var _slot_data = _template_slots[$ _slot_key];
				
				if (is_struct(_slot_data) ) 
				{
					// Configure permitted entries per slot instance.
					if (struct_exists(_slot_data, "permitted") )
					{
						var _permitted_mods = _slot_data[$ "permitted"];
						var _permitted_mods_length = array_length(_permitted_mods);
						
						for (var j = 0; j < _permitted_mods_length; j++)
						{
							// Read operation prefix from the last character.
							var _mod_string = _permitted_mods[j];
							var _mod_len = string_length(_mod_string);
							var _prefix = string_char_at(_mod_string, _mod_len);
							var _key = string_delete(_mod_string, _mod_len, 1);
							
							if (_prefix == "+")
							{ 
								SlotPermittedAdd(_slot_key, _key); 
							} 
							else if (_prefix == "-") 
							{ 
								SlotPermittedRemove(_slot_key, _key); 
							}
						}
					}
					
					// Configure initial equipment per slot instance.
					if (struct_exists(_slot_data, "equip") )
					{
						var _to_equip = _slot_data[$ "equip"];
						if (is_array(_to_equip) ) 
						{
							var j=0; repeat( array_length(_to_equip) ) SlotEquip( _slot_key, _to_equip[j++] );
						}
						else
						{ 
							SlotEquip(_slot_key, _to_equip); 
						}
					}
				}
				else 
				{
					SlotEquip(_slot_key, _slot_data);
				}
			}
		}
	}
	
	/// @desc Loads state instances.
	/// @param {Struct} _template Entity template.
	/// @ignore
	static __LoadStates = function(_template)
	{
		var _all_state_keys = mall_get_state_keys();
		var _all_state_length = array_length(_all_state_keys);
		
		for (var i = 0; i < _all_state_length; i++) 
		{
			var _state_key = _all_state_keys[i];
			var _state_inst = new MallStateInstance( mall_get_state(_state_key), self );
			
			states[$ _state_key] = _state_inst;
			
			// Run start event.
			if (is_callable(_state_inst.event_on_start) ) _state_inst.event_on_start(_state_inst);
		}
	}
	
	/// @desc Loads command categories from the entity template.
	/// @param {Struct} _template Entity template.
	/// @ignore
	static __LoadCommands = function(_template)
	{
		commands = new MallCommandsInstance();
		if (struct_exists(_template, "commands") ) 
		{
			var _categories = struct_get_names(_template[$ "commands"]);
			for (var i = 0; i < array_length(_categories); i++)
			{
				var _category_name = _categories[i];
				var _command_keys_array = _template[$ "commands"][$ _category_name];
				
				// Use the public API to add commands and ensure category creation.
				for (var j = 0; j < array_length(_command_keys_array); j++)
				{
					var _command_key = _command_keys_array[j];
					CommandAdd(_category_name, _command_key);
				}
			}
		}
	}

	/// @desc Loads AI instance.
	/// @param {Struct} _template Entity template.
	/// @ignore
	static __LoadAI = function(_template)
	{
		if (struct_exists(_template, "ai_package") )
		{
			ai_instance = new MallAIInstance(self, _template[$ "ai_package"]);
		}
	}
	
	/// @desc Calculates each stat base value (peak_value) from level.
	/// @ignore
	static __CalculatePeakValues = function()
	{
		var _stat_keys = struct_get_names(stats);
		for (var i = 0; i < array_length(_stat_keys); i++)
		{
			var _stat_inst = stats[$ _stat_keys[i]];
			_stat_inst.Recalculate(self);
		}
	}

	/// @ignore
	/// @desc Applies a value/percent modifier into a stat field.
	/// @param {Struct.MallStatInstance} _stat_to_mod Target stat.
	/// @param {Array} _mod_array Modifier payload [value, numtype].
	/// @param {String} _source_field Field name used as percent base.
	/// @param {String} _target_field Field name updated with the final value.
	static __mall_apply_mod = function(_stat_to_mod, _mod_array, _source_field, _target_field)
	{
		var _mod_value = _mod_array[0];
		var _mod_type = _mod_array[1];
		
		if (_mod_type == MALL_NUMTYPE.PERCENT)
		{
			_stat_to_mod[$ _target_field] += (_stat_to_mod[$ _source_field] * _mod_value) / 100;
		}
		else
		{
			_stat_to_mod[$ _target_field] += _mod_value;
		}
	}
	
	/// @desc Applies passive modifiers from states and effects.
	/// @ignore
	static __ApplyStateModifiers = function()
	{
		var _stat_keys = struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys)
		
		for (var i = 0; i < _stat_keys_length; i++) 
		{
			var _stat_inst = stats[$ _stat_keys[i]];
			_stat_inst.control_value = _stat_inst.equipment_value;
		}
		
		var _state_keys = struct_get_names(states);
		var _state_keys_length = array_length(_state_keys);
		
		for (var i = 0; i < _state_keys_length; i++) 
		{
			var _state_inst = states[$ _state_keys[i]];
			if (!_state_inst.boolean_value) continue;

			// Apply state-template modifiers.
			var _state_modifiers = _state_inst.stats;
			var _state_mod_keys = struct_get_names(_state_modifiers);
			var _state_mod_keys_length = array_length(_state_mod_keys);
			
			for (var j = 0; j < _state_mod_keys_length; j++) 
			{
				var _stat_key =  _state_mod_keys[j];
				var _mod_array = _state_modifiers[$ _stat_key];
				
				if (!struct_exists(stats, _stat_key) ) continue;
				
				var _stat_to_mod = stats[$ _stat_key];
				__mall_apply_mod(_stat_to_mod, _mod_array, "equipment_value", "control_value");
			}

			// Apply passive effect modifiers inside the state.
			var _effects_length = array_length(_state_inst.effects);
			for (var eff_idx = 0; eff_idx < _effects_length; eff_idx++) 
			{
				var _effect_inst = _state_inst.effects[eff_idx];
				var _effect_modifiers = _effect_inst.stats;
				var _effect_mod_keys = struct_get_names(_effect_modifiers);
				var _effect_mod_keys_length = array_length(_effect_mod_keys);
				
				for (var j = 0; j < _effect_mod_keys_length; j++) 
				{
					var _stat_key = _effect_mod_keys[j];
					var _mod_array = _effect_modifiers[$ _stat_key];
					
					if (_mod_array[2] == false && !struct_exists(stats, _stat_key) ) continue;
					
					// Process passive modifiers only ([value, numtype, true]).
					var _stat_to_mod = stats[$ _stat_key];
					__mall_apply_mod(_stat_to_mod, _mod_array, "equipment_value", "control_value");
				}
			}
		}
	}

	/// @desc Applies equipment modifiers.
	/// @ignore
	static __ApplyEquipmentModifiers = function()
	{
		var _stat_keys = struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys);
		
		for (var i = 0; i < _stat_keys_length; i++) 
		{
			var _stat_inst = stats[$ _stat_keys[i] ];
			_stat_inst.equipment_value = _stat_inst.peak_value;
		}
		
		var _slot_keys = struct_get_names(slots);
		var _slot_keys_length = array_length(_slot_keys);
		
		for (var i = 0; i < _slot_keys_length; i++) 
		{
			var _slot_inst = slots[$ _slot_keys[i]];
			if (!_slot_inst.is_active) continue;
			
			var _equipped_items_length = array_length(_slot_inst.equipped_items);
			for (var k = 0; k < _equipped_items_length; k++) 
			{
				var _item = mall_get_item(_slot_inst.equipped_items[k]);
				if (is_undefined(_item) || !struct_exists(_item, "stats") ) continue;
					
				var _item_stat_keys = struct_get_names(_item[$ "stats"]);
				var _item_stat_keys_length = array_length(_item_stat_keys);
					
				for (var j = 0; j < _item_stat_keys_length; j++) 
				{
					var _item_stat_key = _item_stat_keys[j];
					if (!struct_exists(stats, _item_stat_key) ) continue;

					var _stat_to_mod = stats[$ _item_stat_key];
					var _mod_array = _item.stats[$ _item_stat_key];
					__mall_apply_mod(_stat_to_mod, _mod_array, "peak_value", "equipment_value");
				}
			}
		}
	}
	
	/// @desc Finalizes stat calculations, applies clamps, and updates values.
	/// @ignore
	static __FinalizeStatValues = function()
	{
		var _stat_keys = struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys);
		
		for (var i = 0; i < _stat_keys_length; i++) 
		{
			var _stat_inst = stats[$ _stat_keys[i]];
			// Update tracked stat values.
			_stat_inst.last_peak_value =	_stat_inst.peak_value;
			_stat_inst.last_current_value = _stat_inst.current_value;
			_stat_inst.control_value =		__MALL_STAT_ROUNDING_METHOD(clamp(_stat_inst.control_value, _stat_inst.template.min_value, _stat_inst.template.max_value));
			_stat_inst.current_value =		min(_stat_inst.current_value, _stat_inst.control_value);
		}
	}
	
	/// @desc Dispatches an event to each component instance in a component struct.
	/// @ignore
	static __DispatchComponentEvent = function(_components, _event_name, _arg1 = undefined, _arg2 = undefined)
	{
		var _keys = struct_get_names(_components);
		var _keys_length = array_length(_keys);
		
		for (var i = 0; i < _keys_length; i++)
		{
			var _inst = _components[$ _keys[i]];
			var _event_func = _inst[$ _event_name];
			if (is_callable(_event_func)) 
			{
				_event_func(_inst, _arg1, _arg2);
			}
		}
	}
	
	/// @desc Dispatches an event to all equipped items.
	/// @ignore
	static __DispatchEquippedItemEvent = function(_event_name, _arg1 = undefined, _arg2 = undefined)
	{
		var _slot_keys = struct_get_names(slots);
		var _slot_keys_length = array_length(_slot_keys);
		
		for (var i = 0; i < _slot_keys_length; i++)
		{
			var _slot_inst = slots[$ _slot_keys[i]];
			var _equipped_items = _slot_inst.equipped_items;
			var _equipped_items_length = array_length(_equipped_items);
			
			for (var j = 0; j < _equipped_items_length; j++)
			{
				var _item_template = mall_get_item(_equipped_items[j]);
				if (is_undefined(_item_template)) continue;
				
				var _event_func = _item_template[$ _event_name];
				if (is_callable(_event_func)) _event_func(self, _arg1, _arg2);
			}
		}
	}

	/// @desc Notifies entity components after a slot equip/desequip operation.
	/// @ignore
	static __NotifySlotChange = function(_event_name, _slot_inst, _result)
	{
		__DispatchComponentEvent(stats, _event_name, _slot_inst);
		__DispatchComponentEvent(states, _event_name, _slot_inst);
		
		if (_event_name == "event_on_equip")
		{
			event_on_equip(_slot_inst, _result);
		}
		else
		{
			event_on_desequip(_slot_inst, _result);
		}
	}

	
	#endregion
	
	/// @desc Configures the entity from its template data.
	static FromTemplate = function()
	{
		var _template = __Systemall.__entities[$ template_key];
		if (is_undefined(_template) )
		{
			__mall_error($"Template '{template_key}' was not found.");
			exit;
		}
		
		// Load custom variables.
		if (variable_struct_exists(_template, "vars") ) {vars = variable_clone(_template.vars); }
		
		// Load event functions.
		__LoadFunctions(_template);
		
		// Load all components in order.
		__LoadStats(_template);
		__LoadSlots(_template);
		__LoadStates(_template);
		__LoadCommands(_template);
		__LoadAI(_template);
		
		// --- Load drops and experience ---
		exp_value =			_template[$ "exp_value"]		?? exp_value;
		loot_table_key =	_template[$ "loot_table_key"]	?? loot_table_key;
		faction =			_template[$ "faction"]			?? faction;
		learnset =			_template[$ "learnset"]			?? learnset;
		flags =				_template[$ "flags"]			?? flags;
		
		// Recalculate stats after all components and equipment are loaded.
		RecalculateStats();

		// Initialize current values at max after first calculation.
		var _stat_keys = struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys);
		
		for (var i = 0; i < _stat_keys_length; i++) 
		{
			var _stat_inst = stats[$ _stat_keys[i]];
			_stat_inst.current_value = _stat_inst.control_value;
		}
		
		return self;
	}
	
	/// @desc Recalculates all stats (used on level up and equip/unequip).
	static RecalculateStats = function()
	{
		__CalculatePeakValues();
		__ApplyEquipmentModifiers();
		__ApplyStateModifiers();
		__FinalizeStatValues();
		
		// Notify all components that stats were updated.
		__DispatchComponentEvent(stats, "event_on_update");
		__DispatchComponentEvent(slots, "event_on_update");
		__DispatchComponentEvent(states, "event_on_update");
		__DispatchEquippedItemEvent("event_on_update", self);
	}
	
	/// @desc Levels up the entity and recalculates stats.
	/// @param {Real} [levels_to_add]=1 Number of levels to add.
	static LevelUp = function(_levels_to_add = 1)
	{
		if (!event_on_level_check(_levels_to_add) ) exit; 
		
		var _old_level = level;
		level = clamp(level + _levels_to_add, __MALL_ENTITIES_LEVEL_MIN, __MALL_ENTITIES_LEVEL_MAX);
		
		// Check newly learned commands.
		var i=0; repeat(array_length(learnset) )
		{
			var _learn_data = learnset[i];
			// Learn if requirement is between old and new level.
			if (_learn_data.level > _old_level && _learn_data.level <= level) 
			{
				CommandAdd(_learn_data.category, _learn_data.command);
			}
			
			i++;	
		}
		
		// Recalculate stats.
		RecalculateStats();
		
		// Run level-up event.
		event_on_level_up();
	}
	
	#region STATS API
	
	/// @desc Gets a stat instance.
	/// @param {String} key Stat key (for example: "EN").
	/// @return {Struct.MallStatInstance}
	static StatGet = function(_key)
	{
		if (!mall_exists_stat(_key) ) 
		{
			__mall_error($"Stat '{_key}' does not exist.");
		}
		return (struct_get(stats, _key));
	}
	
	/// @desc Sets the current value of a stat.
	/// @param {String} key Stat key.
	/// @param {Real} value New value.
	/// @param {Enum.MALL_NUMTYPE} [numtype]=MALL_NUMTYPE.REAL
	/// @param {Enum.MALL_STAT_TARGET} [numtarget]=MALL_STAT_TARGET.CONTROL
	/// @return {Real} Current value after modification.
	static StatSet = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarget=MALL_STAT_TARGET.CONTROL)
	{
		var _stat = StatGet(_key);
		if (is_undefined(_stat) ) return 0;
		
		_stat.last_current_value = _stat.current_value;
		
		var _new_value = _value;
		if (_numtype == MALL_NUMTYPE.PERCENT) {
			_new_value = _stat.ReturnValueTarget(_numtarget) * _value / 100;
		}
		
		_stat.current_value = clamp(_new_value, _stat.template.min_value, _stat.control_value);
		return _stat.current_value;
	}
	
	/// @desc Adds (or subtracts) a value to a stat.
	/// @param {String} key Stat key.
	/// @param {Real} value Value to add (can be negative).
	/// @param {Enum.MALL_NUMTYPE} [numtype]=MALL_NUMTYPE.REAL
	/// @param {Enum.MALL_STAT_TARGET} [numtarget]=MALL_STAT_TARGET.CURRENT
	/// @return {Real} Actual delta applied to the value.
	static StatAdd = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarget = MALL_STAT_TARGET.CURRENT)
	{
		var _stat = StatGet(_key);
		if (is_undefined(_stat)) return 0;
		
		var _value_to_add = _value;
		if (_numtype == MALL_NUMTYPE.PERCENT) {
			var _base_for_percent = _stat.ReturnValueTarget(_numtarget);
			_value_to_add = (_base_for_percent * _value) / 100;
		}
		
		var _old_value = _stat.current_value;
		var _new_value = __MALL_STAT_ROUNDING_METHOD(_old_value + _value_to_add);
		
		StatSet(_key, _new_value);

		return (_stat.current_value - _old_value);
	}
	
	#endregion
	
	#region SLOTS API
	
	/// @desc Gets a slot instance.
	/// @param {String} key Slot key.
	/// @return {Struct.EntitySlotInstance}
	static SlotGet = function(_key)
	{
		if (!mall_exists_slot(_key) )
		{
			__mall_error($"Slot '{_key}' does not exist.");
		}		
		return (struct_get(slots, _key) );
	}
	
	/// @desc Adds permitted items/types for a slot.
	/// @param {String} slotKey Slot key.
	/// @param {String, Array} itemOrTypeKey Item or type key to add.
	static SlotPermittedAdd = function(_slotKey, _itemOrTypeKey)
	{
		var _slot = SlotGet(_slotKey);
		if (is_undefined(_slot)) return;
		
		if (mall_exists_type(_itemOrTypeKey) ) 
		{
			var _type_items = mall_get_type(_itemOrTypeKey);
			for (var i = 0; i < array_length(_type_items); i++)
			{
				_slot[$ "permitted"][$ _type_items[i]] = 0;
			}
		} 
		else 
		{
			_slot[$ "permitted"][$ _itemOrTypeKey] = 0;
		}
	}
	
	/// @desc Removes permitted items/types.
	/// @param {String} slotKey Slot key.
	/// @param {String, Array} itemOrTypeKey Item or type key to remove.
	static SlotPermittedRemove = function(_slotKey, _itemOrTypeKey)
	{
		var _slot = SlotGet(_slotKey);
		if (is_undefined(_slot)) return;
		
		if (mall_exists_type(_itemOrTypeKey) )
		{
			var _type_items = mall_get_type(_itemOrTypeKey);
			for (var i = 0; i < array_length(_type_items); i++)
			{
				struct_remove(_slot[$ "permitted"], _type_items[i]);
			}
		} 
		else 
		{
			struct_remove(_slot[$ "permitted"], _itemOrTypeKey);
		}
	}
	
	/// @desc Equips an item into a slot.
	/// @param {String} slot_key Slot key.
	/// @param {String} item_key Item key to equip.
	static SlotEquip = function(_slot_key, _item_key)
	{
		var _slot_inst = SlotGet(_slot_key);
		if (is_undefined(_slot_inst) ) return { success: false, previously_equipped: undefined };
		
		var _equip = _slot_inst[$ "Equip"];
		if (!is_callable(_equip)) return { success: false, previously_equipped: undefined };
		var _result = method(_slot_inst, _equip)(_item_key);
		if (_result.success)
		{ 
			RecalculateStats();
			__NotifySlotChange("event_on_equip", _slot_inst, _result);
		}
		
		return _result;
	}
	
	/// @desc Unequips an item from a slot.
	/// @param {String} slot_key Slot key.
	/// @param {String} item_key Item key to unequip.
	static SlotDesequip = function(_slot_key, _item_key)
	{
		var _slot_inst = SlotGet(_slot_key);
		if (is_undefined(_slot_inst)) return { success: false, unequipped_item: undefined };

		var _desequip = _slot_inst[$ "Desequip"];
		if (!is_callable(_desequip)) return { success: false, unequipped_item: undefined };
		var _result = method(_slot_inst, _desequip)(_item_key);
		if (_result.success) 
		{ 
			RecalculateStats();
			__NotifySlotChange("event_on_desequip", _slot_inst, _result);
		}
		
		return _result;
	}

	/// @desc Returns equipped item keys for a slot.
	/// @param {String} key Slot key.
	/// @return {Array<String>} Array of equipped item keys.
	static SlotGetEquipped = function(_key)
	{
		var _slot = SlotGet(_key);
		if (is_undefined(_slot)) return [];
		return (_slot[$ "equipped_items"]);
	}
	
	/// @desc Checks whether an item is permitted in a slot.
	/// @param {String} slot_key Slot key.
	/// @param {String} item_key Item key to check.
	/// @return {Bool}
	static SlotIsPermitted = function(_slot_key, _item_key)
	{
		var _slot = SlotGet(_slot_key);
		if (is_undefined(_slot)) return false;
		return (struct_exists(_slot[$ "permitted"], _item_key));
	}
	
	/// @desc Checks whether a slot has no equipped items.
	/// @param {String} key Slot key.
	/// @return {Bool}
	static SlotIsEmpty = function(_key)
	{
		var _slot = SlotGet(_key);
		if (is_undefined(_slot)) return true;
		return (array_length(_slot[$ "equipped_items"]) == 0);
	}

	/// @desc Runs a function for each entity slot.
	/// @param {Function} fn Function to execute. Receives (slot_instance, slot_key).
	static SlotForeach = function(_fn)
	{
		var _keys = struct_get_names(slots);
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];
			_fn(slots[$ _key], _key);
		}
	}
	
	#endregion

	#region STATES API
	/// @desc Gets a state instance.
	/// @param {String} key State key.
	/// @return {Struct.EntityStateInstance}
	static StateGet = function(_key)
	{
		if (!struct_exists(states, _key))
		{
			__mall_alert($"StateGet: state '{_key}' is not loaded on entity '{id}'.");
		}
		return states[$ _key];
	}
	
	/// @desc Checks whether a state is active on the entity (has at least one effect).
	/// @param {String} key State key.
	/// @return {Bool}
	static StateIsActive = function(_key)
	{
		var _state = StateGet(_key);
		if (is_undefined(_state) ) return false;
		
		return _state[$ "boolean_value"];
	}
	
	/// @desc Adds an effect to an entity state.
	/// @param {String} effect_key Effect template key to add.
	/// @return {Struct.MallEffectInstance} Created effect instance, or undefined on failure.
	static EffectAdd = function(_effect_key)
	{
		var _result = { added: undefined, success: false, leftover: undefined }
		// Resolve effect template, return early if missing.
		var _effect_template = mall_get_effect(_effect_key);
		if (is_undefined(_effect_template) )
		{
			__mall_alert($"EffectAdd: effect template '{_effect_key}' was not found.");
			return _result;
		}
		
		// Resolve target state instance, return early if missing.
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst) ) return _result;
		
		// Create effect instance and validate insertion.
		var _effect_instance = new MallEffectInstance(_effect_template);
		// Validate whether this effect can be added.
		var _can_add_effect = _state_inst[$ "event_can_add_effect"];
		if (is_callable(_can_add_effect) && !(method(_state_inst, _can_add_effect)(_state_inst, _effect_instance) ) ) 
		{
			// Return the non-added instance as leftover.
			_result.leftover = _effect_instance;
			return _result;
		}
		
		// Cache state template.
		var _state_template = _state_inst[$ "template"];
		
		// Check immunities and priority restrictions.
		var _state_keys = struct_get_names(states);
		var _state_keys_length = array_length(_state_keys);
		
		for (var i = 0; i < _state_keys_length; i++)
		{
			var _k = _state_keys[i];
			var _current_state_inst = states[$ _k];
			if (!_current_state_inst.boolean_value) continue;
			
			// Current active state prevents target state.
			if (array_contains(_current_state_inst.template.prevents_states, _state_key) ) return _result;
			
			// Check state priority.
			if (_current_state_inst.template.restricts_action && _state_template.priority < _current_state_inst.template.priority) return _result;
		}
		
		// Clear conflicting states.
		var _states_to_clear = _state_template.clears_states;
		var i=0; repeat(array_length(_states_to_clear) ) { StateRemoveAllEffects( _states_to_clear[i++] ); }
		
		// Add effect instance.
		array_push(_state_inst[$ "effects"], _effect_instance);
		
		// Toggle state on first applied effect.
		if (_state_inst[$ "boolean_value"] == _state_inst[$ "reset_value"]) 
		{
			_state_inst[$ "boolean_value"] = !_state_inst[$ "reset_value"];
			
			// Fire state start event when boolean flips.
			var _state_on_start = _state_inst[$ "event_on_start"];
			if (is_callable(_state_on_start) ) method(_state_inst, _state_on_start)(_state_inst, _effect_instance);
		}
	
		// Run add/start events.
		var _state_on_add_effect = _state_inst[$ "event_on_add_effect"];
		if (is_callable(_state_on_add_effect)) method(_state_inst, _state_on_add_effect)(_state_inst, _effect_instance);
		var _effect_on_start = _effect_instance[$ "event_on_start"];
		if (is_callable(_effect_on_start)) method(_effect_instance, _effect_on_start)(self, _state_inst);
		
		// Recalculate stats.
		RecalculateStats();
		
		// Update result payload.
		_result.added = _effect_instance;
		_result.success = true;
		
		return _result;
	}
	
	/// @desc Removes an effect instance from a state.
	/// @param {String} effect_key Effect template key.
	/// @param {Function} [filter] Optional function to select a specific effect. (_value, _index) with context (template: EffectTemplate).
	static EffectRemove = function(_effect_key, _filter)
	{
		static __default_filter = function(_value, _index) {
			return (_value.template.key == self[$ "template"][$ "key"]);
		}
		
		var _result = { removed: undefined, success: false }
		
		// Resolve effect template, return early if missing.
		var _effect_template = mall_get_effect(_effect_key);
		if (is_undefined(_effect_template) )
		{
			__mall_alert($"EffectRemove: effect template '{_effect_key}' was not found.");
			return _result;
		}
		
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst) ) return _result;

		// Find first matching effect and remove it.
		var _index = array_find_index(_state_inst[$ "effects"], method({ template: _effect_template }, _filter ?? __default_filter));
		var _effect_removed = undefined;
		
		if (_index > -1) _effect_removed = _state_inst[$ "effects"][_index];
		
		// Return if no effect matched.
		if (is_undefined(_effect_removed) ) return _result;
		
		// Validate remove policy.
		var _can_remove_effect = _state_inst[$ "event_can_remove_effect"];
		if (is_callable(_can_remove_effect) && !method(_state_inst, _can_remove_effect)(_state_inst, _effect_removed) ) 
		{
			return _result;
		}
		
		// Remove from state effect array.
		array_delete(_state_inst[$ "effects"], _index, 1);
			
		// Run remove/end events.
		var _state_on_remove_effect = _state_inst[$ "event_on_remove_effect"];
		if (is_callable(_state_on_remove_effect)) method(_state_inst, _state_on_remove_effect)(_state_inst, _effect_removed);
		var _effect_on_end = _effect_removed[$ "event_on_end"];
		if (is_callable(_effect_on_end)) method(_effect_removed, _effect_on_end)(self, _state_inst);
		
		// Deactivate state if there are no remaining effects.
		if (array_length(_state_inst[$ "effects"]) == 0)
		{
			_state_inst[$ "boolean_value"] = _state_inst[$ "reset_value"];
			var _state_on_end = _state_inst[$ "event_on_end"];
			if (is_callable(_state_on_end)) method(_state_inst, _state_on_end)(_state_inst);
		}
		
		// Recalculate stats.
		if (!__is_updating_all_states) RecalculateStats();
			
		// Save result payload.
		_result.removed = _effect_removed;
		_result.success = true;

		return _result;
	}
	
	/// @desc Removes all effects from a specific state.
	/// @param {String} key State key to clear.
	/// @param {Function} [filter] Optional function to select specific effects. (_value, _index) with context (template: EffectTemplate).
	static StateRemoveAllEffects = function(_key, _filter)
	{
		var _results = { };
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst[$ "boolean_value"]) return _results;
				
		// Optimization flag for batched updates.
		__is_updating_all_states = true;
		
		for (var i = array_length(_state_inst[$ "effects"]) - 1; i >= 0; i--)
		{
			var _effect_inst =	_state_inst[$ "effects"][i];
			var _effect_key =	_effect_inst.template.key;
			
			struct_set(_results, _effect_key+i, EffectRemove(_effect_key, _filter) );
		}
		
		__is_updating_all_states = false;
		
		// Recalculate all stats.
		RecalculateStats();
		
		return _results;
	}

	/// @desc Updates effects for a specific state based on turn timing.
	/// @param {String} key State key to update.
	/// @param {Enum.MALL_EFFECT_TURN} turn_type Turn timing (START or END).
	static EffectsUpdateByTurn = function(_key, _turn_type)
	{
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst[$ "boolean_value"]) return;

		// Optimization flag to defer stat recalculation.
		__is_updating_all_states = true;
		
		// Iterate backwards for safe in-loop removal.
		for (var i = array_length(_state_inst[$ "effects"]) - 1; i >= 0; i--) 
		{
			var _effect_inst = _state_inst[$ "effects"][i];
			var _template = _effect_inst.template;
			
			// Check whether the effect should execute at this turn moment.
			if (_template.turn_type != _turn_type && _template.turn_type != MALL_EFFECT_TURN.BOTH) continue;
			
			// Select the correct iterator.
			var _iterator = (_turn_type == MALL_EFFECT_TURN.START) ? _effect_inst.iterator_start : _effect_inst.iterator_end;
			var _tick_result = _iterator.Tick();
			
			switch (_tick_result)
			{
				case MALL_ITERATOR_STATE.WORKING:
				case MALL_ITERATOR_STATE.CYCLE_END:
					// Process active modifiers (affect current value).
					var _effect_modifiers = _template.stats;
					var _effect_mod_keys = variable_struct_get_names(_effect_modifiers);
					var _effect_mod_keys_length = array_length(_effect_mod_keys);
					
					for (var j = 0; j < _effect_mod_keys_length; j++) 
					{
						var _stat_key = _effect_mod_keys[j];
						var _mod_array = _effect_modifiers[$ _stat_key];
						
						// Process active modifiers only ([value, numtype, false]).
						if (_mod_array[2] == true) continue;
						
						var _base_value = _mod_array[0];
						var _base_type = _mod_array[1];
						var _value_to_apply;
						var _type_to_apply = _base_type;
							
						// Check custom calculation event.
						if (is_callable(_effect_inst.event_on_calculate) ) 
						{
							_value_to_apply = _effect_inst.event_on_calculate(self, _effect_inst, _base_value, _base_type);
							// Event returns already-calculated value.
							_type_to_apply = MALL_NUMTYPE.REAL;
						} 
						else 
						{
							_value_to_apply = _base_value;
						}
							
						StatAdd(_stat_key, _value_to_apply, _type_to_apply);
					}
					
					// Run turn event.
					var _event = (_turn_type == MALL_EFFECT_TURN.START) ? _effect_inst.event_on_turn_start : _effect_inst.event_on_turn_end;
					if (is_callable(_event) ) _event(self, _effect_inst);
					
					break;
				
				case MALL_ITERATOR_STATE.COMPLETED:
					// Mark effect for removal.
					with (_effect_inst) __to_remove = true;
				
					// Effect completed, remove it.
					EffectRemove(_template.key);
					
					break;
			}
		}
		
		// Re-enable regular recalculation flow.
		__is_updating_all_states = false;
		
		// Recalculate stats when not inside a batched update flow.
		if (!__is_updating_all_states) RecalculateStats();
	}

	
	/// @desc Updates all entity states based on turn timing.
	/// @param {Enum.MALL_EFFECT_TURN} turn_type Turn timing (START or END).
	static StateUpdateAll = function(_turn_type)
	{
		// Optimization flag.
		__is_updating_all_states = true;
		
		var _keys = variable_struct_get_names(states);
		var _keys_length = array_length(_keys);
		
		for (var i = 0; i < _keys_length; i++)
		{
			EffectsUpdateByTurn(_keys[i], _turn_type);
		}
		
		__is_updating_all_states = false;
		
		RecalculateStats();
	}
	
	#endregion

	#region COMMANDS API
	
	/// @desc Adds a command to a category.
	/// @param {String} category_key Category key to add into.
	/// @param {String} command_key Command key to add.
	/// @return {Bool} Returns true if added successfully.
	static CommandAdd = function(_category_key, _command_key)
	{
		if (!mall_exists_command(_command_key) )
		{
			__mall_alert($"CommandAdd: command '{_command_key}' is not registered in the database.");
			return false;
		}
		
		// Create category if missing.
		if (!struct_exists(commands[$ "commands"], _category_key) ) 
		{
			commands[$ "commands"][$ _category_key] = {};
			array_push(commands[$ "commands_key"], _category_key);
		}
		
		commands[$ "commands"][$ _category_key][$ _command_key] = true;
		return true;
	}
	
	/// @desc Removes a command from a category.
	/// @param {String} category_key Command category key.
	/// @param {String} command_key Command key to remove.
	/// @return {Bool} Returns true if removed.
	static CommandRemove = function(_category_key, _command_key)
	{
		if (struct_exists(commands[$ "commands"], _category_key) )
		{
			return struct_remove(commands[$ "commands"][$ _category_key], _command_key);
		}
		
		return false;
	}
	
	/// @desc Checks whether the entity has a command in a specific category.
	/// @param {String} category_key Category key to query.
	/// @param {String} command_key Command key.
	/// @return {Bool}
	static CommandExists = function(_category_key, _command_key)
	{
		if (struct_exists(commands[$ "commands"], _category_key) ) 
		{
			return struct_exists(commands[$ "commands"][$ _category_key], _command_key);
		}
		
		return false;
	}
	
	/// @desc Gets the command template if owned by the entity.
	/// @param {String} category_key Command category key.
	/// @param {String} command_key Command key.
	/// @return {Struct.MallCommand} La template del comando, o undefined.
	static CommandGet = function(_category_key, _command_key)
	{
		if (CommandExists(_category_key, _command_key) ) 
		{
			return mall_get_command(_command_key);
		}
		return undefined;
	}
	
	/// @desc Gets all command keys in a category.
	/// @param {String} category_key Category key.
	/// @return {Array<String>} Array with command keys.
	static CommandGetAll = function(_category_key)
	{
		if (struct_exists(commands[$ "commands"], _category_key) ) 
		{
			return struct_get_names(commands[$ "commands"][$ _category_key]);
		}
		
		return [];
	}
	
	/// @desc Gets a random command key from a category.
	/// @param {String} category_key Category key.
	/// @return {String} Random command key, or undefined.
	static CommandGetRandom = function(_category_key)
	{
		var _all_commands = CommandGetAll(_category_key);
		var _all_commands_length = array_length(_all_commands);
		if (_all_commands_length > 0) 
		{
			var _random_index = irandom(_all_commands_length - 1);
			return _all_commands[_random_index];
		}
		
		return undefined;
	}
	
	/// @desc Gets all command categories for the entity.
	/// @return {Array<String>}
	static CategoryGetAll = function()
	{
		return commands[$ "commands_key"];
	}
	
	#endregion

	#region MISC API
	/// @desc Calculates and returns experience and item drops when the entity is defeated.
	/// @return {Struct} Struct with format { exp: Real, items: Array<Struct> }.
	static GetDrops = function()
	{
		var _result = {
			exps: exp_value,
			items: []
		};
		
		var _all_drops = [];
		array_copy(_all_drops, 0, bonus_drops, 0, array_length(bonus_drops) );
		
		// Merge drops from loot table.
		var _loot_table = mall_get_loot_table(loot_table_key);
		if (!is_undefined(_loot_table) && variable_struct_exists(_loot_table, "items") ) 
		{
			var _table_items = _loot_table[$ "items"];
			array_copy(_all_drops, array_length(_all_drops), _table_items, 0, array_length(_table_items));
		}
		
		// Roll item drops.
		for (var i = 0; i < array_length(_all_drops); i++) 
		{
			var _drop_data = _all_drops[i];
			var _chance = _drop_data.chance ?? 100;
			
			if (random(100) < _chance)
			{
				var _quantity = 0;
				var _quantity_data = _drop_data.quantity ?? 1;
				
				if (is_array(_quantity_data) ) 
				{
					_quantity = irandom_range(_quantity_data[0], _quantity_data[1]);
				} 
				else 
				{
					_quantity = _quantity_data;
				}
				
				if (_quantity > 0)
				{
					array_push(_result.items, {
						key:		_drop_data.key,
						quantity:	_quantity
					});
				}
			}
		}
		
		return _result;
	}	

	/// @desc Adds a new runtime drop entry to the entity.
	/// @param {String} key Item key.
	/// @param {Real, Array} quantity Quantity (number or [min, max] array).
	/// @param {Real} [chance]=100 Drop chance (0-100).
	static AddDrop = function(_key, _quantity, _chance = 100)
	{
		array_push(bonus_drops, {
			key: _key,
			quantity: _quantity,
			chance: _chance
		});
		
		return self;
	}
	
	/// @desc Runs at turn start during battle.
	static OnTurnStart = function()
	{
		// Update states and effects that trigger at turn start.
		StateUpdateAll(MALL_EFFECT_TURN.START);
		
		// Notify all components.
		__DispatchComponentEvent(stats, "event_on_turn_start");
		__DispatchComponentEvent(slots, "event_on_turn_start");
		__DispatchEquippedItemEvent("event_on_turn_start", self);
	}

	/// @desc Runs at turn end during battle.
	static OnTurnEnd = function()
	{
		// Update states and effects that trigger at turn end.
		StateUpdateAll(MALL_EFFECT_TURN.END);
		
		// Notify all components.
		__DispatchComponentEvent(stats, "event_on_turn_end");
		__DispatchComponentEvent(slots, "event_on_turn_end");
		__DispatchEquippedItemEvent("event_on_turn_end", self);		
	}

	/// @desc Selects the action for this turn.
	/// @param {Struct} battle_context Battle context (allies, enemies).
	/// @return {Struct} Selected action.
	static SelectAction = function(_battle_context)
	{
		// Delegate decision-making to AI when available.
		if (!is_undefined(ai_instance) )
		{
			var _select_action = ai_instance[$ "SelectAction"];
			if (is_callable(_select_action)) return method(ai_instance, _select_action)(_battle_context);
			return undefined;
		}
	
		// Otherwise, caller may use player input or a default action.
		return undefined;
	}

	/// @desc Checks whether the entity can perform an action this turn.
	/// @return {Bool} Returns false if any active state restricts actions.
	static CanAct = function()
	{
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) 
		{
			var _state_inst = states[$ _state_keys[i]];
			
			// Active state prevents actions.
			if (_state_inst.boolean_value && _state_inst.template.restricts_action) 
			{
				return false;
			}
		}
		
		return true;
	}

	/// @desc Adds threat (aggro) to the entity.
	/// @param {Real} amount Threat amount to add.
	static AggroAdd = function(_amount)
	{
		aggro += _amount;
		return self;
	}
	
	/// @desc Gets current threat (aggro).
	/// @return {Real}
	static AggroGet = function()
	{
		return aggro;
	}
	
	/// @desc Resets threat (aggro) to 0.
	static AggroReset = function()
	{
		aggro = 0;
		return self;
	}
	
	#endregion

	#region SAVE AND LOAD API
	
	/// @desc Exports current entity state to a struct.
	/// @return {Struct} Struct containing entity save data.
	static Export = function()
	{
		var _export_data =
		{
			id:				id,
			template_key:	template_key,
			level:			level,
			group_key:		group_key,
			vars:			variable_clone(vars),
			stats:			{},
			slots:			{},
			states:			{},
			flags:			variable_clone(flags)
		};
		
		// Export each stat state.
		var _stat_keys = variable_struct_get_names(stats);
		for (var i = 0; i < array_length(_stat_keys); i++) 
		{
			var _key = _stat_keys[i];
			_export_data.stats[$ _key] = stats[$ _key].Export();
		}
		
		// Export each slot state.
		var _slot_keys = variable_struct_get_names(slots);
		for (var i = 0; i < array_length(_slot_keys); i++) 
		{
			var _key = _slot_keys[i];
			_export_data.slots[$ _key] = slots[$ _key].Export();
		}
		
		// Export each state state.
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) 
		{
			var _key = _state_keys[i];
			_export_data.states[$ _key] = states[$ _key].Export();
		}
		
		return _export_data;
	}
	
	/// @desc Imports and restores entity state from a struct.
	/// @param {Struct} data Struct containing saved data.
	static Import = function(_data)
	{
		// Restore base properties.
		id =		_data[$ "id"]			?? _data[$ "instance_id"] ?? id;
		level =		_data[$ "level"]		?? 1;
		group_key =	_data[$ "group_key"]	?? "";
		vars =		_data[$ "vars"]			?? {};
		// Load flags.
		flags =		_data[$ "flags"]		?? {};
		
		// Import each stat state.
		if (struct_exists(_data, "stats") ) 
		{
			var _import_stats = _data[$ "stats"];
			var _stat_keys = struct_get_names(_import_stats);
			var _stat_keys_length = array_length(_stat_keys);

			for (var i = 0; i < _stat_keys_length; i++) 
			{
				var _key = _stat_keys[i];
				if (struct_exists(stats, _key) ) { stats[$ _key].Import(_import_stats[$ _key]); }
			}
		}
		
		// Import each slot state.
		if (struct_exists(_data, "slots") ) 
		{
			var _import_slots = _data[$ "slots"];
			var _slot_keys = struct_get_names(_import_slots);
			var _slot_keys_length = array_length(_slot_keys);

			for (var i = 0; i < _slot_keys_length; i++) 
			{
				var _key = _slot_keys[i];
				if (struct_exists(slots, _key) ) { slots[$ _key].Import(_import_slots[$ _key]); }
			}
		}
		
		// Import each state state.
		if (struct_exists(_data, "states") ) 
		{
			var _import_states = _data[$ "states"];
			var _state_keys = struct_get_names(_import_states);
			var _state_keys_length = array_length(_state_keys);

			for (var i = 0; i < _state_keys_length; i++) 
			{
				var _key = _state_keys[i];
				if (struct_exists(states, _key) ) { states[$ _key].Import(_import_states[$ _key]); }
			}
		}
		
		// Recalculate everything to apply loaded changes.
		RecalculateStats();
	}
	
	#endregion

	#region STATE QUERY API
	
	/// @desc Returns an array with all active state keys.
	/// @return {Array<String>}
	static StateGetAllActive = function()
	{
		var _active_states = [];
		var _state_keys = variable_struct_get_names(states);
		var _state_keys_length = array_length(_state_keys);

		for (var i = 0; i < _state_keys_length; i++) 
		{
			var _key = _state_keys[i];
			if (states[$ _key].boolean_value) { array_push(_active_states, _key); }
		}

		return _active_states;
	}
	
	/// @desc Returns active state keys filtered by a specific type.
	/// @param {String} type Type to query (for example: "AILMENT", "BUFF").
	/// @return {Array<String>}
	static StateGetAllByType = function(_type)
	{
		var _active_states = [];
		var _type_upper = string_upper(_type);

		var _state_keys = variable_struct_get_names(states);
		var _state_keys_length = array_length(_state_keys);		
		for (var i = 0; i < _state_keys_length; i++) 
		{
			var _key = _state_keys[i];
			var _state_inst = states[$ _key];
			if (_state_inst.boolean_value && _state_inst.template.state_type == _type_upper) 
			{
				array_push(_active_states, _key);
			}
		}

		return _active_states;
	}
	
	#endregion

	#region FLAGS API
	
	/// @desc Adds a flag to the entity.
	/// @param {String} key Flag key (for example: "IMMUNE_TO_POISON").
	static FlagAdd = function(_key)
	{
		flags[$ _key] = true;
	}
	
	/// @desc Removes a flag from the entity.
	/// @param {String} key Flag key.
	static FlagRemove = function(_key)
	{
		struct_remove(flags, _key);
	}
	
	/// @desc Checks whether the entity has a specific flag.
	/// @param {String} key Flag key.
	/// @return {Bool}
	static FlagHas = function(_key)
	{
		return (struct_exists(flags, _key) );
	}
	
	#endregion

	#region API DEBUG
	/// @desc Returns a text representation of current entity state for debugging.
	/// @return {String} Formatted string with entity summary.
	static toString = function()
	{
		var _str = $"[ENTITY: {template_key} (Lvl {level})]";
		
		// Stats
		_str += "\n- Stats:";
		var _stat_keys = variable_struct_get_names(stats);
		// Sort alphabetically for easier reading.
		array_sort(_stat_keys, true);
		
		for (var i = 0; i < array_length(_stat_keys); i++) 
		{
			var _k = _stat_keys[i];
			var _s = stats[$ _k];
			// Format: NAME: Current/Max
			_str += $"\n  * {_k}: {_s.current_value}/{_s.control_value}";
		}
		
		// Slots (show only those with items).
		_str += "\n- Slots:";
		var _slot_keys = variable_struct_get_names(slots);
		array_sort(_slot_keys, true);
		var _has_items = false;
		
		for (var i = 0; i < array_length(_slot_keys); i++) 
		{
			var _k = _slot_keys[i];
			var _s = slots[$ _k];
			if (array_length(_s.equipped_items) > 0) 
			{
				_str += $"\n  * {_k}: {string(_s.equipped_items)}";
				_has_items = true;
			}
		}
		if (!_has_items) _str += " None";
		
		// States (show only active ones).
		_str += "\n- States:";
		var _state_keys = variable_struct_get_names(states);
		array_sort(_state_keys, true);
		var _has_states = false;
		
		for (var i = 0; i < array_length(_state_keys); i++) 
		{
			var _k = _state_keys[i];
			var _s = states[$ _k];
			if (_s.boolean_value) 
			{
				var _duration_text = (_s.iterator.duration == infinity) ? "Inf" : string(_s.iterator.duration - _s.iterator.ticks_elapsed);
				_str += $"\n  * {_k} ({_duration_text} trn)";
				_has_states = true;
			}
		}
		if (!_has_states) _str += " None";
		
		return _str;
	}
	
	#endregion
}