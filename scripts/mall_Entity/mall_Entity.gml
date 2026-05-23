/// @desc Represents a playable or non-playable entity in the system.
/// @param {String} template_key Template key used to build this entity.
/// @param {String} instance_id Unique ID for this entity instance.
function MallEntity(_template_key, _instance_id) : MallBehavior(_template_key) constructor
{
	/// @ignore
	/// @type {Struct} Cache for events to avoid redundant lookups. Maps event keys to resolved function references.
	__cache = {};

	/// @ignore
	/// @type {Bool} Flag used to optimize batched state updates.
	__is_updating_all_states = false;

	/// @ignore
	/// @type {Bool} Flag used to defer expensive recalculations while loading template data.
	__is_loading_template = false;
	
	/// @type {String} Unique identifier for this entity instance.
	id = _instance_id;
	/// @desc Group key for organizational purposes (for example, "enemies" or "allies").
	group_key = "";
	
	/// @type {Real} Experience given to the player when this entity is defeated.
	exp_value = 0;
	/// @type {String} Loot table key used to determine drops when this entity is defeated.
	loot_table_key = "";
	/// @type {Array} Bonus drops added on top of the loot table rolls.
	bonus_drops = [];

	/// @type {String} AI Package key used to determine behavior in battle.
	ai_package = "";
	/// @type {Struct.MallAIInstance} AI brain instance.
	ai_instance = undefined;

	/// @type {String} Entity faction.
	faction = "NEUTRAL";
	/// @type {Real} Threat level.
	aggro = 0;
	/// @type {Array} Commands learned on level milestones.
	learnset = [];

	/// @type {Real} Current level of the entity.
	level =	1;
	/// @type {Struct.MallStatInstance} Stat instances owned by this entity.
	stats =	{};
	/// @type {Struct.MallSlotInstance} Slot instances owned by this entity.
	slots =	{};
	/// @type {Struct.MallStateInstance} State instances owned by this entity.
	states = {};
	
	/// @type {Struct.MallEntityCommands} Command categories owned by this entity.
	commands = new MallEntityCommands(self, $"{id}_commands");

	/// @type {Struct} Flags for various purposes (for example, tracking if an enemy has called for help).
	flags =	{};
	
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
	/// @param {Struct.MallItem} item_template Equip operation result.
	// event_on_equip

	/// @desc Runs after an item is unequipped from any slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallSlotInstance} slot_instance Affected slot instance.
	/// @param {Struct.MallItem} item_template Unequip operation result.
	// event_on_desequip
	
	#endregion

	#region PRIVATE LOAD METHODS
	
	/// @ignore
	/// @desc Logs an alert message with entity context if __MALL_ENTITIES_ALERT is enabled.
	/// @param {String} _message Alert message to log.
	static __Alert = function(_message)
	{
		if (__MALL_ENTITIES_ALERT) __mall_alert($"\n	MallEntity '{id}': {_message}");
	}

	/// @ignore
	/// @desc Logs an error message with entity context.
	/// @param {String} _message Error message to log.
	static __Error = function(_message)
	{
		__mall_error($"\n	MallEntity '{id}': {_message}");
	}

	/// @ignore
	/// @desc Loads event functions from the template.
	/// @param {Struct} data Entity template struct.
	static __LoadEvents = function(_data)
	{
		method(self, MallBehavior.__LoadEvents) (_data);

		event_on_level_up = variable_get_hash(_data[$ "event_on_level_up"] ?? "");
		event_on_level_check = variable_get_hash(_data[$ "event_on_level_check"] ?? "");
		
		event_on_action_select = variable_get_hash(_data[$ "event_on_action_select"] ?? "");
	}

	/// @desc If the event exists in the cache.
	/// @param {String} event_key The slot event key to check.
	/// @returns {Bool}
	static __ExistsInCache = function(_key_instance, _key_item, _key_template)
	{
		return struct_exists_from_hash(__cache, _key_instance);
	}

	/// @ignore
	/// @desc Loads stat instances and applies base values.
	/// @param {Struct} template Entity template struct.
	static __LoadStats = function(_template)
	{
		var _all_stat_keys = mall_get_stat_keys();
		var i=0; repeat ( array_length(_all_stat_keys) )
		{
			var _stat_key = _all_stat_keys[i++];
			var _stat_instance = new MallStatInstance(mall_get_stat(_stat_key), self);
			
			stats[$ _stat_key] = _stat_instance;
			
			// Run start event on initialization.
			var _on_start = _stat_instance.event_on_start;
			if (is_callable(_on_start) ) method_call(_on_start, [_stat_instance]);
		}

		// Load base values.
		if (struct_exists(_template, "stats") )
		{
			var _template_stats = _template[$ "stats"];
			var _template_stats_keys = struct_get_names(_template_stats);
			var i=0; repeat(array_length(_template_stats_keys) )
			{
				var _stat_key = _template_stats_keys[i++];
				if (!struct_exists(stats, _stat_key) ) continue;

				var _stat_data = _template_stats[$ _stat_key];
				
				// Normalize numbers into the expected stat config struct.
				if (is_numeric(_stat_data) )
				{
					_stat_data = { base: _stat_data, growth: 0, curve: "linear" };
				}
				
				// Assign stat properties.
				var _stat = stats[$ _stat_key];
				_stat[$ "base_value"] =	_stat_data[$ "base"]	?? 1;
				_stat[$ "growth"] =		_stat_data[$ "growth"]	?? 1;
				_stat[$ "curve_name"] =	_stat_data[$ "curve"]	?? "linear";
				
				// Resolve growth curve reference.
				if (mall_asset_exists(_stat[$ "curve_name"]) )
				{
					_stat[$ "growth_curve"] = mall_asset_get(_stat[$ "curve_name"]);
				}
				// Fallback to linear if the curve asset is missing.
				else
				{
					_stat[$ "growth_curve"] = mall_asset_get("linear");
					_stat[$ "curve_name"] =	"linear";
				}
			}
		}
	}
	
	/// @ignore
	/// @desc Loads slot instances, updates permitted items, and equips initial items.
	/// @param {Struct} template Entity template.
	static __LoadSlots = function(_template)
	{
		var _all_slot_keys = mall_get_slot_keys();
		var i=0; repeat(array_length(_all_slot_keys) )
		{
			var _slot_key = _all_slot_keys[i++];
			var _slot_instance = new MallSlotInstance(mall_get_slot(_slot_key), self);
			
			slots[$ _slot_key] = _slot_instance;
			
			// Run start event on initialization.
			var _start_event = _slot_instance.event_on_start;
			if (is_callable(_start_event) ) method_call(_start_event, [_slot_instance]);			
		}

		if (struct_exists(_template, "slots") ) 
		{
			var _template_slots = _template[$ "slots"];
			var _template_slot_keys = struct_get_names(_template_slots);
			// Batch initial equips and recalculate once at the end of FromTemplate.
			__is_loading_template = true;

			var i=0; repeat(array_length(_template_slot_keys) )
			{
				var _slot_key = _template_slot_keys[i++];
				var _slot_data = _template_slots[$ _slot_key];
				
				if (is_struct(_slot_data) ) 
				{
					// Configure permitted entries per slot instance.
					if (struct_exists(_slot_data, "permitted") )
					{
						var _permitted_mods = _slot_data[$ "permitted"];
						var j=0; repeat(array_length(_permitted_mods) ) { SlotPermittedAdd(_slot_key, _permitted_mods[j++]); }
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

			__is_loading_template = false;
		}
	}
	
	/// @ignore
	/// @desc Loads state instances.
	/// @param {Struct} template Entity template.
	static __LoadStates = function(_template)
	{
		var _all_state_keys = mall_get_state_keys();
		var i=0; repeat(array_length(_all_state_keys) )
		{
			var _state_key = _all_state_keys[i++];
			var _state_instance = new MallStateInstance(mall_get_state(_state_key), self);
			
			states[$ _state_key] = _state_instance;
			
			// Run start event on initialization.
			var _on_start = _state_instance.event_on_start;
			if (is_callable(_on_start) ) method_call(_on_start, [_state_instance]);
		}
	}
	
	/// @ignore
	/// @desc Loads command categories from the entity template.
	/// @param {Struct} _template Entity template.
	static __LoadCommands = function(_template)
	{
		if (!struct_exists(_template, "commands") ) return;

		var _categories = struct_get_names(_template[$ "commands"]);
		var i=0; repeat(array_length(_categories) )
		{
			var _category_name = _categories[i++];
			var _command_keys = _template[$ "commands"][$ _category_name];
			
			var j=0; repeat(array_length(_command_keys) )
			{
				var _command_key = _command_keys[j++];
				CommandAdd(_category_name, _command_key);
			}
		}
	}

	/// @ignore
	/// @desc Loads AI instance.
	/// @param {Struct} template Entity template.
	static __LoadAI = function(_template)
	{
		if (!struct_exists(_template, "ai_package") ) return;
		// Initialize AI instance with the specified package and resolve rules.
		var _package = _template[$ "ai_package"];
		ai_instance = new MallAIInstance(self, _package);
	}
	
	/// @ignore
	/// @desc Calculates each stat base value (peak_value) from level.
	static __CalculatePeakValues = function()
	{
		var _stat_keys = struct_get_names(stats);
		var i=0; repeat(array_length(_stat_keys))
		{
			var _key = _stat_keys[i++];
			/// @type {Struct.MallStatInstance}
			var _inst = stats[$ _key];

			// Recalculate peak value through the stat API.
			_inst.Recalculate(self);
		}
	}

	/// @ignore
	/// @desc Applies a value/percent modifier into a stat field.
	/// @param {Struct.MallStatInstance} stat_to_mod Target stat.
	/// @param {Array} mod_array Modifier payload [value, numtype].
	/// @param {String} source_field Field name used as percent base.
	/// @param {String} target_field Field name updated with the final value.
	static __ApplyMod = function(_stat_to_mod, _mod_array, _source_field, _target_field)
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
	
	/// @ignore
	/// @desc Applies passive modifiers from states and effects.
	static __ApplyStateModifiers = function()
	{
		// Set control values to equipment values before applying state modifiers, so states can modify the effective stat values after equipment.
		var _stat_keys = struct_get_names(stats);
		var i=0; repeat(array_length(_stat_keys) )
		{
			/// @type {Struct.MallStatInstance}
			var _stat_inst = stats[$ _stat_keys[i++]];
			_stat_inst.control_value = _stat_inst.equipment_value;
		}
		
		var _state_keys = struct_get_names(states);
		var i=0; repeat(array_length(_state_keys) )
		{
			var _state_key = _state_keys[i++];
			/// @type {Struct.MallStateInstance}
			var _state_inst = states[$ _state_key];
			if (!_state_inst.boolean_value) continue;

			// Apply state-template modifiers.
			var _state_modifiers = _state_inst.stats;
			var _state_mod_keys = struct_get_names(_state_modifiers);
			var j=0; repeat(array_length(_state_mod_keys) )
			{
				var _stat_key = _state_mod_keys[j++];
				var _mod_array = _state_modifiers[$ _stat_key];
				
				if (!struct_exists(stats, _stat_key) ) continue;
				
				var _stat_to_mod = stats[$ _stat_key];
				__ApplyMod(_stat_to_mod, _mod_array, "equipment_value", "control_value");
			}
			
			// Apply passive effect modifiers inside the state.
			var j=0; repeat(array_length(_state_inst.effects))
			{
				var _effect_inst = _state_inst.effects[j++];
				var _effect_modifiers = _effect_inst.stats;
				var _effect_mod_keys = struct_get_names(_effect_modifiers);
				var k=0; repeat(array_length(_effect_mod_keys) )
				{
					var _stat_key = _effect_mod_keys[k++];
					var _mod_array = _effect_modifiers[$ _stat_key];
					
					// Process passive modifiers only ([value, numtype, true]).
					if (_mod_array[2] != true || !struct_exists(stats, _stat_key) ) continue;

					/// @type {Struct.MallStatInstance}
					var _stat_to_mod = stats[$ _stat_key];
					__ApplyMod(_stat_to_mod, _mod_array, "equipment_value", "control_value");
				}
			}
		}
	}

	/// @ignore
	/// @desc Applies equipment modifiers.
	static __ApplyEquipmentModifiers = function()
	{
		var _stat_keys = struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys);
		
		for (var i = 0; i < _stat_keys_length; i++) 
		{
			/// @type {Struct.MallStatInstance}
			var _stat_inst = stats[$ _stat_keys[i] ];
			_stat_inst.equipment_value = _stat_inst.peak_value;
		}
		
		var _slot_keys = struct_get_names(slots);
		var _slot_keys_length = array_length(_slot_keys);
		
		for (var i = 0; i < _slot_keys_length; i++) 
		{
			/// @type {Struct.MallSlotInstance}
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
					__ApplyMod(_stat_to_mod, _mod_array, "peak_value", "equipment_value");
				}
			}
		}
	}
	
	/// @ignore
	/// @desc Finalizes stat calculations, applies clamps, and updates values.
	static __FinalizeStatValues = function()
	{
		var _stat_keys = struct_get_names(stats);
		var i=0; repeat(array_length(_stat_keys))
		{
			var _key = _stat_keys[i++];
			/// @type {Struct.MallStatInstance}
			var _inst = stats[$ _key];

			_inst.last_peak_value =		_inst.peak_value;
			_inst.last_current_value =	_inst.current_value;
			_inst.control_value =		__MALL_STAT_ROUNDING_METHOD(clamp(_inst.control_value, _inst.template.min_value, _inst.template.max_value) );
			_inst.current_value =		min(_inst.current_value, _inst.control_value);
		}
	}
	
	/// @ignore
	/// @desc Dispatches an event to each component instance in a component struct.
	/// @param {Struct} components Struct containing component instances.
	/// @param {String} event_name Name of the event to dispatch.
	/// @param {Array<Any>} args Optional argument to pass to the event function.
	static __DispatchComponentEvent = function(_components, _event_name, _args)
	{
		var _keys = struct_get_names(_components);
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];
			var _inst = _components[$ _key];
			var _event_func = _inst[$ _event_name];
			// Pass the instance as the first argument, followed by any additional arguments provided.
			if (is_callable(_event_func) ) { _event_func(_inst, _args); }
		}
	}
	
	/// @ignore
	/// @desc Dispatches an event to all equipped items.
	/// @param {String} _event_name Name of the event to dispatch.
	/// @param {Struct.MallEntity} _entity Entity that owns the equipped items.
	/// @param {Struct.MallEntity|Undefined} _other_entity Optional opposite entity in combat (target or attacker).
	/// @param {Struct|Undefined} _payload Optional payload passed through all listeners.
	/// @returns {Struct|Undefined}
	static __DispatchEquippedItemEvent = function(_event_name, _entity, _other_entity=undefined, _payload=undefined)
	{
		var _slot_keys = struct_get_names(slots);
		var i=0; repeat(array_length(_slot_keys) )
		{
			var _slot_key = _slot_keys[i++];
			/// @type {Struct.MallSlotInstance}
			var _slot_inst = slots[$ _slot_key];
			var _equipped_items = _slot_inst.equipped_items;
			// Loop every equipped item in the slot and dispatch the event if the function exists.
			var j=0; repeat(array_length(_equipped_items) )
			{
				var _item_key = _equipped_items[j++];
				var _item_template = mall_get_item(_item_key);
				if (is_undefined(_item_template) ) continue;
				
				var _event_func = undefined;
				if (struct_exists(_item_template, _event_name) )
				{
					_event_func = _item_template[$ _event_name];
				}

				if (is_callable(_event_func) )
				{
					var _result = _event_func(_entity, _other_entity, _payload);
					if (!is_undefined(_result) ) _payload = _result;
				}
			}
		}

		return _payload;
	}

	/// @ignore
	/// @desc Dispatches a combat event to each component instance in a component struct.
	/// @param {Struct} _components Struct containing component instances.
	/// @param {String} _event_name Name of the event to dispatch.
	/// @param {Struct.MallEntity} _other_entity The opposite entity in combat (target or attacker).
	/// @param {Struct|Undefined} _payload Optional payload passed through all listeners.
	/// @returns {Struct|Undefined}
	static __DispatchComponentCombatEvent = function(_components, _event_name, _other_entity, _payload=undefined)
	{
		var _keys = struct_get_names(_components);
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];
			var _inst = _components[$ _key];
			if (!struct_exists(_inst, _event_name) ) continue;

			var _event_func = _inst[$ _event_name];
			if (is_callable(_event_func) )
			{
				var _result = _event_func(_inst, _other_entity, _payload);
				if (!is_undefined(_result) ) _payload = _result;
			}
		}

		return _payload;
	}

	/// @ignore
	/// @desc Dispatches a combat event to all active effect instances in all states.
	/// @param {String} _event_name Name of the event to dispatch.
	/// @param {Struct.MallEntity} _other_entity The opposite entity in combat (target or attacker).
	/// @param {Struct|Undefined} _payload Optional payload passed through all listeners.
	/// @returns {Struct|Undefined}
	static __DispatchEffectsCombatEvent = function(_event_name, _other_entity, _payload=undefined)
	{
		var _state_keys = struct_get_names(states);
		var i=0; repeat(array_length(_state_keys) )
		{
			var _state_key = _state_keys[i++];
			/// @type {Struct.MallStateInstance}
			var _state_inst = states[$ _state_key];

			var _effects = _state_inst.effects;
			var j=0; repeat(array_length(_effects) )
			{
				var _effect_inst = _effects[j++];
				if (!struct_exists(_effect_inst, _event_name) ) continue;

				var _event_func = _effect_inst[$ _event_name];
				if (is_callable(_event_func) )
				{
					var _result = _event_func(_effect_inst, _other_entity, _payload);
					if (!is_undefined(_result) ) _payload = _result;
				}
			}
		}

		return _payload;
	}

	/// @ignore
	/// @desc Notifies entity components after a slot equip/desequip operation.
	/// @param {String} event_name Name of the event ("event_on_equip" or "event_on_desequip").
	/// @param {Struct.MallSlotInstance} slot_inst Slot instance affected by the equip/desequip operation.
	/// @param {Struct} result Result of the equip/desequip operation.
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

	/// @ignore
	/// @desc Recalculates stats unless recalculation is currently deferred.
	static __RecalculateAfterEquipmentChange = function()
	{
		if (__is_loading_template) return;
		if (__is_updating_all_states) return;

		RecalculateStats();
	}

	/// @ignore
	/// @desc Constructor for drop entries used in runtime bonus drops.
	/// @param {String} key Item key.
	/// @param {Real, Array} quantity Quantity (number or [min, max] array).
	static __DropItem = function(_key, _quantity, _chance=100) constructor
	{
		key = _key;
		quantity = _quantity;
		chance = _chance;
	}

	/// @ignore
	/// @desc Constructor for drop entries used in runtime bonus drops.
	/// @param {Real} experience Experience points.
	/// @param {Array<Struct.MallEntity.__DropItem>} items Array of item drops.
	static __Drops = function(_exps=0, _items=[]) constructor
	{
		exps = _exps;
		items = _items;
	}
	
	#endregion
	
	#region PUBLIC API

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
			var _learn_data = learnset[i++];
			// Learn if requirement is between old and new level.
			if (_learn_data.level > _old_level && _learn_data.level <= level) 
			{
				CommandAdd(_learn_data.category, _learn_data.command);
			}
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
			__error($"StatGet: stat '{_key}' is not registered in the database.");
			return undefined;
		}

		if (!struct_exists(stats, _key) )
		{
			__error($"StatGet: stat '{_key}' is not loaded on entity '{id}'.");
			return undefined;
		}

		return (struct_get(stats, _key) );
	}
	
	/// @desc Sets the current value of a stat. Return the current value after modification.
	/// @param {String} key Stat key.
	/// @param {Real} value New value.
	/// @param {Enum.MALL_NUMTYPE} [numtype]=MALL_NUMTYPE.REAL
	/// @param {Enum.MALL_STAT_TARGET} [numtarget]=MALL_STAT_TARGET.CONTROL
	/// @return {Real}
	static StatSet = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarget=MALL_STAT_TARGET.CONTROL)
	{
		var _stat = StatGet(_key);
		if (is_undefined(_stat) ) return 0;
		
		_stat.last_current_value = _stat.current_value;
		var _new_value = _value;

		// If the value is a percentage, calculate the real value based on the specified target.
		if (_numtype == MALL_NUMTYPE.PERCENT) { _new_value = _stat.ReturnValueTarget(_numtarget) * _value / 100; }
		_stat.current_value = clamp(_new_value, _stat.template.min_value, _stat.control_value);

		return _stat.current_value;
	}
	
	/// @desc Adds (or subtracts) a value to a stat. Return the actual delta applied to the stat after clamps and rounding.
	/// @param {String} key Stat key.
	/// @param {Real} value Value to add (can be negative).
	/// @param {Enum.MALL_NUMTYPE} [numtype]=MALL_NUMTYPE.REAL
	/// @param {Enum.MALL_STAT_TARGET} [numtarget]=MALL_STAT_TARGET.CURRENT
	/// @return {Real}
	static StatAdd = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarget = MALL_STAT_TARGET.CURRENT)
	{
		var _stat = StatGet(_key);
		if (is_undefined(_stat) ) return 0;
		
		var _value_to_add = _value;
		if (_numtype == MALL_NUMTYPE.PERCENT)
		{
			var _base_for_percent = _stat.ReturnValueTarget(_numtarget);
			_value_to_add = (_base_for_percent * _value) / 100;
		}
		
		var _old_value = _stat.current_value;
		var _new_value = __MALL_STAT_ROUNDING_METHOD(_old_value + _value_to_add);
		
		StatSet(_key, _new_value);

		return (_stat.current_value - _old_value);
	}
	
	/// @desc Iterates over stat instances and applies a callback function.
	/// @param {Function} fn Callback function with signature fn(stat_key, stat_instance).
	static StatForeach = function(_fn)
	{
		var _stat_keys = struct_get_names(stats);
		var i=0; repeat(array_length(_stat_keys))
		{
			var _stat_key = _stat_keys[i++];
			var _stat_inst = stats[$ _stat_key];
			_fn(_stat_key, _stat_inst);
		}

		return self;
	}

	#endregion
	
	#region SLOTS API
	
	/// @desc Gets a slot instance.
	/// @param {String} key Slot key.
	/// @return {Struct.MallSlotInstance}
	static SlotGet = function(_key)
	{
		if (!mall_exists_slot(_key) )
		{
			__error($"SlotGet: slot '{_key}' is not registered in the database.");
			return undefined;
		}

		if (!struct_exists(slots, _key) )
		{
			__error($"SlotGet: slot '{_key}' is not loaded on entity '{id}'.");
			return undefined;
		}

		return (struct_get(slots, _key) );
	}
	
	/// @desc Adds permitted items/types for a slot.
	/// @param {String} key Slot key.
	/// @param {String, Array} item_or_type_key Item or type key to add.
	static SlotPermittedAdd = function(_key, _item_or_type_key)
	{
		var _slot = SlotGet(_key);
		if (is_undefined(_slot) ) return;
		
		if (mall_exists_type(_item_or_type_key) ) 
		{
			var _type_items = mall_get_type(_item_or_type_key);
			var _slot_permitted = _slot[$ "permitted"];
			var i=0; repeat(array_length(_type_items) ) { _slot_permitted[$ _type_items[i++]] = 0; }

			__alert($"Added type '{_item_or_type_key}' to slot '{_key}' permitted list. This allows items of this type to be equipped in the slot.");
		} 
		else
		{
			_slot[$ "permitted"][$ _item_or_type_key] = 0;
			__alert($"Added item '{_item_or_type_key}' to slot '{_key}' permitted list. This allows the item to be equipped in the slot.");
		}

		return self;
	}
	
	/// @desc Removes permitted items/types.
	/// @param {String} key Slot key.
	/// @param {String, Array} item_or_type_key Item or type key to remove.
	static SlotPermittedRemove = function(_key, _item_or_type_key)
	{
		var _slot = SlotGet(_key);
		if (is_undefined(_slot) ) return;
		
		if (mall_exists_type(_item_or_type_key) ) 
		{
			var _type_items = mall_get_type(_item_or_type_key);
			var _slot_permitted = _slot[$ "permitted"];
			var i=0; repeat(array_length(_type_items) ) { struct_remove(_slot_permitted, _type_items[i++]); }

			__alert($"Removed type '{_item_or_type_key}' from slot '{_key}' permitted list. This prevents items of this type from being equipped in the slot.");
		}
		else
		{
			struct_remove(_slot[$ "permitted"], _item_or_type_key);
			__alert($"Removed item '{_item_or_type_key}' from slot '{_key}' permitted list. This prevents the item from being equipped in the slot.");
		}

		return self;
	}
	
	/// @desc Equips an item into a slot. Returns an Struct with the operation result and any relevant data.
	/// @param {String} slot_key Slot key.
	/// @param {String} item_key Item key to equip.
	/// @return {{success: Bool, previously_equipped: Array<String>|undefined}}
	static SlotEquip = function(_slot_key, _item_key)
	{
		var _slot_inst = SlotGet(_slot_key);
		if (is_undefined(_slot_inst) )
		{
			__alert($"SlotEquip: slot '{_slot_key}' is invalid or not loaded.");
			return { success: false, previously_equipped: undefined };
		}
		
		var _equip = _slot_inst[$ "Equip"];
		if (!is_callable(_equip) )
		{
			__error($"SlotEquip: Equip callback is not callable for slot '{_slot_key}'.");
			return { success: false, previously_equipped: undefined };
		}
		
		// Call the equip function of the slot instance, which returns a result struct with success and previously_equipped fields.
		var _result = method(_slot_inst, _equip)(_item_key);
		if (_result.success)
		{ 
			__RecalculateAfterEquipmentChange();
			__NotifySlotChange("event_on_equip", _slot_inst, _result);

			__alert($"Item '{_item_key}' was equipped in slot '{_slot_key}'.");
		}
		else
		{
			__alert($"Failed to equip item '{_item_key}' in slot '{_slot_key}'.");
		}
		
		return (_result);
	}
	
	/// @desc Unequips an item from a slot.
	/// @param {String} slot_key Slot key.
	/// @param {String} item_key Item key to unequip.
	/// @return {{success: Bool, unequipped_item: String|Array|undefined}}
	static SlotDesequip = function(_slot_key, _item_key)
	{
		var _slot_inst = SlotGet(_slot_key);
		if (is_undefined(_slot_inst))
		{
			__alert($"SlotDesequip: slot '{_slot_key}' is invalid or not loaded.");
			return { success: false, unequipped_item: undefined };
		}

		var _desequip = _slot_inst[$ "Desequip"];
		if (!is_callable(_desequip) )
		{
			__error($"SlotDesequip: Desequip callback is not callable for slot '{_slot_key}'.");
			return { success: false, unequipped_item: undefined };
		}

		// Call the desequip function of the slot instance, which returns a result struct with success and unequipped_item fields.
		var _result = method(_slot_inst, _desequip)(_item_key);
		if (_result.success) 
		{ 
			__RecalculateAfterEquipmentChange();
			__NotifySlotChange("event_on_desequip", _slot_inst, _result);

			__alert($"Item '{_item_key}' was unequipped from slot '{_slot_key}'.");
		}
		else
		{
			__alert($"Failed to unequip item '{_item_key}' from slot '{_slot_key}'.");
		}
		
		return (_result);
	}

	/// @desc Returns equipped item keys for a slot. Returns an empty array if the slot is empty or undefined.
	/// @param {String} key Slot key.
	/// @return {Array<String>}
	static SlotGetEquipped = function(_key)
	{
		var _slot = SlotGet(_key);
		if (is_undefined(_slot) ) return [];
		return (_slot[$ "equipped_items"]);
	}
	
	/// @desc Checks whether an item is permitted in a slot.
	/// @param {String} slot_key Slot key.
	/// @param {String} item_key Item key to check.
	/// @return {Bool}
	static SlotIsPermitted = function(_slot_key, _item_key)
	{
		var _slot = SlotGet(_slot_key);
		if (is_undefined(_slot) ) return false;

		return (struct_exists(_slot[$ "permitted"], _item_key));
	}
	
	/// @desc Checks whether a slot has no equipped items.
	/// @param {String} key Slot key.
	/// @return {Bool}
	static SlotIsEmpty = function(_key)
	{
		var _slot = SlotGet(_key);
		if (is_undefined(_slot) ) return true;
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
		if (!struct_exists(states, _key) )
		{
			__error($"StateGet: state '{_key}' is not loaded on entity '{id}'.");
			return undefined;
		}

		return (struct_get(states, _key) );
	}
	
	/// @desc Checks whether a state is active on the entity (has at least one effect).
	/// @param {String} key State key.
	/// @return {Bool}
	static StateIsActive = function(_key)
	{
		var _state = StateGet(_key);
		if (is_undefined(_state) ) return false;
		
		return (_state[$ "boolean_value"] );
	}
	
	/// @desc Adds an effect to an entity state. Return created effect instance, or undefined on failure.
	/// @param {String} effect_key Effect template key to add.
	/// @return {Struct.MallEffectInstance|Undefined}
	static EffectAdd = function(_effect_key)
	{
		var _result = { added: undefined, success: false, leftover: undefined }

		// Resolve effect template, return early if missing.
		var _effect_template = mall_get_effect(_effect_key);
		if (is_undefined(_effect_template) )
		{
			__alert($"EffectAdd: effect template '{_effect_key}' was not found.");
			return _result;
		}
		
		// Resolve target state instance, return early if missing.
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst) )
		{
			__alert($"EffectAdd: state '{_state_key}' is not loaded on entity '{id}'.");
			return _result;
		}
		
		// Create effect instance and validate insertion.
		var _effect_instance = new MallEffectInstance(_effect_template);
		// Validate whether this effect can be added.
		var _can_add_effect = _state_inst[$ "event_can_add_effect"];
		if (is_callable(_can_add_effect) && !(method(_state_inst, _can_add_effect)(_state_inst, _effect_instance) ) ) 
		{
			__alert($"EffectAdd: event_can_add_effect denied effect '{_effect_key}' for state '{_state_key}'.");
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
			/// @type {Struct.MallStateInstance}
			var _current_state_inst = states[$ _k];
			if (!_current_state_inst.boolean_value) continue;
			
			// Current active state prevents target state.
			if (array_contains(_current_state_inst.template.prevents_states, _state_key) )
			{
				__alert($"EffectAdd: active state '{_k}' prevents state '{_state_key}'.");
				return _result;
			}
			
			// Check state priority.
			if (_current_state_inst.template.restricts_action && _state_template.priority < _current_state_inst.template.priority)
			{
				__alert($"EffectAdd: blocked by higher-priority active state '{_k}'.");
				return _result;
			}
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
		/// @ignore
		static __default_filter = function(_value, _index)
		{
			return (_value.template.key == self[$ "template"][$ "key"]);
		}
		
		var _result = { removed: undefined, success: false }
		
		// Resolve effect template, return early if missing.
		var _effect_template = mall_get_effect(_effect_key);
		if (is_undefined(_effect_template) )
		{
			__alert($"EffectRemove: effect template '{_effect_key}' was not found.");
			return _result;
		}
		
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst) )
		{
			__alert($"EffectRemove: state '{_state_key}' is not loaded on entity '{id}'.");
			return _result;
		}

		// Find first matching effect and remove it.
		var _index = array_find_index(_state_inst[$ "effects"], method({ template: _effect_template }, _filter ?? __default_filter));
		var _effect_removed = undefined;
		
		if (_index > -1) _effect_removed = _state_inst[$ "effects"][_index];
		
		// Return if no effect matched.
		if (is_undefined(_effect_removed) )
		{
			__alert($"EffectRemove: no effect instance matched key '{_effect_key}' on state '{_state_key}'.");
			return _result;
		}
		
		// Validate remove policy.
		var _can_remove_effect = _state_inst[$ "event_can_remove_effect"];
		if (is_callable(_can_remove_effect) && !method(_state_inst, _can_remove_effect)(_state_inst, _effect_removed) ) 
		{
			__alert($"EffectRemove: event_can_remove_effect denied effect '{_effect_key}' on state '{_state_key}'.");
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

	/// @desc Runs a function for each effect instance in a state.
	/// @param {String} key State key.
	/// @param {Function} fn Function to execute. Receives (effect_instance, index).
	static EffectForeach = function(_key, _fn)
	{
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst[$ "boolean_value"]) return;

		// Iterate over effects with index.
		var _effects = _state_inst[$ "effects"];
		var i=0; repeat (array_length(_effects) )
		{
			var _effect_inst = _effects[i++];
			_fn(_effect_inst, i);
		}
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
			var _result_key = string(_effect_key) + "_" + string(i);

			struct_set(_results, _result_key, EffectRemove(_effect_key, _filter));
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
		var i=0; repeat(array_length(_keys) ) { EffectsUpdateByTurn(_keys[i++], _turn_type); }
		
		// Re-enable regular recalculation flow.
		__is_updating_all_states = false;
		
		RecalculateStats();
	}
	
	/// @desc Runs a function for each entity state.
	/// @param {Function} fn Function to execute. Receives (state_key, state_instance).
	static StateForeach = function(_fn)
	{
		var _keys = struct_get_names(states);
		var i=0; repeat(array_length(_keys) ) 
		{
			var _key = _keys[i++];
			var _state_inst = states[$ _key];
			_fn(_key, _state_inst);
		}
	}

	#endregion

	#region COMMANDS API
	
	/// @desc Adds a command to a category. Returns true if added successfully.
	/// @param {String} category_key Category key to add into.
	/// @param {String} command_key Command key to add.
	/// @return {Bool}
	static CommandAdd = function(_category_key, _command_key)
	{
		return commands.AddCommand(_category_key, _command_key);
	}
	
	/// @desc Removes a command from a category. Returns true if removed.
	/// @param {String} category_key Command category key.
	/// @param {String} command_key Command key to remove.
	/// @return {Bool} 
	static CommandRemove = function(_category_key, _command_key)
	{
		return commands.RemoveCommand(_category_key, _command_key);
	}
	
	/// @desc Checks whether the entity has a command in a specific category.
	/// @param {String} category_key Category key to query.
	/// @param {String} command_key Command key.
	/// @return {Bool}
	static CommandExists = function(_category_key, _command_key)
	{
		return commands.HasCommand(_category_key, _command_key);
	}
	
	/// @desc Gets the command template if owned by the entity. Return the command or undefined if the entity does not have the command.
	/// @param {String} category_key Command category key.
	/// @param {String} command_key Command key.
	/// @return {Struct.MallCommand|Undefined}
	static CommandGet = function(_category_key, _command_key)
	{
		return commands.GetCommand(_category_key, _command_key);
	}
	
	/// @desc Gets all command keys in a category. Array with command keys or empty array if category does not exist or has no commands.
	/// @param {String} category_key Category key.
	/// @return {Array<String>}
	static CommandGetAll = function(_category_key)
	{
		return commands.GetAllCommands(_category_key);
	}
	
	/// @desc Gets a random command key from a category.
	/// @param {String} category_key Category key.
	/// @return {String} Random command key, or undefined.
	static CommandGetRandom = function(_category_key)
	{
		return commands.GetRandomCommand(_category_key);
	}
	
	/// @desc Gets all command categories for the entity.
	/// @return {Array<String>}
	static CategoryGetAll = function()
	{
		return commands.GetCategories();
	}
	
	#endregion

	#region MISC API

	/// @desc Calculates and returns experience and item drops when the entity is defeated. 
	/// Return struct with format { exps: Real, items: Array<Struct.MallEntity.__DropItem> }.
	/// @return {Struct.MallEntity.__Drops}
	static GetDrops = function()
	{
		// Start with bonus drops defined at runtime, then merge drops from the loot table and roll final drops.
		var _result = new __Drops();
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
		var i=0; repeat(array_length(_all_drops) )
		{
			var _drop_data = _all_drops[i++];
			var _chance = _drop_data.chance ?? 100;
			
			if (random(100) >= _chance) continue;

			// Determine quantity.
			var _quantity_data = _drop_data.quantity ?? 1;
			var _quantity = is_array(_quantity_data) ? 
				irandom_range(_quantity_data[0], _quantity_data[1]) : 
				_quantity_data;
			// Add to result if quantity is greater than 0.
			if (_quantity > 0) { array_push(_result.items, new __DropItem(_drop_data.key, _quantity)); }
		}

		return _result;
	}	

	/// @desc Adds a new runtime drop entry to the entity.
	/// @param {String} key Item key.
	/// @param {Real, Array} quantity Quantity (number or [min, max] array).
	/// @param {Real} [chance]=100 Drop chance (0-100).
	static AddDrop = function(_key, _quantity, _chance = 100)
	{
		array_push(bonus_drops, new __DropItem(_key, _quantity, _chance) );
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

	/// @desc Runs attack hooks on every entity component (stats, slots, states, effects, equipped items).
	/// @param {Struct.MallEntity} _target Target entity receiving this attack.
	/// @param {Struct|Undefined} _payload Optional payload passed through all listeners.
	/// @returns {Struct|Undefined}
	static OnAttack = function(_target, _payload=undefined)
	{
		_payload = __DispatchComponentCombatEvent(stats, "event_on_attack", _target, _payload);
		_payload = __DispatchComponentCombatEvent(slots, "event_on_attack", _target, _payload);
		_payload = __DispatchComponentCombatEvent(states, "event_on_attack", _target, _payload);
		_payload = __DispatchEffectsCombatEvent("event_on_attack", _target, _payload);
		_payload = __DispatchEquippedItemEvent("event_on_attack", self, _target, _payload);

		return _payload;
	}

	/// @desc Runs defense hooks on every entity component (stats, slots, states, effects, equipped items).
	/// @param {Struct.MallEntity} _attacker Entity attacking this defender.
	/// @param {Struct|Undefined} _payload Optional payload passed through all listeners.
	/// @returns {Struct|Undefined}
	static OnDefense = function(_attacker, _payload=undefined)
	{
		_payload = __DispatchComponentCombatEvent(stats, "event_on_defense", _attacker, _payload);
		_payload = __DispatchComponentCombatEvent(slots, "event_on_defense", _attacker, _payload);
		_payload = __DispatchComponentCombatEvent(states, "event_on_defense", _attacker, _payload);
		_payload = __DispatchEffectsCombatEvent("event_on_defense", _attacker, _payload);
		_payload = __DispatchEquippedItemEvent("event_on_defense", self, _attacker, _payload);

		return _payload;
	}

	/// @desc Selects the action for this turn.
	/// @param {Struct} battle_context Battle context (allies, enemies).
	/// @return {Struct} Selected action.
	static SelectAction = function(_battle_context)
	{
		// Delegate decision-making to AI when available.
		if (!is_undefined(ai_instance) )
		{
			return ai_instance.SelectAction(_battle_context);
		}
		
		// Otherwise, caller may use player input or a default action.
		return undefined;
	}

	/// @desc Checks whether the entity can perform an action this turn. Returns false if any active state restricts actions.
	/// @return {Bool}
	static CanAct = function()
	{
		var _state_keys = variable_struct_get_names(states);
		var i=0; repeat(array_length(_state_keys) )
		{
			var _key = _state_keys[i++];
			/// @type {Struct.MallStateInstance}
			var _state_inst = states[$ _key];
			
			// Active state prevents actions.
			if (_state_inst.boolean_value && _state_inst.template.restricts_action) { return false; }
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
		var _this = self;
		with (method(self, MallBehavior.Export)() )
		{
			id = _this.id;
			group_key = _this.group_key;
			exp_value = _this.exp_value;
			loot_table_key = _this.loot_table_key;
			bonus_drops = variable_clone(_this.bonus_drops);
			ai_package = _this.ai_package.Export();
			faction = _this.faction;
			aggro = _this.aggro;
			learnset = variable_clone(_this.learnset);
			
		}

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
		var _stat_keys = struct_get_names(stats);
		var i=0; repeat ( array_length(_stat_keys) ) 
		{ 
			var _key = _stat_keys[i++];
			_export_data.stats[$ _key] = stats[$ _key].Export(); 
		}
		
		// Export each slot state.
		var _slot_keys = variable_struct_get_names(slots);
		var i=0; repeat ( array_length(_slot_keys) ) 
		{ 
			var _key = _slot_keys[i++];
			_export_data.slots[$ _key] = slots[$ _key].Export(); 
		}
		
		// Export each state state.
		var _state_keys = variable_struct_get_names(states);
		var i=0; repeat ( array_length(_state_keys) ) 
		{ 
			var _key = _state_keys[i++];
			_export_data.states[$ _key] = states[$ _key].Export();
		}
		
		return _export_data;
	}
	
	/// @desc Imports and restores entity state from a struct.
	/// @param {Struct} data Struct containing saved data.
	static Import = function(_data)
	{
		// Parent Import.
		method(self, MallBehavior.Import)(_data);

		// Restore base properties.
		id = _data[$ "id"] ?? id;
		group_key = _data[$ "group_key"] ?? group_key;

		// 
		exp_value = _data[$ "exp_value"] ?? exp_value;
		loot_table_key = _data[$ "loot_table_key"] ?? loot_table_key;
		bonus_drops = _data[$ "bonus_drops"] ?? bonus_drops;
		
		// Load AI.
		ai_package = _data[$ "ai_instance"] ?? ai_instance;
		if (mall_exists_ai_package(ai_package) )
		{
			ai_package = mall_get_ai_package(ai_package);
		}

		faction = _data[$ "faction"] ?? faction;
		aggro = _data[$ "aggro"] ?? aggro;
		learnset = _data[$ "learnset"] ?? learnset;

		// 
		level = _data[$ "level"] ?? level;

		__LoadStats(_data);
		__LoadSlots(_data);
		__LoadStates(_data);
		__LoadCommands(_data);
		__LoadAI(_data);
		
		// Recalculate everything to apply loaded changes.
		RecalculateStats();

		return self;
	}

	#endregion

	#region STATE QUERY API
	
	/// @desc Returns an array with all active state keys.
	/// @return {Array<String>}
	static StateGetAllActive = function()
	{
		var _active_states = [];
		var _state_keys = struct_get_names(states);
		var i=0; repeat(array_length(_state_keys) )
		{
			var _key = _state_keys[i++];
			/// @type {Struct.MallStateInstance}
			var _state_inst = states[$ _key];

			if (_state_inst.boolean_value) { array_push(_active_states, _key); }
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
		var _state_keys = struct_get_names(states);

		var i=0; repeat(array_length(_state_keys) )
		{
			var _key = _state_keys[i++];
			/// @type {Struct.MallStateInstance}
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
	
	/// @desc Runs a function for each entity flag.
	/// @param {Function} fn Function to execute. Receives (value, key).
	static FlagForeach = function(_fn)
	{
		struct_foreach(flags, _fn);
	}

	#endregion

	#region API DEBUG
	/// @desc Returns a text representation of current entity state for debugging.
	/// @return {String} Formatted string with entity summary.
	static toString = function()
	{
		var _str = $"[MallEntity: {template_key} (Lvl {level})]";
		
		// Stats
		_str += "\n- Stats:";
		var _stat_keys = struct_get_names(stats);
		// Sort alphabetically for easier reading.
		array_sort(_stat_keys, true);
		
		var i=0; repeat(array_length(_stat_keys) )
		{
			var _k = _stat_keys[i++];
			/// @type {Struct.MallStatInstance}
			var _s = stats[$ _k];
			// Format: NAME: Current/Max
			_str += $"\n  * {_k}: {_s.current_value}/{_s.control_value}";
		}

		// Slots (show only those with items).
		_str += "\n- Slots:";
		var _slot_keys = struct_get_names(slots);
		array_sort(_slot_keys, true);
		var _has_items = false;
		
		var i=0; repeat(array_length(_slot_keys) )
		{
			var _k = _slot_keys[i++];
			/// @type {Struct.MallSlotInstance}
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
		var _state_keys = struct_get_names(states);
		array_sort(_state_keys, true);
		var _has_states = false;
		
		var i=0; repeat(array_length(_state_keys) )
		{
			var _k = _state_keys[i++];
			/// @type {Struct.MallStateInstance}
			var _s = states[$ _k];
			if (_s[$ "boolean_value"])
			{
				var _duration_left = 0;
				var _has_finite_duration = false;
				var _has_infinite_duration = false;
				/// @type {Array<Struct.MallEffectInstance>}
				var _effects = _s.effects;
				var j=0; repeat(array_length(_effects) )
				{
					/// @type {Struct.MallEffectInstance}
					var _effect_inst = _effects[j++];
					var _iter = (_effect_inst.template.turn_type == MALL_EFFECT_TURN.END) ? _effect_inst.iterator_end : _effect_inst.iterator_start;
					var _iter_duration = _iter.duration;

					if (_iter_duration == infinity)
					{
						_has_infinite_duration = true;
						continue;
					}

					_has_finite_duration = true;
					var _remaining = max(0, _iter_duration - _iter.ticks_elapsed);
					_duration_left = max(_duration_left, _remaining);
				}

				var _duration_text = (_has_infinite_duration && !_has_finite_duration) ? "Inf" : string(_duration_left);
				_str += $"\n  * {_k} ({_duration_text} trn)";
				_has_states = true;
			}
		}
		if (!_has_states) _str += " None";
		
		return _str;
	}
	
	#endregion

	#endregion
}