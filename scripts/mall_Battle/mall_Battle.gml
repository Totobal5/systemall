/// @desc Creates encounter and group templates from a Battle data struct.
/// @param {Struct} data Full Battle file payload.
function mall_create_battle_from_data(_data)
{
	/// @ignore
	static __groups = function(_key, _value) { __Systemall.__battle[$ "groups"][$ _key] = _value; }

	/// @ignore
	static __encounters = function(_key, _value) 
	{ 
		__Systemall.__battle.encounters[$ _key] = _value;
		array_push(__Systemall.__battle_keys, _key); 
	}

	if (!__mall_validate_registry_args("mall_create_battle_from_data", undefined, _data, undefined, "Battle", false)) return;
	
	if (!struct_exists(__Systemall.__battle, "groups") ) { __Systemall.__battle[$ "groups"] = {}; }

	// Load reusable enemy groups.
	if (struct_exists(_data, "groups") ) { struct_foreach(_data[$ "groups"], __groups); }
	// Load battle encounters.
	if (struct_exists(_data, "encounters") ) { struct_foreach(_data[$ "encounters"], __encounters); }
}

/// @desc Gets valid command targets using a custom filter callable.
/// @param {Struct.MallEntity} caster Entity casting the command.
/// @param {Struct.MallCommand} command Command template.
/// @param {{player_group: MallEntityGroup, enemy_group: MallEntityGroup}} battle_context Battle context
/// @param {Function} filter Callable that filters potential targets.
/// @return {Array<Struct.MallEntity>}
function mall_battle_get_valid_targets(_caster, _command, _battle_context, _filter)
{
	if (!is_callable(_filter) )
	{
		__mall_error("mall_battle_get_valid_targets expected a callable filter.");
		return [];
	}

	if (is_undefined(_caster) || is_undefined(_command) || !is_struct(_battle_context))
	{
		__mall_error("mall_battle_get_valid_targets received invalid arguments.");
		return [];
	}

	var _valid_targets = [];
	var _player_group = _battle_context[$ "player_group"];
	var _enemy_group = _battle_context[$ "enemy_group"];

	var _allies =  (_caster.faction == "PLAYER") ? (_player_group[$ "entities"] ?? []) : (_enemy_group[$ "entities"] ?? []);
	var _enemies = (_caster.faction == "PLAYER") ? (_enemy_group[$ "entities"] ?? []) : (_player_group[$ "entities"] ?? []);

	// Build potential target list.
	var _potential_targets = [];
	if (_command.can_target_self) { array_push(_potential_targets, _caster); }

	// Copy allies only if command supports ally targeting.
	if (_command.can_target_ally)
	{
		array_copy(_potential_targets, array_length(_potential_targets), _allies, 0, array_length(_allies));
	}

	// Copy enemies only if command supports enemy targeting.
	if (_command.can_target_enemy)
	{
		array_copy(_potential_targets, array_length(_potential_targets), _enemies, 0, array_length(_enemies));
	}

	// Filter potential list (for example, remove duplicates/defeated targets).
	return (_filter(_potential_targets, _valid_targets) );
}

/// @desc Starts a new battle instance.
/// @param {String} _encounter_key Encounter template key.
/// @param {Struct.MallEntityGroup} _player_group Player group instance.
function mall_battle_start_battle(_encounter_key, _player_group)
{
	if (!is_undefined(__Systemall.__battle_manager) ) 
	{
		__mall_error("Cannot start battle: another battle is already active.");
		exit;
	}
	// Create and store battle manager instance for global access.
	// Execute start battle logic immediately to trigger any start-of-battle events and initialize first turn.
	__Systemall.__battle_manager = new BattleManager(_encounter_key, _player_group).StartBattle();
}

/// @desc Returns current battle manager instance.
/// @return {Struct.BattleManager}
function mall_battle_get_manager()
{
	return (__Systemall.__battle_manager);
}

/// @desc Return a reusable encounter template.
/// @param {String} key Encounter template key.
/// @return {Struct.BattleEncounter}
function mall_get_battle_encounter(_key) 
{
	return __Systemall.__battle.encounters[$ _key]; 
}

/// @desc Return a reusable enemy group template.
/// @param {String} key Group template key.
/// @return {Struct.BattleGroup}
function mall_get_battle_group(_key) 
{
	var _groups = __Systemall.__battle[$ "groups"] ?? {};
	return _groups[$ _key]; 
}