/// @desc Manages battle state and combat flow.
/// @param {String} _encounter_key Encounter template key.
/// @param {Struct.MallEntityGroup} _player_group Player party group instance.
function BattleManager(_encounter_key, _player_group) constructor
{
	// --- Encounter data ---
	encounter_template = mall_get_battle_encounter(_encounter_key);
	player_group = _player_group;

	if (is_undefined(encounter_template))
	{
		__mall_error($"BattleManager could not find encounter template '{_encounter_key}'.");
		exit;
	}
	
	// Enemy groups, each with its own bag if configured.
	enemy_groups = [];
	
	// --- Battle runtime state ---
	turn_queue = [];
	current_turn_index = 0;
	current_wave_index = 0;
	is_battle_active = false;
	
	#region EVENTS
	// Runs when battle starts.
	event_on_start = "";
	// Runs when battle ends, receiving rewards if player won.
	event_on_end = "";
	// Validates whether escape is allowed (must return Bool).
	event_can_escape_check = ""; 
	// Runs on successful escape.
	event_on_escape_success = "";
	// Runs on failed escape.
	event_on_escape_fail = "";

	// Runs whenever a new entity is added to battle.
	event_on_entity_added = "";
	// Runs whenever an entity is defeated/removed from battle.
	event_on_entity_removed = "";
	
	// Defines logic to build initial turn order.
	event_on_turn_order_create = "";
	// Runs at start of a new turn round.
	event_on_turn_start = "";	
	// Runs after each action to reorder/update turn queue.
	event_on_turn_update = "";
	// Runs when all entities have completed one round.
	event_on_turn_end = "";
	
	__LoadFunctions();

	#endregion

	#region PRIVATE METHODS
	
	/// @ignore
	/// @desc Loads encounter event function references.
	static __LoadFunctions = function()
	{
		event_on_start = mall_get_event(encounter_template[$ "event_on_start"] ?? "");
		event_on_end = mall_get_event(encounter_template[$ "event_on_end"] ?? "");

		// Escape validation event (must return Bool).
		event_can_escape_check = __mall_get_event_check_true(encounter_template[$ "event_can_escape_check"] ?? "" ); 
		// Escape success event.
		event_on_escape_success = mall_get_event(encounter_template[$ "event_on_escape_success"] ?? "");
		// Escape fail event.
		event_on_escape_fail = mall_get_event(encounter_template[$ "event_on_escape_fail"] ?? "");

		// Entity add/remove events.
		event_on_entity_added = mall_get_event(encounter_template[$ "event_on_entity_added"] ?? "");
		event_on_entity_removed = mall_get_event(encounter_template[$ "event_on_entity_removed"] ?? "");

		// Turn queue events.
		event_on_turn_order_create = mall_get_event(encounter_template[$ "event_on_turn_order_create"] ?? "");
		event_on_turn_start = mall_get_event(encounter_template[$ "event_on_turn_start"] ?? "");
		event_on_turn_update = mall_get_event(encounter_template[$ "event_on_turn_update"] ?? "");
		event_on_turn_end = mall_get_event(encounter_template[$ "event_on_turn_end"] ?? "");
	}
	
	/// @ignore
	/// @desc Processes the next encounter wave or reusable enemy group.
	static __ProcessNextWave = function()
	{
		// No more waves means player victory.
		var _encounter_groups = encounter_template[$ "groups"] ?? [];
		if (current_wave_index >= array_length(_encounter_groups))
		{
			__EndBattle(true);
			exit;
		}
		
		var _group_data = _encounter_groups[current_wave_index];
		// Resolve reusable group key or inline group definition.
		var _group_template = (is_string(_group_data) ) ? mall_get_battle_group(_group_data) : _group_data;
		if (!is_struct(_group_template))
		{
			__mall_error($"Invalid wave group definition at index {current_wave_index}.");
			__EndBattle(false);
			exit;
		}
		
		// Create enemy group instance for this wave.
		var _new_enemy_group = new MallEntityGroup("BATTLE_ENEMIES_" + string(current_wave_index));
		
		// Create and configure enemy group bag when defined.
		if (struct_exists(_group_template, "bag_template") ) 
		{
			var _bag_template_key = _group_template[$ "bag_template"];
			var _bag_template = mall_get_bag(_bag_template_key);
			
			if (!is_undefined(_bag_template) ) 
			{
				// Create a new bag instance from template.
				var _create_bag_instance = _bag_template[$ "CreateInstance"];
				if (is_callable(_create_bag_instance))
				{
					_new_enemy_group.bag = _create_bag_instance(_new_enemy_group.key + "_bag");
				}
			}
		}
		
		// Create enemy instances.
		var _group_positions = _group_template[$ "positions"] ?? [];
		var _pos_data_size = array_length(_group_positions);
		for (var i = 0; i < _pos_data_size; i++) 
		{
			var _pos_data = _group_positions[i];
			var _level = is_array(_pos_data.level) ? irandom_range(_pos_data.level[0], _pos_data.level[1]) : _pos_data.level;
			
			var _enemy_inst = mall_entity_create_instance(_pos_data.template_key, _level);
			if (is_undefined(_enemy_inst))
			{
				__mall_alert($"__ProcessNextWave: skipping position {i} — entity template '{_pos_data.template_key}' could not be created.");
				continue;
			}
			
			// Equip encounter-specific items.
			if (struct_exists(_pos_data, "slots") ) 
			{
				var _slots_to_equip = struct_get_names(_pos_data.slots);
				var _slots_to_equip_size = array_length(_slots_to_equip);
				var j = 0; repeat (_slots_to_equip_size)
				{
					var _slot_key = _slots_to_equip[j++];
					_enemy_inst.SlotEquip(_slot_key, _pos_data.slots[$ _slot_key]);
				}
			}
			
			// Register instance.
			_new_enemy_group.Add(_enemy_inst);
			__mall_register_instance(_enemy_inst); 
		}
		
		array_push(enemy_groups, _new_enemy_group);
		current_wave_index++;
		
		__CreateTurnOrder();
		mall_broadcast_post("WAVE_START", { 
			wave_index: current_wave_index, 
			enemies: _new_enemy_group 
		});
	}
	
	/// @ignore
	/// @desc Creates or rebuilds the turn queue.
	static __CreateTurnOrder = function()
	{
		var _all_entities = [];
		array_copy(_all_entities, 0, player_group.entities, 0, array_length(player_group.entities) );
		
		var _enemy_groups_size = array_length(enemy_groups);
		var i = 0; repeat (_enemy_groups_size)
		{
			var _enemy_entities = enemy_groups[i++].entities;
			var _enemy_entities_size = array_length(_enemy_entities);
			if (_enemy_entities_size > 0)
			{
				array_copy(_all_entities, array_length(_all_entities), _enemy_entities, 0, _enemy_entities_size);
			}
		}

		// Allow custom event to alter or fully build turn order.
		turn_queue = is_callable(event_on_turn_order_create) ? event_on_turn_order_create(_all_entities) : _all_entities;
		current_turn_index = 0;
	}
	
	/// @ignore
	/// @desc Checks victory/defeat conditions.
	static __CheckEndConditions = function()
	{
		// Defeat condition: no players remaining.
		if (player_group.Size() == 0) 
		{
			__EndBattle(false);
			// Battle ended.
			return true;
		}
		
		// Read current enemy wave state.
		if (array_length(enemy_groups) == 0) { return false; }
		
		// If current wave still has enemies, battle continues.
		var _current_enemy_group = enemy_groups[array_length(enemy_groups) - 1];
		if (_current_enemy_group.Size() > 0) { return false; }

		var _encounter_groups = encounter_template[$ "groups"] ?? [];
		if (current_wave_index >= array_length(_encounter_groups))
		{
			// Victory: last configured wave cleared.
			__EndBattle(true);
			// Battle ended.
			return true;
		}
		else
		{
			// Advance to next wave.
			__ProcessNextWave();
			// Battle state changed (new wave), turn flow must restart.
			return true;
		}
	}
	
	/// @ignore
	/// @desc Ends battle and dispatches rewards when applicable.
	/// @param {Bool} _player_won True if player won.
	static __EndBattle = function(_player_won)
	{
		is_battle_active = false;
		
		if (_player_won) 
		{
			var _rewards = __CalculateRewards();
			mall_broadcast_post("BATTLE_VICTORY", { encounter: self, rewards: _rewards });
			
			if (is_callable(event_on_end) ) event_on_end(self, _rewards);
		}
		else
		{
			mall_broadcast_post("BATTLE_DEFEAT", { encounter: self });
		}
		
		__Systemall.__battle_manager = undefined;
	}
	
	/// @ignore
	/// @desc Calculates EXP and loot from all defeated enemies.
	static __CalculateRewards = function()
	{
		static __default_loot = [0, 0];
		var _end_rewards = { exps: 0, gold: 0, items: {} };
		
		// Iterate all enemy groups that participated in battle.
		var _enemy_groups_size = array_length(enemy_groups);
		for (var i = 0; i < _enemy_groups_size; i++) 
		{
			var _group = enemy_groups[i];
			// Returns defeated enemies for this wave.
			var _defeated_entities = _group.GetDefeated();
			var _defeated_size = array_length(_defeated_entities);
			for (var j = 0; j < _defeated_size; j++)
			{
				var _entity = _defeated_entities[j];
				
				// Read entity drops.
				var _drops = _entity.GetDrops();
				
				// Add EXP.
				_end_rewards.exps += _drops.exps;
				
				// Resolve loot table gold roll.
				var _loot_table = mall_get_loot_table(_entity.loot_table_key);
				if (!is_undefined(_loot_table) ) 
				{
					var _gold = _loot_table[$ "gold_drop"] ?? __default_loot;
					_end_rewards.gold += irandom_range(_gold[0], _gold[1]);
				}
				
				// Merge item drops.
				var _drops_items = _drops.items;
				var _drops_size = array_length(_drops_items);
				for (var k = 0; k < _drops_size; k++) 
				{
					var _drop_item = _drops_items[k];
					if (struct_exists(_end_rewards.items, _drop_item.key) ) 
					{
						_end_rewards.items[$ _drop_item.key] += _drop_item.quantity;
					} 
					else 
					{
						_end_rewards.items[$ _drop_item.key] = _drop_item.quantity;
					}
				}
			}
		}
		
		return _end_rewards;
	}
	
	#endregion
	
	#region BATTLE FLOW
	
	/// @desc Starts battle flow.
	/// @returns {Struct.BattleManager} Self reference for chaining.
	static StartBattle = function()
	{
		is_battle_active = true;
		mall_broadcast_post("BATTLE_START", { encounter: self });
		// Call start event if defined.
		if (is_callable(event_on_start) ) event_on_start(self);
		
		__ProcessNextWave();
		NextTurn();

		return self;
	}
	
	/// @desc Advances to next turn in queue.
	static NextTurn = function()
	{
		if (!is_battle_active) return;
		// Check battle end conditions.
		if (__CheckEndConditions() ) return;
		
		if (current_turn_index >= array_length(turn_queue) ) 
		{
			// End of round, rebuild turn order.
			__CreateTurnOrder();
			mall_broadcast_post("ROUND_START", { turn: turn_queue });
		}
		
		if (array_length(turn_queue) == 0)
		{
			__mall_alert("NextTurn: turn queue is empty after rebuild — ending battle.");
			__EndBattle(false);
			return;
		}
		
		var _current_entity = turn_queue[current_turn_index];
		_current_entity.OnTurnStart();
		
		mall_broadcast_post("TURN_START", { entity: _current_entity, manager: self });
		
		// Manager now waits for UI/AI system to call ExecuteAction.
	}
	
	/// @desc Runs selected action and advances turn.
	/// @param {Struct.BattleAction} _action Action to execute.
	static ExecuteAction = function(_action)
	{
		if (!is_battle_active) exit;
		
		var _caster = turn_queue[current_turn_index];
		
		// If no action or caster cannot act, skip turn.
		if (is_undefined(_action) || !_caster.CanAct() ) 
		{
			_caster.OnTurnEnd();
			current_turn_index++;
			NextTurn();

			exit;
		}
		
		var _command = _action.source;
		var _targets = _action.targets;
		
		if (!is_struct(_command))
		{
			__mall_error($"ExecuteAction: action.source is not a valid command struct (got {typeof(_command)}). Turn will be skipped.");
			_caster.OnTurnEnd();
			current_turn_index++;
			NextTurn();
			exit;
		}
		
		var _check_func =	__mall_get_event_check_true(_command.event_check);
		var _execute_func = mall_get_event(_command.event_execute);
		var _fail_func =	mall_get_event(_command.event_fail);
		
		var _action_results = [];
		var _targets_size = array_length(_targets);
		for (var i = 0; i < _targets_size; i++)
		{
			var _target = _targets[i];
			var _hit = is_callable(_check_func) ? _check_func(_caster, _target, _command.params) : true;
			
			if (_hit && is_callable(_execute_func) ) 
			{
				var _result = _execute_func(_caster, _target, _command.params);
				array_push(_action_results, { target: _target, result: _result, hit: true });
			} 
			else if (!_hit && is_callable(_fail_func) ) 
			{
				var _result = _fail_func(_caster, _target, _command.params);
				array_push(_action_results, { target: _target, result: _result, hit: false });
			}
		}
		
		mall_broadcast_post("ACTION_EXECUTED", { 
			caster: _caster, 
			command: _command, 
			results: _action_results 
		});
		
		// Check whether any target was defeated.
		var _action_results_size = array_length(_action_results);
		for (var i = 0; i < _action_results_size; i++)
		{
			var _res = _action_results[i];
			if (_res.result.WasAnyDefeated() ) 
			{
				var _defeated_entity = _res.target;
				
				// Find group that owns defeated entity.
				var _group_found = false;
				if (array_contains(player_group.entities, _defeated_entity) ) 
				{
					player_group.MarkAsDefeated(_defeated_entity);
					_group_found = true;
				} 
				else 
				{
					for (var j = 0; j < array_length(enemy_groups); j++) 
					{
						if (array_contains(enemy_groups[j].entities, _defeated_entity) ) 
						{
							enemy_groups[j].MarkAsDefeated(_defeated_entity);
							_group_found = true;

							break;
						}
					}
				}
				
				// If found and moved, remove from turn queue.
				if (_group_found) 
				{
					var _turn_index = array_get_index(turn_queue, _defeated_entity);
					if (_turn_index > -1) 
					{
						array_delete(turn_queue, _turn_index, 1);
						// If removed entity was current or prior index, adjust cursor.
						if (_turn_index <= current_turn_index) { current_turn_index--; }
					}
				}
			}
		}
		
		_caster.OnTurnEnd();
		current_turn_index++;
		NextTurn();
	}
	
	#endregion
}