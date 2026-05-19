/// @desc Defines an inventory item template.
/// @param {String} key Unique template key.
function MallItem(_key) : MallBehavior(_key) constructor
{
    /// @desc Item type. Stored in Systemall's global type index.
    /// @type {String}
    item_type = "UNDEFINED";
    
    /// @desc Whether the item can stack.
    /// @type {Bool}
    is_stackable = true;
    
    /// @desc Maximum number of items per stack.
    /// @type {Real}
    stack_limit = 99;
    
    /// @desc Item-specific variables shared by this template.
    /// @type {Struct}
    vars = {};
	
    // Targeting flags.
    
    /// @desc Whether this item can target the caster.
    /// @type {Bool}
    can_target_self = false;
    
    /// @desc Whether this item can target allies.
    /// @type {Bool}
    can_target_ally = true;
    
    /// @desc Whether this item can target enemies.
    /// @type {Bool}
    can_target_enemy = false;
	
    // Trade values.
    
    /// @desc Buy price for this item.
    /// @type {Real}
    buy_value = 0;
    
    /// @desc Sell price for this item.
    /// @type {Real}
    sell_value = 0;
    
    /// @desc Whether this item can be sold.
    /// @type {Bool}
    can_sell = true;
    
    /// @desc Whether this item can be bought.
    /// @type {Bool}
    can_buy = true;
	
    /// @desc Stats granted by the item as [value, type].
    /// @type {Struct}
    stats = {};

	#region EVENTS

    /// @desc Runs after the item is successfully equipped in this slot.
    /// @context Struct.MallItem
    /// @param {Struct.MallEntity} entity The entity that equipped the item.
    /// @param {Struct.MallSlotInstance} slot_instance The slot where it was equipped.
    /// @returns {undefined}
    event_on_equip = "";
	
    /// @desc Runs after the item is successfully unequipped from this slot.
    /// @context Struct.MallItem
    /// @param {Struct.MallEntity} entity The entity that unequipped the item.
    /// @param {Struct.MallSlotInstance} slot_instance The slot where it was unequipped from.
    /// @returns {undefined}
    event_on_desequip = "";
	
    /// @desc Runs on each RecalculateStats call.
    /// @param {Struct.MallEntity} entity The entity being updated.
    /// @returns {undefined}
    event_on_update = "";
	
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

    /// @desc Runs on every turn update in the WateManager.
    /// @context Struct.MallItem
    /// @param {Struct.MallEntity} entity The entity updating the turn.
    /// @returns {undefined}
    event_on_turn_update = "";
	
    /// @desc Runs at the start of the turn for the entity that has it enabled.
    /// @context Struct.MallItem
    /// @param {Struct.MallEntity} entity The entity updating the turn.
    /// @returns {undefined}
    event_on_turn_start = "";
	
    /// @desc Runs at the end of the turn for the entity that has it enabled.
    /// @context Struct.MallItem
    /// @param {Struct.MallEntity} entity The entity updating the turn.
    /// @returns {undefined}
    event_on_turn_end = "";
	
	#endregion

	#region PRIVATE
	
    /// @ignore
    /// @desc Loads stats from the data struct.
    /// @param {Struct} data Struct containing the item data.
    /// @returns {undefined}
    static __LoadStats = function(_data)
    {
        /// @ignore
        static __get = function(_key, _value) 
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

		if (struct_exists(_data, "stats") ) 
		{ 
			struct_foreach(_data[$ "stats"], __get); 
		}
		else
		{
			var _name = _data[$ "name"];
			__mall_alert($"Pocket item '{_name}' has no stats defined.");
		}
	}

    /// @ignore
    /// @desc Loads event callbacks from the data struct.
    /// @param {Struct} data Struct containing the item data.
    /// @returns {undefined}
    static __LoadFunctions = function(_data)
    {
		// Load inherited MallBehavior callbacks.
		event_on_update = method(self, mall_get_event( _data[$ "event_on_update"] ) );
	
		// Turn events.
		event_on_turn_update = method(self, mall_get_event( _data[$ "event_on_turn_update"] ) );
		event_on_turn_start = method(self, mall_get_event( _data[$ "event_on_turn_start"] ) );
		event_on_turn_end = method(self, mall_get_event( _data[$ "event_on_turn_end"] ) );
		
		// Equipment events.
		event_on_equip = method(self, mall_get_event( _data[$ "event_on_equip"] ) );
		event_on_desequip = method(self, mall_get_event( _data[$ "event_on_desequip"] ) );
		
		event_can_equip = method(self, __mall_get_event_check_true( _data[$ "event_can_equip"] ) );
		event_can_desequip = method(self, __mall_get_event_check_true( _data[$ "event_can_desequip"] ) );
	
		event_on_buy = method(self, mall_get_event( _data[$ "event_on_buy"] ) );
		event_on_sell = method(self, mall_get_event( _data[$ "event_on_sell" ] ) );
	
		// event_on_world_step = mall_get_function(_data[$ "event_on_world_step"]);
		// event_on_world_enter = mall_get_function(_data[$ "event_on_world_enter"]);
		// event_on_world_exit = mall_get_function(_data[$ "event_on_world_exit"]);
	
		event_on_attack = method(self, mall_get_event( _data[$ "event_on_attack"] ) );
		event_on_defense = method(self, mall_get_event( _data[$ "event_on_defense"] ) );
	}

	#endregion

	#region API

    /// @desc Configures the item from a data struct.
    /// @param {Struct} data Struct containing the item data.
    /// @returns {MallItem}
    static FromData = function(_data)
    {
		// Reset mutable state before loading new data.
		can_target_self = false;
		can_target_ally = true;
		can_target_enemy = false;
		stats = {};

		item_type =	string_upper(_data[$ "item_type"] ?? "UNDEFINED");
		is_stackable = _data[$ "is_stackable"] ?? true;
		stack_limit = _data[$ "stack_limit"] ?? 99;
		
		// Load item-specific variables.
		vars = variable_clone( _data[$ "vars"] ?? vars );
		
		// Read the "target_types" array from JSON. Default is ["ally"].
		var _targets = _data[$ "target_types"] ?? ["ally"];
		if (is_array(_targets) )
		{
			// Iterate through the array and enable the matching flags.
			var i=0; repeat(array_length(_targets) )
			{
				var _target_lower = string_lower(_targets[i++]);
				switch (_target_lower)
				{
					case "self":	can_target_self =  true; break;
					case "ally":	can_target_ally =  true; break;
					case "enemy":	can_target_enemy = true; break;
				}					
			}
		}
		
		// Economy.
		buy_value =	_data[$ "buy_value"]	?? 0;
		sell_value = _data[$ "sell_value"]	?? 0;
		can_sell = _data[$ "can_sell"]		?? true;
		can_buy = _data[$ "can_buy"]		?? true;
		
		// Load stats and callbacks.
		__LoadStats(_data);
		__LoadFunctions(_data);
		
		return self;
	}
	
	#endregion
}