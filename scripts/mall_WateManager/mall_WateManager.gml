// Feather ignore all

/// @desc Gestiona el estado y el flujo de una batalla.
/// @param {String} encounter_key La llave de la plantilla del encuentro.
/// @param {Struct.PartyGroup} player_group La instancia del grupo de jugadores.
function WateManager(_encounter_key, _player_group) constructor
{
    // --- Propiedades del Encuentro ---
    encounter_template = mall_get_wate_encounter(_encounter_key);
    player_group = _player_group;
    
    // Grupos de enemigos, cada uno con su propia mochila si se define
    enemy_groups = [];
    
    // --- Estado del Combate ---
    turn_queue = [];
    current_turn_index = 0;
    current_wave_index = 0;
    is_battle_active = false;
    
    // --- Eventos del Encuentro ---
    event_on_start =	"";
    event_on_end =		"";
	// Evento que se ejecuta para validar si se puede escapar, incluso si can_escape es true. Debe devolver un booleano.
	event_can_escape_check = ""; 
	// Se ejecuta cuando la huida tiene éxito.
	event_on_escape_success = "";
	// Se ejecuta cuando la huida falla.
	event_on_escape_fail = "";

	// Se ejecuta cada vez que una nueva entidad (ej: refuerzo) se añade al combate.
	event_on_entity_added = "";
	// Se ejecuta cada vez que una entidad es derrotada o eliminada del combate.
	event_on_entity_removed = "";
	
	// Define la lógica para crear la cola de turnos inicial.
	event_on_turn_order_create = "";
	// Se ejecuta al inicio de una nueva ronda de turnos.
	event_on_turn_start = "";	
	// Se ejecuta después de cada acción para reordenar o actualizar la cola de turnos.
	event_on_turn_update = "";
	// Se ejecuta cuando todas las entidades han tenido su turno en una ronda.
	event_on_turn_end = "";
	
	__LoadFunctions();

    #region MÉTODOS PRIVADOS
    
	/// @desc Cargar funciones.
	/// @ignore
	static __LoadFunctions = function()
	{
	    event_on_start =	mall_get_function(encounter_template[$ "event_on_start"] ?? "");
	    event_on_end =		mall_get_function(encounter_template[$ "event_on_end"] ?? "");

		// Evento que se ejecuta para validar si se puede escapar, incluso si can_escape es true. Debe devolver un booleano.
		event_can_escape_check =	__mall_get_function_check_true(encounter_template[$ "event_can_escape_check"] ?? "" ); 
		// Se ejecuta cuando la huida tiene éxito.
		event_on_escape_success =	mall_get_function(encounter_template[$ "event_on_escape_success"] ?? "" );
		// Se ejecuta cuando la huida falla.
		event_on_escape_fail =		mall_get_function(encounter_template[$ "event_on_escape_fail"] ?? "" );

		// Se ejecuta cada vez que una nueva entidad (ej: refuerzo) se añade al combate.
		event_on_entity_added =		mall_get_function(encounter_template[$ "event_on_entity_added"] ?? "" );
		// Se ejecuta cada vez que una entidad es derrotada o eliminada del combate.
		event_on_entity_removed =	mall_get_function(encounter_template[$ "event_on_entity_removed"] ?? "" );
	
		// Define la lógica para crear la cola de turnos inicial.
		event_on_turn_order_create =	mall_get_function(encounter_template[$ "event_on_turn_order_create"] ?? "" );
		// Se ejecuta al inicio de una nueva ronda de turnos.
		event_on_turn_start =			mall_get_function(encounter_template[$ "event_on_turn_start"] ?? "" );	
		// Se ejecuta después de cada acción para reordenar o actualizar la cola de turnos.
		event_on_turn_update =			mall_get_function(encounter_template[$ "event_on_turn_update"] ?? "" );	
		// Se ejecuta cuando todas las entidades han tenido su turno en una ronda.
		event_on_turn_end =				mall_get_function(encounter_template[$ "event_on_turn_end"] ?? "" ); 	
	}
	
    /// @desc (Privado) Procesa la siguiente oleada o grupo aleatorio del encuentro.
    /// @ignore
    static __ProcessNextWave = function()
    {
        if (current_wave_index >= array_length(encounter_template.groups))
        {
            // No hay más oleadas, la batalla ha sido ganada.
            __EndBattle(true);
            return;
        }
        
        var _group_data = encounter_template.groups[current_wave_index];
        var _group_template;
        
        // Determinar si es una llave a un grupo reutilizable o una definición directa
        if (is_string(_group_data) ) 
		{
            _group_template = mall_get_wate_group(_group_data);
        } 
		else 
		{
            _group_template = _group_data;
        }
        
        // Crear un nuevo PartyGroup para los enemigos de esta oleada
        var _new_enemy_group = new PartyGroup("WATE_ENEMIES_" + string(current_wave_index));
        
        // Crear y configurar la mochila para el grupo de enemigos
        if (variable_struct_exists(_group_template, "bag_template") ) 
        {
            var _bag_template_key = _group_template.bag_template;
            var _bag_template = pocket_bag_get(_bag_template_key);
            
            if (!is_undefined(_bag_template) ) 
            {
                // Llamar al método de la plantilla para crear una nueva instancia.
                _new_enemy_group.bag = _bag_template.CreateInstance(_new_enemy_group.key + "_bag");
            }
        }
        
        // Crear las instancias de los enemigos
        for (var i = 0; i < array_length(_group_template.positions); i++) 
		{
            var _pos_data = _group_template.positions[i];
            var _level = is_array(_pos_data.level)
                ? irandom_range(_pos_data.level[0], _pos_data.level[1])
                : _pos_data.level;
            
            var _enemy_inst = party_entity_create_instance(_pos_data.template_key, _level);
            
            // Equipar objetos específicos del encuentro
            if (variable_struct_exists(_pos_data, "slots") ) 
			{
                var _slots_to_equip = variable_struct_get_names(_pos_data.slots);
                for (var j = 0; j < array_length(_slots_to_equip); j++) 
				{
                    var _slot_key = _slots_to_equip[j];
                    _enemy_inst.SlotEquip(_slot_key, _pos_data.slots[$ _slot_key]);
                }
            }
            
            _new_enemy_group.Add(_enemy_inst);
			
			// Registrar la instancia globalmente
            // party_register_instance(_enemy_inst); 
        }
        
        array_push(enemy_groups, _new_enemy_group);
        current_wave_index++;
        
        __CreateTurnOrder();
        mall_broadcast_post("WAVE_START", { 
			wave_index: current_wave_index, 
			enemies: _new_enemy_group 
		});
    }
    
    /// @desc (Privado) Crea o recrea la cola de turnos.
    /// @ignore
    static __CreateTurnOrder = function()
    {
		var _all_entities = [];
        array_copy(_all_entities, 0, player_group.entities, 0, array_length(player_group.entities) );
        
		for (var i = 0; i < array_length(enemy_groups); i++) 
		{
            var _enemy_entities = enemy_groups[i].entities;
            array_copy(_all_entities, array_length(_all_entities), _enemy_entities, 0, array_length(_enemy_entities));
        }
        
        // Ejecutar funcion.
        if (is_callable(event_on_turn_order_create) ) 
		{
            turn_queue = event_on_turn_order_create(_all_entities);
        } 
		else 
		{
            // Lógica por defecto si no se especifica un evento (ej: orden de añadido)
            turn_queue = _all_entities;
        }
		
        current_turn_index = 0;
    }
    
    /// @desc (Privado) Comprueba las condiciones de victoria o derrota.
    /// @ignore
    static __CheckEndConditions = function()
    {
        // Condición de Derrota: Si no quedan jugadores.
        if (player_group.Size() == 0) 
        {
            __EndBattle(false);
            return true; // La batalla terminó.
        }
        
        // Obtener el grupo de enemigos de la oleada actual.
        if (array_length(enemy_groups) == 0) {
            // Esto puede pasar al inicio, antes de que se procese la primera oleada.
            return false;
        }
        var _current_enemy_group = enemy_groups[array_length(enemy_groups) - 1];
        
        // Si la oleada actual todavía tiene enemigos, la batalla continúa.
        if (_current_enemy_group.Size() > 0) {
            return false;
        }
        
        // Si la oleada actual ha sido derrotada...
        
        // Comprobar si era la última oleada definida en la plantilla.
        if (current_wave_index >= array_length(encounter_template.groups))
        {
            // Victoria: Era la última oleada y no quedan enemigos.
            __EndBattle(true);
            return true; // La batalla terminó.
        }
        else
        {
            // Avanzar a la siguiente oleada.
            __ProcessNextWave();
            return true; // El estado de la batalla cambió (nueva oleada), por lo que el flujo de turnos debe reiniciarse.
        }
    }
	
    /// @desc (Privado) Finaliza la batalla.
    /// @param {Bool} player_won True si el jugador ganó.
    /// @ignore
    static __EndBattle = function(_player_won)
    {
        is_battle_active = false;
        if (_player_won) 
		{
            mall_broadcast_post("BATTLE_VICTORY", { encounter: self });
            if (is_callable(event_on_end) ) event_on_end(self);
        } 
		else 
		{
            mall_broadcast_post("BATTLE_DEFEAT", { encounter: self });
        }
        
        // Limpiar instancias de enemigos, etc.
        // ...
        
		// Liberar el gestor
        Wate.manager = undefined;
    }
    
    #endregion
    
    #region CICLO DE COMBATE
    
    /// @desc Inicia la batalla.
    static StartBattle = function()
    {
        is_battle_active = true;
        mall_broadcast_post("BATTLE_START", { encounter: self });
        if (is_callable(event_on_start)) event_on_start(self);
        
        __ProcessNextWave();
        NextTurn();
    }
    
    /// @desc Avanza al siguiente turno en la cola.
    static NextTurn = function()
    {
        if (!is_battle_active) return;
        // Comprobar si la batalla terminó
        if (__CheckEndConditions() ) return;
        
        if (current_turn_index >= array_length(turn_queue) ) {
            // Fin de la ronda, crear nuevo orden de turnos
            __CreateTurnOrder();
            mall_broadcast_post("ROUND_START", { turn: turn_queue });
        }
        
        var _current_entity = turn_queue[current_turn_index];
        _current_entity.OnTurnStart();
        
        mall_broadcast_post("TURN_START", { entity: _current_entity, manager: self });
        
        // El manager ahora espera a que un sistema externo (UI o IA) llame a ExecuteAction
    }
    
    /// @desc Ejecuta una acción seleccionada y avanza al siguiente turno.
    /// @param {Struct.WateAction} action La acción a ejecutar.
    static ExecuteAction = function(_action)
    {
        if (!is_battle_active) return;
        
        var _caster = turn_queue[current_turn_index];
        
        // Si no hay acción o la entidad no puede actuar, pasar el turno
        if (is_undefined(_action) || !_caster.CanAct()) {
            _caster.OnTurnEnd();
            current_turn_index++;
            NextTurn();
            return;
        }
        
        var _command = _action.source;
        var _targets = _action.targets;
        
        var _check_func = mall_get_function(_command.event_check);
        var _execute_func = mall_get_function(_command.event_execute);
        var _fail_func = mall_get_function(_command.event_fail);
        
        var _action_results = [];
        
        for (var i = 0; i < array_length(_targets); i++)
        {
            var _target = _targets[i];
            var _hit = is_callable(_check_func) ? _check_func(_caster, _target, _command.params) : true;
            
            if (_hit && is_callable(_execute_func)) {
                var _result = _execute_func(_caster, _target, _command.params);
                array_push(_action_results, { target: _target, result: _result, hit: true });
            } 
            else if (!_hit && is_callable(_fail_func)) {
                var _result = _fail_func(_caster, _target, _command.params);
                array_push(_action_results, { target: _target, result: _result, hit: false });
            }
        }
        
        mall_broadcast_post("ACTION_EXECUTED", { 
            caster: _caster, 
            command: _command, 
            results: _action_results 
        });
        
        _caster.OnTurnEnd();
        current_turn_index++;
        NextTurn();
    }
    
    #endregion
}

// -----------------------------------------------------------------------------
// API PÚBLICA PARA MANEJAR EL COMBATE
// -----------------------------------------------------------------------------

/// @desc Inicia un nuevo combate.
/// @param {String} encounter_key La llave de la plantilla del encuentro.
/// @param {Struct.PartyGroup} player_group La instancia del grupo de jugadores.
function wate_start_battle(_encounter_key, _player_group)
{
    if (!is_undefined(Systemall.__wate_manager) ) 
	{
        show_debug_message("[Wate] Error: Ya hay una batalla en curso.");
        return;
    }
    
    Systemall.__wate_manager = new WateManager(_encounter_key, _player_group);
    Systemall.__wate_manager.StartBattle();
}

/// @desc Devuelve el gestor de combate actual.
/// @return {Struct.WateManager}
function wate_get_manager()
{
    return Systemall.__wate_manager;
}

/// @desc Devuelve la plantilla de un encuentro.
function mall_get_wate_encounter(_key) 
{
	return Systemall.__wate.encounters[$ _key]; 
}

/// @desc Devuelve la plantilla de un grupo de enemigos reutilizable.
function mall_get_wate_group(_key) 
{
	return Systemall.__wate.groups[$ _key]; 
}
