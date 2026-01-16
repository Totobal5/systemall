/// @desc (TARGETING) Devuelve al propio lanzador.
function AI_TARGET_Self(_caster, _battle_context)
{
    return [_caster];
}

/// @desc (TARGETING) Devuelve un enemigo vivo al azar.
function AI_TARGET_Random_Enemy(_caster, _battle_context)
{
    var _enemies = (_caster.faction == "PLAYER") 
        ? _battle_context.enemy_group.entities 
        : _battle_context.player_group.entities;
        
    var _living_enemies = array_filter(_enemies, function(entity) {
        return entity.StatGet("EN").current_value > 0;
    });
    
    if (array_length(_living_enemies) > 0) {
        var _rand_index = irandom(array_length(_living_enemies) - 1);
        return [_living_enemies[_rand_index]];
    }
    
    return [];
}

/// @desc (TARGETING) Devuelve al aliado (o a sí mismo) con el porcentaje de HP más bajo.
function AI_TARGET_Ally_With_Lowest_HP(_caster, _battle_context)
{
    var _allies = (_caster.faction == "PLAYER") 
        ? _battle_context.player_group.entities 
        : _battle_context.enemy_group.entities;
        
    var _lowest_hp_ally = undefined;
    var _lowest_hp_percent = 101;
    
    for (var i = 0; i < array_length(_allies); i++) 
	{
        var _ally = _allies[i];
        var _hp_stat = _ally.StatGet("EN");
        if (_hp_stat.current_value > 0) {
            var _hp_percent = (_hp_stat.current_value / _hp_stat.control_value) * 100;
            if (_hp_percent < _lowest_hp_percent) 
			{
                _lowest_hp_percent = _hp_percent;
                _lowest_hp_ally = _ally;
            }
        }
    }
    
    return is_undefined(_lowest_hp_ally) ? [] : [_lowest_hp_ally];
}

/// @desc (TARGETING) Devuelve a todos los enemigos vivos.
function AI_TARGET_All_Enemies(_caster, _battle_context)
{
    var _enemies = (_caster.faction == "PLAYER") 
        ? _battle_context.enemy_group.entities 
        : _battle_context.player_group.entities;
        
    return array_filter(_enemies, function(entity) {
        return entity.StatGet("EN").current_value > 0;
    });
}

/// @desc (TARGETING) Devuelve a todos los aliados vivos (incluido el lanzador).
function AI_TARGET_All_Allies(_caster, _battle_context)
{
    var _allies = (_caster.faction == "PLAYER") 
        ? _battle_context.player_group.entities 
        : _battle_context.enemy_group.entities;
        
    return array_filter(_allies, function(entity) {
        return entity.StatGet("EN").current_value > 0;
    });
}