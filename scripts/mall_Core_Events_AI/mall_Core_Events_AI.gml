/// Declare default AI behavior functions here.

/// @ignore
/// @desc Returns true when entity is alive based on EN stat.
function __AI_IsAlive(_entity)
{
    if (is_undefined(_entity) || !is_struct(_entity)) return false;

    var _en = _entity.StatGet("EN");
    if (is_undefined(_en) || !is_struct(_en)) return false;

    return (_en.current_value > 0);
}

/// @ignore
/// @desc Returns allies or enemies array from battle context. Returns [] when unavailable.
function __AI_GetSide(_caster, _battle_context, _want_allies)
{
    if (is_undefined(_battle_context) || !is_struct(_battle_context)) return [];

    var _is_player = (_caster.faction == "PLAYER");
    if (_want_allies)
    {
        var _ally_group = _is_player ? (_battle_context[$ "player_group"] ?? undefined) : (_battle_context[$ "enemy_group"] ?? undefined);
        if (is_undefined(_ally_group) || !is_struct(_ally_group)) return [];
        return _ally_group.entities ?? [];
    }

    var _enemy_group = _is_player ? (_battle_context[$ "enemy_group"] ?? undefined) : (_battle_context[$ "player_group"] ?? undefined);
    if (is_undefined(_enemy_group) || !is_struct(_enemy_group)) return [];
    return _enemy_group.entities ?? [];
}

/// @desc (TARGETING) Returns the caster itself.
function AI_TARGET_Self(_caster, _battle_context)
{
    return [_caster];
}

/// @desc (TARGETING) Returns one random living enemy.
function AI_TARGET_Random_Enemy(_caster, _battle_context)
{
    var _enemies = __AI_GetSide(_caster, _battle_context, false);
        
    var _living_enemies = array_filter(_enemies, function(_entity) {
        return __AI_IsAlive(_entity);
    });
    
    if (array_length(_living_enemies) > 0) {
        var _rand_index = irandom(array_length(_living_enemies) - 1);
        return [_living_enemies[_rand_index]];
    }
    
    return [];
}

/// @desc (TARGETING) Returns the ally (or self) with the lowest HP percentage.
function AI_TARGET_Ally_With_Lowest_HP(_caster, _battle_context)
{
    var _allies = __AI_GetSide(_caster, _battle_context, true);
        
    var _lowest_hp_ally = undefined;
    var _lowest_hp_percent = 101;
    
    for (var i = 0; i < array_length(_allies); i++) 
	{
        var _ally = _allies[i];
        var _hp_stat = _ally.StatGet("EN");
        if (is_struct(_hp_stat) && _hp_stat.current_value > 0) {
            var _hp_max = max(1, _hp_stat.control_value);
            var _hp_percent = (_hp_stat.current_value / _hp_max) * 100;
            if (_hp_percent < _lowest_hp_percent) 
			{
                _lowest_hp_percent = _hp_percent;
                _lowest_hp_ally = _ally;
            }
        }
    }
    
    return is_undefined(_lowest_hp_ally) ? [] : [_lowest_hp_ally];
}

/// @desc (TARGETING) Returns all living enemies.
function AI_TARGET_All_Enemies(_caster, _battle_context)
{
    var _enemies = __AI_GetSide(_caster, _battle_context, false);
        
    return array_filter(_enemies, function(_entity) {
        return __AI_IsAlive(_entity);
    });
}

/// @desc (TARGETING) Returns all living allies (including caster).
function AI_TARGET_All_Allies(_caster, _battle_context)
{
    var _allies = __AI_GetSide(_caster, _battle_context, true);
        
    return array_filter(_allies, function(_entity) {
        return __AI_IsAlive(_entity);
    });
}