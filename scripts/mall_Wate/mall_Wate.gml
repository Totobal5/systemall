/// @desc Encapsula una acción de combate completa, estandarizando la comunicación
///      entre el selector de acción (IA o UI) y el gestor de combate.
/// @param {Struct.PartyEntity} caster La entidad que realiza la acción.
/// @param {Struct.DarkCommand / Struct.PocketItem} source El comando o item que se usa.
/// @param {Array<Struct.PartyEntity>} targets Los objetivos de la acción.
function WateAction(_caster, _source, _targets) constructor
{
    /// @desc La entidad que realiza la acción.
    caster = _caster;
    
    /// @desc La plantilla del comando o item que se está utilizando.
    source = _source;
    
    /// @desc Un array con las instancias de las entidades objetivo.
    targets = _targets;
}


/// @desc Obtiene una lista de objetivos válidos para un comando.
/// @param {Struct.PartyEntity} caster La entidad que lanza el comando.
/// @param {Struct.DarkCommand} command La plantilla del comando.
/// @param {Struct} battle_context El contexto de la batalla { player_group: PartyGroup, enemy_group: PartyGroup }.
/// @return {Array<Struct.PartyEntity>}
function wate_get_valid_targets(_caster, _command, _battle_context)
{
    var _valid_targets = [];
    var _player_group = _battle_context.player_group;
    var _enemy_group = _battle_context.enemy_group;
    
    var _allies =  (_caster.faction == "PLAYER") ? _player_group.entities : _enemy_group.entities;
    var _enemies = (_caster.faction == "PLAYER") ? _enemy_group.entities : _player_group.entities;
    
    // 1. Construir la lista de objetivos potenciales
    var _potential_targets = [];
    if (_command.can_target_self) {
        array_push(_potential_targets, _caster);
    }
    if (_command.can_target_ally) {
        array_copy(_potential_targets, array_length(_potential_targets), _allies, 0, array_length(_allies));
    }
    if (_command.can_target_enemy) {
        array_copy(_potential_targets, array_length(_potential_targets), _enemies, 0, array_length(_enemies));
    }
    
    // 2. Filtrar la lista (eliminar duplicados y objetivos no válidos como los derrotados)
    for (var i = 0; i < array_length(_potential_targets); i++)
    {
        var _target = _potential_targets[i];
        
        // (Aquí se podría añadir lógica más compleja, como no poder curar a alguien con vida llena)
        var _is_alive = _target.StatGet("EN").current_value > 0;
        
        if (_is_alive && !array_contains(_valid_targets, _target))
        {
            array_push(_valid_targets, _target);
        }
    }
    
    return _valid_targets;
}