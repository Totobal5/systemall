/// @desc Starts a new battle instance.
/// @param {String} encounter_key Encounter template key.
/// @param {Struct.MallEntityGroup} player_group Player group instance.
function mall_battle_start_battle(_encounter_key, _player_group)
{
	if (!is_undefined(__Systemall.__battle_manager) ) 
	{
		__mall_error("Cannot start battle: another battle is already active.");
		exit;
	}
	// Create and store battle manager instance for global access.
	// Execute start battle logic immediately to trigger any start-of-battle events and initialize first turn.
	__Systemall.__battle_manager = new MallBattleManager(_encounter_key, _player_group).StartBattle();
}

/// @desc Returns current battle manager instance.
/// @return {Struct.MallBattleManager}
function mall_battle_get_manager()
{
	return (__Systemall.__battle_manager);
}