/// @desc Defines an inventory item template.
/// @param {String} key Unique template key.
function MallItem(_key) : MallBehavior(_key) constructor
{
	/// @type {Bool} Whether the item can stack.
	is_stackable = true;
	
	/// @type {Real} Maximum number of items per stack.
	stack_limit = 99;
	
	/// @type {Real} Buy price for this item.
	buy_value = 0;
	
	/// @type {Real} Sell price for this item.
	sell_value = 0;

	/// @type {Bool} Whether this item can target the caster.
	can_target_self = false;
	
	/// @type {Bool} Whether this item can target allies.
	can_target_ally = true;
	
	/// @type {Bool} Whether this item can target enemies.
	can_target_enemy = false;	

	/// @type {Bool} Whether this item can be sold.
	can_sell = true;
	
	/// @type {Bool} Whether this item can be bought.
	can_buy = true;
	
	/// @type {Struct} Stats granted by the item as [value, type].
	stats = {};
	
	#region EVENTS

	/// @desc Runs after the item is successfully equipped in this slot.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity that equipped the item.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where it was equipped.
	// event_on_equip = "";
	
	/// @desc Runs after the item is successfully unequipped from this slot.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity that unequipped the item.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where it was unequipped from.
	/// @returns {undefined}
	// event_on_desequip = "";
	
	/// @desc Runs on each RecalculateStats call.
	/// @param {Struct.MallEntity} entity The entity being updated.
	/// @returns {undefined}
	// event_on_update = "";
	
	/// @desc Validates whether the item can be equipped by an entity in a slot. Must return bool.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity trying to equip the item.
	/// @param {Struct.MallSlotInstance} slot_instance The target slot.
	/// @returns {Bool}
	event_can_equip = "";
	
	/// @desc Validates whether the item can be unequipped. Must return bool.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity trying to unequip the item.
	/// @param {Struct.MallSlotInstance} slot_instance The slot being unequipped.
	/// @returns {Bool}
	event_can_desequip = "";
	
	/// @desc Runs when the item is bought.
	/// @context Struct.MallItem
	/// @param {Struct.MallShop} shop The shop where it was bought.
	/// @returns {undefined}
	event_on_buy = "";
	
	/// @desc Runs when the item is sold.
	/// @context Struct.MallItem
	/// @param {Struct.MallShop} shop The shop where it was sold.
	/// @returns {undefined}
	event_on_sell = "";
	
	/// @desc Not implemented by the engine.
	/// @returns {undefined}
	event_on_world_step = "";
	
	/// @desc Not implemented by the engine.
	/// @returns {undefined}
	event_on_world_enter = "";
	
	/// @desc Not implemented by the engine.
	/// @returns {undefined}
	event_on_world_exit = "";
	
	/// @desc Runs when the equipped entity attacks.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} caster The attacking entity.
	/// @param {Struct.MallEntity} target The attack target.
	/// @returns {undefined}
	event_on_attack = "";
	
	/// @desc Runs when the equipped entity is attacked.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} defender The entity being attacked.
	/// @param {Struct.MallEntity} attacker The attacker.
	/// @returns {undefined}
	event_on_defense = "";

	/// @desc Runs on every turn update in the 'MallBattleManager'.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity updating the turn.
	/// @returns {undefined}
	// event_on_turn_update = "";
	
	/// @desc Runs at the start of the turn for the entity that has it enabled.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity updating the turn.
	/// @returns {undefined}
	// event_on_turn_start = "";
	
	/// @desc Runs at the end of the turn for the entity that has it enabled.
	/// @context Struct.MallItem
	/// @param {Struct.MallEntity} entity The entity updating the turn.
	/// @returns {undefined}
	// event_on_turn_end = "";
	
	#endregion

	#region PRIVATE API
	
	/// @ignore
	/// @desc Parses a stat entry from the data struct and stores it in the stats struct.
	/// @param {String} key The stat key, potentially with suffixes.
	/// @param {Real} value The stat value.
	static __Parse = function(_key, _value)
	{
		var _type = MALL_NUMTYPE.REAL;
		var _stat_key = _key;

		// Check for suffixes in the stat key.
		var _len = string_length(_key);
		var _suffix = string_char_at(_key, _len);
		if (_suffix == "%" || _suffix == "+") 
		{
			_stat_key = string_delete(_key, _len, 1);
			if (_suffix == "%") { _type = MALL_NUMTYPE.PERCENT; }
		}
		
		// Store as [value, type].
		stats[$ _stat_key] = [_value, _type];
	}

	/// @ignore
	/// @desc Loads stats from the data struct.
	/// @param {Struct} data Struct containing the item data.
	/// @returns {undefined}
	static __LoadStats = function(_data)
	{
		if (struct_exists(_data, "stats") ) 
		{ 
			struct_foreach(_data[$ "stats"], __Parse); 
		}
		else
		{
			__mall_alert($"Mall item '{key}' has no stats defined.");
		}
	}

	/// @ignore
	/// @desc Loads event callbacks from the data struct.
	/// @param {Struct} data Struct containing the item data.
	/// @returns {undefined}
	static __LoadEvents = function(_data)
	{
		// Load parent behavior callbacks.
		method(self, MallBehavior.__LoadEvents) (_data);

		// Equipment events.
		event_can_equip =    variable_get_hash(_data[$ "event_can_equip"]		?? "");
		event_can_desequip = variable_get_hash(_data[$ "event_can_desequip"]	?? "");
		
		event_on_buy =	variable_get_hash(_data[$ "event_on_buy"]	?? "");
		event_on_sell = variable_get_hash(_data[$ "event_on_sell" ]	?? "");
		
		event_on_attack =	variable_get_hash(_data[$ "event_on_attack"]	?? "");
		event_on_defense =	variable_get_hash(_data[$ "event_on_defense"]	?? "");

		event_on_world_step =  variable_get_hash(_data[$ "event_on_world_step"]		?? "");
		event_on_world_enter = variable_get_hash(_data[$ "event_on_world_enter"]	?? "");
		event_on_world_exit =  variable_get_hash(_data[$ "event_on_world_exit"]		?? "");

		return self;
	}

	#endregion

	#region PUBLIC API

	/// @desc Exports the item data to a struct, typically for database storage or saving.
	/// @returns {Struct} Struct with the item data.
	static Export = function()
	{
		var _this = self;
		with (method(self, MallBehavior.Export)() )
		{
			is_stackable = _this.is_stackable;
			stack_limit = _this.stack_limit;
			
			buy_value = _this.buy_value;
			sell_value = _this.sell_value;
			
			can_target_self = _this.can_target_self;
			can_target_ally = _this.can_target_ally;
			can_target_enemy = _this.can_target_enemy;
			can_sell = _this.can_sell;
			can_buy = _this.can_buy;

			// Events.
			event_can_equip = _this.event_can_equip;
			event_can_desequip = _this.event_can_desequip;
			event_on_buy = _this.event_on_buy;
			event_on_sell = _this.event_on_sell;
			event_on_attack = _this.event_on_attack;
			event_on_defense = _this.event_on_defense;
			event_on_world_step = _this.event_on_world_step;
			event_on_world_enter = _this.event_on_world_enter;
			event_on_world_exit = _this.event_on_world_exit;

			// Stats.
			stats = variable_clone(_this.stats);

			return self;
		}
	}

	/// @desc Configures the item from a data struct.
	/// @param {Struct} data Struct containing the item data.
	static Import = function(_data)
	{
		// Call parent import.
		method(self, MallBehavior.Import) (_data);

		// Load stats.
		__LoadStats(_data);

		// Configure item properties.
		is_stackable = _data[$ "is_stackable"] ?? is_stackable;
		stack_limit = _data[$ "stack_limit"] ?? stack_limit;

		// Economy
		buy_value =	 _data[$ "buy_value"]  ?? buy_value;
		sell_value = _data[$ "sell_value"] ?? sell_value;

		can_buy =  _data[$ "can_buy"]  ?? can_buy;
		can_sell = _data[$ "can_sell"] ?? can_sell;

		// Targets
		can_target_self =  _data[$ "can_target_self"]  ?? can_target_self;
		can_target_ally =  _data[$ "can_target_ally"]  ?? can_target_ally;
		can_target_enemy = _data[$ "can_target_enemy"] ?? can_target_enemy;
		
		return self;
	}
	
	#endregion
}