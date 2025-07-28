enum MALL_STAT_TARGET
{
	PEAK,
	EQUIPMENT,
	CONTROL,
	CURRENT,
	LAST_CURRENT,
	LAST_PEAK,
}

/// @desc Representa la instancia de una estadística para una entidad.
function EntityStatInstance(_template) constructor
{
	// Referencia a la plantilla MallStat
    template = _template;
    
    // Valores de estado
    level = template.base_level;
    base_value = template.base_value;
    
    // Valores calculados
    peak_value = 0;      // Valor máximo con bonificaciones de nivel
    equipment_value = 0; // Valor con equipo
    control_value = 0;   // Valor final con estados alterados
    current_value = 0;   // Valor actual (ej: vida actual)
    
	last_peak_value = peak_value;
	last_current_value = current_value;
	
	// Events
    event_on_start =		mall_get_function( template[$ "event_on_start"] );
    event_on_end =			mall_get_function( template[$ "event_on_end"] );
    event_on_update =		mall_get_function( template[$ "event_on_update"] );
    event_on_level_up =		mall_get_function( template[$ "event_on_level_up"] );
    event_on_level_check =	__mall_get_function_check_true( template[$ "event_on_level_check"] );
    event_on_equip =		mall_get_function( template[$ "event_on_equip"] );
    event_on_desequip =		mall_get_function( template[$ "event_on_desequip"] );

    // Eventos de Turno
    event_on_turn_update =	mall_get_function( template[$ "event_on_turn_update"] );
    event_on_turn_start =	mall_get_function( template[$ "event_on_turn_start"] );
    event_on_turn_end =		mall_get_function( template[$ "event_on_turn_end"] );	
	
    /// @desc Recalcula el valor base de la estadística (peak_value).
    static Recalculate = function(_entity)
    {
		// Si sube de nivel de manera independiente.
		if (template.is_standalone_level)
		{
			var _level_up_check = Systemall.__functions[$ template.event_on_level_check];
			if (is_callable(_level_up_check) && !_level_up_check(_entity, self))
			{
				return;
			}
		}
			
        var _level_up_event = Systemall.__functions[$ template.event_on_level_up];
        if (is_callable(_level_up_event))
        {
            peak_value = _level_up_event(_entity, self);
        }
        else
        {
            peak_value = base_value;
        }
    }
	
	/// @desc Devuelve un valor específico de la estadística.
	static ReturnValueTarget = function(_numtarget)
	{
        switch (_numtarget) 
        {
            case MALL_STAT_TARGET.CURRENT:      return current_value;
            case MALL_STAT_TARGET.LAST_CURRENT: return last_current_value;
            case MALL_STAT_TARGET.PEAK:         return peak_value;
            case MALL_STAT_TARGET.LAST_PEAK:    return last_peak_value;
            case MALL_STAT_TARGET.EQUIPMENT:    return equipment_value;
            case MALL_STAT_TARGET.CONTROL:      return control_value;
        }
		
		return 0;
	}

	/// @desc Exporta el estado actual de la instancia de la estadística.
	static Export = function()
	{
		return {
			level: level,
			current_value: current_value,
			base_value: base_value
		};
	}
	
	/// @desc Importa el estado de la instancia de la estadística.
	static Import = function(_data)
	{
		level =			_data[$ "level"] ?? template.base_level;
		current_value = _data[$ "current_value"] ?? 0;
		base_value =	_data[$ "base_value"] ?? template.base_value;
	}
}

/// @desc Representa la instancia de un slot de equipo para una entidad.
function EntitySlotInstance(_template, _entity) constructor
{
	// Referencia a la plantilla MallSlot
    template = _template;
    
	// A quien pertenece esta instancia.
	parent_entity = _entity;
	
	max_items = template.max_items;
    equipped_items = [];
    last_equipped_items = equipped_items;
	
	// Crear nueva lista de objetos permitidos para equipar.
	permited = variable_clone(template.permited);
	
	is_active = !template.is_disabled;
	is_damaged = template.is_damaged;

    // La llave de otro slot del que depende para estar activo.
	depends_on_slot = template.depends_on_slot;

    // Asignar llaves de eventos
	event_on_start =	mall_get_function( template[$ "event_on_start"] );
	event_on_end =		mall_get_function( template[$ "event_on_end"] );
	event_on_update =	mall_get_function( template[$ "event_on_update"] );
    
	// Eventos de Turno
	event_on_turn_update =	mall_get_function( template[$ "event_on_turn_update"] );
	event_on_turn_start =	mall_get_function( template[$ "event_on_turn_start"] );
	event_on_turn_end =		mall_get_function( template[$ "event_on_turn_end"] );
    
	// Eventos de Equipamiento
	event_on_equip =	mall_get_function( template[$ "event_on_equip"] );
	event_on_desequip =	mall_get_function( template[$ "event_on_desequip"] );

	// Evento para comprobar el objeto que se le va a equipar.
	/// @param entity
	/// @param item
	event_can_equip =		__mall_get_function_check_true( template[$ "event_can_equip"] );
	
	// Evento para comprobar si el objeto se puede desequipar.
	/// @param entity
	/// @param item	
	event_can_desequip =	__mall_get_function_check_true( template[$ "event_can_desequip"] );
	
	// Evento al atacar
	event_on_attack =		mall_get_function( template[$ "event_on_attack"] );
	// Evento al ser atacado.
	event_on_defend =		mall_get_function( template[$ "event_on_defend"] );

	/// @desc Intenta equipar un objeto en este slot.
	/// @param {String} item_key La llave del objeto a equipar.
	/// @return {Struct} { success: bool }
	static Equip = function(_item_key)
	{
		var _result = { success: false };
		var _item_to_equip = pocket_item_get(_item_key);
		
		// 1. Validar que el item exista, sea permitido y que el slot no esté lleno.
		if (is_undefined(_item_to_equip) || !struct_exists(permited, _item_key) || array_length(equipped_items) >= template.max_items) 
		{
			return _result;
		}
		
		// 2. Comprobar si el nuevo objeto se puede equipar.
		var _can_equip_slot = event_can_equip(parent_entity, _item_to_equip);
		var _can_equip_item = _item_to_equip.event_can_equip(_item_to_equip, parent_entity);
		
		if (_can_equip_slot && _can_equip_item)
		{
			// --- Todas las comprobaciones pasaron, proceder con el equipamiento ---
			last_equipped_items = array_clone(equipped_items);
			array_push(equipped_items, _item_key);
			
			// Disparar eventos de equipamiento
			event_on_equip(parent_entity, _item_to_equip);
			_item_to_equip.event_on_equip(_item_to_equip, parent_entity);
			
			_result.success = true;
		}
		
		return _result;
	}
	
	/// @desc Intenta desequipar un objeto específico del slot.
	/// @param {String} item_key La llave del objeto a desequipar.
	/// @return {Struct} { success: bool, unequipped_item: string_or_undefined }
	static Desequip = function(_item_key)
	{
		var _result = { success: false, unequipped_item: undefined };
		var _item_to_remove = pocket_item_get(_item_key);
		var _item_index = array_get_index(equipped_items, _item_key);
 
		// 1. Validar que el objeto exista y esté en este slot.
		if (is_undefined(_item_to_remove) || _item_index == -1)
		{
			return _result;
		}

		// 2. Comprobar si el objeto se puede desequipar.
		var _can_desequip_slot = event_can_desequip(parent_entity, _item_to_remove);
		var _can_desequip_item = _item_to_remove.event_can_desequip(_item_to_remove, parent_entity);

		if (_can_desequip_slot && _can_desequip_item)
		{
			// --- Todas las comprobaciones pasaron, proceder con el desequipamiento ---
			_result.unequipped_item = _item_key;
			
			// Disparar eventos de desequipamiento
			event_on_desequip(parent_entity, _item_to_remove);
			_item_to_remove.event_on_desequip(_item_to_remove, parent_entity);
			
			// Limpiar el slot
			last_equipped_items = array_clone(equipped_items);
			array_delete(equipped_items, _item_index, 1);
			
			_result.success = true;
		}
		
		return _result;
	}

	/// @desc Exporta el estado actual de la instancia del slot.
	static Export = function()
	{
		var _this = self;
		return {
			equipped_items: _this.equipped_items,
			is_active: is_active
		};
	}
	
	/// @desc Importa el estado de la instancia del slot.
	static Import = function(_data)
	{
		equipped_items = _data[$ "equipped_items"] ?? [];
		is_active = _data[$ "is_active"] ?? !template.is_disabled;
	}
}

/// @desc Representa la instancia de un state para una entidad.
function EntityStateInstance(_template) constructor
{
	// Referencia a la plantilla MallState
	template = _template;
	
	// Valor booleano de estado actual de esta instancia
	boolean_value = template.boolean_value;
	
	// Array para contener las instancias de efectos activos
	effects = [];
	
	// Eventos (referencias a funciones ya cargadas)
	event_on_start =	mall_get_function( template.event_on_start );
	event_on_end =		mall_get_function( template.event_on_end );
	event_on_update =	mall_get_function( template.event_on_update );
	event_on_turn_update =	mall_get_function( template.event_on_turn_update );
	event_on_turn_start =	mall_get_function( template.event_on_turn_start );
	event_on_turn_end =		mall_get_function( template.event_on_turn_end );
	event_on_equip =		mall_get_function( template.event_on_equip );
	event_on_desequip =		mall_get_function( template.event_on_desequip );

	/// @desc Exporta el estado actual de la instancia del estado.
	static Export = function()
	{
		var _this = self;
		
		var _effects_export = [];
		for (var i = 0; i < array_length(effects); i++) 
		{
			array_push(_effects_export, effects[i].Export() );
		}
		
		return {
			boolean_value: _this.boolean_value,
			effects: _effects_export
		};
	}
	
	/// @desc Importa el estado de la instancia del estado.
	static Import = function(_data)
	{
		boolean_value = _data[$ "boolean_value"] ?? template.boolean_value;
		effects = [];
		
		var _effects_import = _data[$ "effects"] ?? [];
		for (var i = 0; i < array_length(_effects_import); i++) 
		{
			var _effect_data = _effects_import[i];
			var _effect_template = mall_get_dark(_effect_data.key);
			
			if (!is_undefined(_effect_template) ) 
			{
				var _effect_inst = new DarkEffectInstance(_effect_template);
				_effect_inst.Import(_effect_data);
				
				array_push(effects, _effect_inst);
			}
		}
	}
}

/// @desc El "cerebro" de una entidad, que toma decisiones basadas en un paquete de IA.
/// @param {Struct.PartyEntity} parent_entity La entidad que posee esta IA.
/// @param {String} ai_package_key La llave del paquete de IA a utilizar.
function EntityAIInstance(_parent_entity, _ai_package_key) constructor
{
    parent_entity = _parent_entity;
    
    // Lista final de reglas, aplanada y ordenada por prioridad.
    resolved_rules = [];
    
    // Aquí se podrían guardar variables de estado de la IA (ej: memoria de aggro)
    memory = {};
    
    /// @desc (Privado) Procesa un array de llaves de reglas y paquetes para construir una lista plana.
    /// @param {Array<String>} rules_array Array de llaves de reglas/paquetes.
    /// @return {Array<Struct>} Un array de structs de reglas.
    /// @ignore
    static __ResolveRules = function(_rules_array)
    {
        var _flat_list = [];
        for (var i = 0; i < array_length(_rules_array); i++)
        {
            var _key = _rules_array[i];
            
            // Comprobar si es una regla individual
            if (variable_struct_exists(Systemall.__ai_rules, _key))
            {
                array_push(_flat_list, Systemall.__ai_rules[$ _key]);
            }
            // Comprobar si es otro paquete de IA (herencia)
            else if (variable_struct_exists(Systemall.__ai_packages, _key))
            {
                var _nested_package = Systemall.__ai_packages[$ _key];
                var _nested_rules = __ResolveRules(_nested_package.rules);
                array_copy(_flat_list, array_length(_flat_list), _nested_rules, 0, array_length(_nested_rules));
            }
        }
        return _flat_list;
    }
    
    // --- Inicialización ---
    var _package = mall_get_ai_package(_ai_package_key);
    if (!is_undefined(_package))
    {
        resolved_rules = __ResolveRules(_package.rules);
        
        // Ordenar la lista final por prioridad, de mayor a menor.
        array_sort(resolved_rules, function(ruleA, ruleB)
		{
            return ruleB.priority - ruleA.priority;
        });
    }
    
    /// @desc Selecciona la mejor acción a realizar en el turno actual.
    /// @param {Struct} battle_context Un struct con información del combate (aliados, enemigos, etc.).
    /// @return {Struct} La acción a ejecutar, o undefined.
    static SelectAction = function(_battle_context)
    {
        for (var i = 0; i < array_length(resolved_rules); i++)
        {
            var _rule = resolved_rules[i];
            
            var _condition_func = mall_get_function(_rule.condition);
            
            // Si la condición de la regla se cumple...
            if (is_callable(_condition_func) && _condition_func(parent_entity, _battle_context))
            {
                // ...encontrar los objetivos...
                var _target_func = mall_get_function(_rule.target);
                var _targets = is_callable(_target_func) ? _target_func(parent_entity, _battle_context) : [];
                
                // ...y si se encontraron objetivos válidos...
                if (array_length(_targets) > 0)
                {
                    // ...ejecutar la acción.
                    var _action_func = mall_get_function(_rule.action);
                    if (is_callable(_action_func))
                    {
                        return _action_func(parent_entity, _targets);
                    }
                }
            }
        }
        
        // Si ninguna regla se cumplió, no hacer nada.
        return undefined;
    }
}

/// @desc Representa la instancia de un efecto activo en una entidad.
function DarkEffectInstance(_template) constructor
{
    static effect_counter = 0;
    
    id = $"{_template.key}_{effect_counter++}";
    template = _template;
    
    // Cada instancia tiene sus propios iteradores
    iterator_start = (new MallIterator() ).Configure(
        _template.iterator_start_config.duration ?? 1,
        _template.iterator_start_config.repeats ?? 0
    );
	
    iterator_end = (new MallIterator() ).Configure(
        _template.iterator_end_config.duration ?? 1,
        _template.iterator_end_config.repeats ?? 0
    );

	/// @desc Exporta el estado actual de la instancia del efecto.
	static Export = function()
	{
		var _this = self;
		return {
			key:	_this.template.key,
			id:		_this.id,
			iterator_start: _this.iterator_start.Export(),
			iterator_end:	_this.iterator_end.Export()
		};
	}
	
	/// @desc Importa el estado de la instancia del efecto.
	static Import = function(_data)
	{
		id = _data[$ "id"] ?? id;
		
		if (variable_struct_exists(_data, "iterator_start") ) 
		{
			iterator_start.Import(_data.iterator_start);
		}
		
		if (variable_struct_exists(_data, "iterator_end") ) 
		{
			iterator_end.Import(_data.iterator_end);
		}
	}
}

/// @desc Contenedor para los comandos de una entidad.
function EntityCommandsInstance() constructor
{
	// Struct que guarda las llaves de los comandos, agrupados por categoría.
	// Ejemplo: { "default": { "CMD_ATTACK": true }, "magic": { "CMD_FIRE": true } }
	commands = {};
	
	// Array con las llaves de las categorías para una iteración más sencilla.
	// Ejemplo: ["default", "magic"]
	commands_key = [];
}

/// @desc Representa una entidad jugable o no jugable en el sistema.
/// @param {String} template_key La llave de la plantilla a usar.
/// @param {String} instance_id Un ID único para esta instancia.
function PartyEntity(_template_key, _instance_id) : MallEvents(_template_key) constructor
{
	// -- Identificación --
	id = _instance_id;
	template_key = _template_key;
	group_key = "";

	// Flag para optimizar actualizaciones en bucle
	__is_updating_all_states = false;

	// --- Propiedades de Combate ---
	exp_drop = 0;
	drops = [];
	// Instancia del cerebro de la IA
	ai_instance = undefined;
	
	// Variables propias fuera del sistema Mall.
	vars = {};
	
	// --- Estado de la Instancia ---
	level = 1;
    stats = {};
    slots = {};
    states = {};
    commands = {};
	
	// -- Eventos --
	event_on_level_up = "";
    event_on_level_check = "";
	event_on_action_select = "";
	
	#region MÉTODOS PRIVADOS DE CARGA
	
	static __LoadFunctions = function(_template)
	{
		event_on_level_up = method(self, mall_get_function(_template.event_on_level_up) );
		event_on_level_check = method(self, __mall_get_function_check_true(_template.event_on_level_check) );
		
		event_on_action_select = method(self, mall_get_function(_template.event_on_action_select) );
	}
	
	/// @desc (Privado) Carga las instancias de stats y aplica los valores base.
	/// @param {Struct} _template La plantilla de la entidad.
	/// @ignore
	static __LoadStats = function(_template)
	{
        var _all_stat_keys = mall_get_stat_keys();
        for (var i = 0; i < array_length(_all_stat_keys); i++) {
            var _stat_key = _all_stat_keys[i];
            stats[$ _stat_key] = new EntityStatInstance(mall_get_stat(_stat_key));
        }
		
		if (variable_struct_exists(_template, "stats")) {
			var _template_stats = _template.stats;
			var _template_stat_keys = variable_struct_get_names(_template_stats);
			for (var i = 0; i < array_length(_template_stat_keys); i++) {
				var _stat_key = _template_stat_keys[i];
				if (struct_exists(stats, _stat_key)) {
					stats[$ _stat_key].base_value = _template_stats[$ _stat_key];
				}
			}
		}
	}
	
	/// @desc (Privado) Carga las instancias de slots, modifica permitidos y equipa items iniciales.
	/// @param {Struct} _template La plantilla de la entidad.
	/// @ignore
	static __LoadSlots = function(_template)
	{
        var _all_slot_keys = mall_get_slot_keys();
        for (var i = 0; i < array_length(_all_slot_keys); i++) {
            var _slot_key = _all_slot_keys[i];
            slots[$ _slot_key] = new EntitySlotInstance(mall_get_slot(_slot_key), self);
        }
		
        if (variable_struct_exists(_template, "slots")) {
            var _template_slots = _template.slots;
            var _template_slot_keys = variable_struct_get_names(_template_slots);
            for (var i = 0; i < array_length(_template_slot_keys); i++) {
                var _slot_key = _template_slot_keys[i];
                var _slot_data = _template_slots[$ _slot_key];
                
                if (is_struct(_slot_data)) {
                    if (variable_struct_exists(_slot_data, "permited")) {
                        var _permited_mods = _slot_data.permited;
                        for (var j = 0; j < array_length(_permited_mods); j++) {
                            var _mod_string = _permited_mods[j];
                            var _prefix = string_char_at(_mod_string, 1);
                            var _key = string_delete(_mod_string, 1, 1);
                            
                            if (_prefix == "+") { SlotPermitedAdd(_slot_key, _key); } 
							else if (_prefix == "-") { SlotPermitedRemove(_slot_key, _key); }
                        }
                    }
                    if (variable_struct_exists(_slot_data, "equip")) {
                        var _to_equip = _slot_data.equip;
                        if (is_array(_to_equip)) {
                            for (var j = 0; j < array_length(_to_equip); j++) { SlotEquip(_slot_key, _to_equip[j]); }
                        } else { SlotEquip(_slot_key, _to_equip); }
                    }
                } else {
                    SlotEquip(_slot_key, _slot_data);
                }
            }
        }
	}
	
	/// @desc (Privado) Carga las instancias de states.
	/// @param {Struct} _template La plantilla de la entidad.
	/// @ignore
	static __LoadStates = function(_template)
	{
        var _all_state_keys = mall_get_state_keys();
        for (var i = 0; i < array_length(_all_state_keys); i++) {
            var _state_key = _all_state_keys[i];
            states[$ _state_key] = new EntityStateInstance(mall_get_state(_state_key));
        }
	}
	
	/// @desc (Privado) Carga los comandos desde la plantilla de la entidad.
	/// @param {Struct} _template La plantilla de la entidad.
	/// @ignore
	static __LoadCommands = function(_template)
	{
        commands = new EntityCommandsInstance();
        if (variable_struct_exists(_template, "commands") ) 
		{
            var _categories = variable_struct_get_names(_template.commands);
            for (var i = 0; i < array_length(_categories); i++)
            {
                var _category_name = _categories[i];
                var _command_keys_array = _template.commands[$ _category_name];

                // Usar la API pública para añadir los comandos, asegurando la creación de categorías
                for (var j = 0; j < array_length(_command_keys_array); j++)
                {
                    var _command_key = _command_keys_array[j];
                    CommandAdd(_category_name, _command_key);
                }
            }
        }
	}

	/// @desc (Privado) Carga la instancia de la IA.
	/// @param {Struct} _template La plantilla de la entidad.
	/// @ignore
	static __LoadAI = function(_template)
	{
		if (variable_struct_exists(_template, "ai_package") )
		{
			ai_instance = new EntityAIInstance(self, _template.ai_package);
		}
	}
	
	/// @desc Calcula el valor base de cada stat (peak_value) según el nivel.
	/// @ignore
	static __CalculatePeakValues = function()
	{
		var _stat_keys = variable_struct_get_names(stats);
        for (var i = 0; i < array_length(_stat_keys); i++) {
            var _stat_inst = stats[$ _stat_keys[i]];
            _stat_inst.Recalculate(self);
        }
	}
	
	/// @desc Aplica los modificadores del equipo.
	/// @ignore
	static __ApplyEquipmentModifiers = function()
	{
		var _stat_keys = variable_struct_get_names(stats);
        for (var i = 0; i < array_length(_stat_keys); i++) {
            var _stat_inst = stats[$ _stat_keys[i]];
            _stat_inst.equipment_value = _stat_inst.peak_value;
        }
        
        var _slot_keys = variable_struct_get_names(slots);
        for (var i = 0; i < array_length(_slot_keys); i++) {
            var _slot_inst = slots[$ _slot_keys[i]];
            if (_slot_inst.is_active) {
                for (var k = 0; k < array_length(_slot_inst.equipped_items); k++) {
                    var _item = pocket_item_get(_slot_inst.equipped_items[k]);
                    if (is_undefined(_item) || !variable_struct_exists(_item, "stats")) continue;
                    
                    var _item_stat_keys = variable_struct_get_names(_item.stats);
                    for (var j = 0; j < array_length(_item_stat_keys); j++) {
                        var _item_stat_key = _item_stat_keys[j];
                        if (struct_exists(stats, _item_stat_key)) {
                            stats[$ _item_stat_key].equipment_value += _item.stats[$ _item_stat_key][0];
                        }
                    }
                }
            }
        }
	}
	
	/// @desc Aplica los modificadores de los estados y efectos.
	/// @ignore
	static __ApplyStateModifiers = function()
	{
		var _stat_keys = variable_struct_get_names(stats);
        for (var i = 0; i < array_length(_stat_keys); i++) {
            var _stat_inst = stats[$ _stat_keys[i]];
            _stat_inst.control_value = _stat_inst.equipment_value;
        }
        
        var _state_keys = variable_struct_get_names(states);
        for (var i = 0; i < array_length(_state_keys); i++) {
            var _state_inst = states[$ _state_keys[i]];
            
            for (var eff_idx = 0; eff_idx < array_length(_state_inst.effects); eff_idx++) {
                var _effect_inst = _state_inst.effects[eff_idx];
                var _modifiers = _effect_inst.template.stats;
                var _mod_keys = variable_struct_get_names(_modifiers);
                
                for (var j = 0; j < array_length(_mod_keys); j++) {
                    var _mod_key_full = _mod_keys[j];
                    var _prefix = string_char_at(_mod_key_full, 1);
                    var _stat_key = string_delete(_mod_key_full, 1, 1);
                    
                    if (struct_exists(stats, _stat_key)) {
                        var _stat_to_mod = stats[$ _stat_key];
                        var _mod_value = _modifiers[$ _mod_key_full];
                        
                        if (_prefix == "+") {
                            _stat_to_mod.control_value += _mod_value;
                        } else if (_prefix == "%") {
                            _stat_to_mod.control_value += (_stat_to_mod.equipment_value * _mod_value) / 100;
                        }
                    }
                }
            }
        }
	}
	
	/// @desc Finaliza los cálculos, aplica límites y actualiza valores.
	/// @ignore
	static __FinalizeStatValues = function()
	{
		var _stat_keys = variable_struct_get_names(stats);
        for (var i = 0; i < array_length(_stat_keys); i++) {
            var _stat_inst = stats[$ _stat_keys[i]];
            _stat_inst.last_peak_value = _stat_inst.peak_value;
            _stat_inst.last_current_value = _stat_inst.current_value;
            _stat_inst.control_value = __MALL_STAT_ROUND(clamp(_stat_inst.control_value, _stat_inst.template.min_value, _stat_inst.template.max_value));
            _stat_inst.current_value = min(_stat_inst.current_value, _stat_inst.control_value);
        }
	}
	
	#endregion
	
    /// @desc Configura la entidad a partir de su plantilla de datos.
    static FromTemplate = function()
    {
        var _template = Systemall.__entities[$ template_key];
        if (is_undefined(_template) )
		{
            show_error($"[PartyEntity] No se encontró la plantilla '{template_key}'", true);
            return self;
        }
		
        // Cargar variables.
		if (variable_struct_exists(_template, "vars") ) {vars = variable_clone(_template.vars); }
		
		// Cargar Funciones.
		__LoadFunctions(_template);
		
        // Cargar todos los componentes en orden
		__LoadStats(_template);
		__LoadSlots(_template);
		__LoadStates(_template);
		__LoadCommands(_template);
		__LoadAI(_template);
		
		// --- Cargar drops y exp ---
		exp_drop = _template[$ "exp_drop"] ?? 0;
		drops = _template[$ "drops"] ?? [];
		
		// Recalcular stats después de que todo esté cargado y equipado.
        RecalculateStats();
		
        return self;
    }
	
    /// @desc Recalcula todas las estadísticas (usado al subir de nivel o al equipar/desequipar).
    static RecalculateStats = function()
    {
		// Ejecuta cada paso del cálculo en orden.
		__CalculatePeakValues();
		__ApplyEquipmentModifiers();
		__ApplyStateModifiers();
		__FinalizeStatValues();
    }
	
    /// @desc Sube de nivel a la entidad y recalcula sus estadísticas.
	/// @param {Real} [levels_to_add]=1 El número de niveles a subir.
    static LevelUp = function(_levels_to_add = 1)
    {
        var _level_check_func = Systemall.__functions[$ event_on_level_check];
        if (is_callable(_level_check_func) && !_level_check_func(self, _levels_to_add)) {
            return;
        }
        
        level = clamp(level + _levels_to_add, __MALL_PARTY_LEVEL_MIN, __MALL_PARTY_LEVEL_MAX);
        RecalculateStats();
        
        var _level_up_func = Systemall.__functions[$ event_on_level_up];
        if (is_callable(_level_up_func)) {
            _level_up_func(self);
        }
    }
	
	#region API DE STATS
	   
	/// @desc Obtiene la instancia de una estadística.
	/// @param {String} key La llave de la estadística (ej: "EN").
	/// @return {Struct.EntityStatInstance}
    static StatGet = function(_key)
    {
	    if (!mall_exists_stat(_key) ) {
	        show_error($"[Systemall] Advertencia: El stat '{_key}' no existe.", true);
		}
		return (struct_get(stats, _key));
	}
	
	/// @desc Establece el valor actual de una estadística.
	/// @param {String} key La llave de la estadística.
	/// @param {Real} value El nuevo valor.
	/// @param {Enum.MALL_NUMTYPE} [numtype]=MALL_NUMTYPE.REAL
	/// @param {Enum.MALL_STAT_TARGET} [numtarget]=MALL_STAT_TARGET.CONTROL
	/// @return {Real} El valor actual después de la modificación.
	static StatSet = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarget=MALL_STAT_TARGET.CONTROL)
	{
        var _stat = StatGet(_key);
        if (is_undefined(_stat)) return 0;
		
		_stat.last_current_value = _stat.current_value;
		
		var _new_value = _value;
		if (_numtype == MALL_NUMTYPE.PERCENT) {
			_new_value = _stat.ReturnValueTarget(_numtarget) * _value / 100;
		}
		
		_stat.current_value = clamp(_new_value, _stat.template.min_value, _stat.control_value);
		return _stat.current_value;
	}
	
	/// @desc Añade (o resta) un valor a una estadística.
	/// @param {String} key La llave de la estadística.
	/// @param {Real} value El valor a añadir (puede ser negativo).
	/// @param {Enum.MALL_NUMTYPE} [numtype]=MALL_NUMTYPE.REAL
	/// @param {Enum.MALL_STAT_TARGET} [numtarget]=MALL_STAT_TARGET.CURRENT
	/// @return {Real} La diferencia de valor que se aplicó.
	static StatAdd = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarget = MALL_STAT_TARGET.CURRENT)
	{
        var _stat = StatGet(_key);
        if (is_undefined(_stat)) return 0;
		
		var _value_to_add = _value;
		if (_numtype == MALL_NUMTYPE.PERCENT) {
			var _base_for_percent = _stat.ReturnValueTarget(_numtarget);
			_value_to_add = (_base_for_percent * _value) / 100;
		}
		
		var _old_value = _stat.current_value;
		var _new_value = __MALL_STAT_ROUND(_old_value + _value_to_add);
		
		StatSet(_key, _new_value);

        return (_stat.current_value - _old_value);
	}
	
	#endregion
	
	#region API DE SLOTS
	
    /// @desc Obtiene la instancia de un slot.
	/// @param {String} key La llave del slot.
	/// @return {Struct.EntitySlotInstance}
    static SlotGet = function(_key)
    {
	    if (!mall_exists_slot(_key) ) {
	        show_error($"[Systemall] Advertencia: El slot '{_key}' no existe.", true);
	    }		
        return (struct_get(slots, _key) );
    }
    
	/// @desc Añade objetos/tipos permitidos para equipar en el Slot.
	/// @param {String} slotKey La llave del slot.
	/// @param {String, Array} itemOrTypeKey La llave del objeto o tipo a añadir.
    static SlotPermitedAdd = function(_slotKey, _itemOrTypeKey)
    {
        var _slot = SlotGet(_slotKey);
        if (is_undefined(_slot)) return;
        
        if (mall_exists_type(_itemOrTypeKey)) {
            var _type_items = mall_get_type(_itemOrTypeKey);
            for (var i = 0; i < array_length(_type_items); i++) {
                _slot.permited[$ _type_items[i]] = 0;
            }
        } else {
            _slot.permited[$ _itemOrTypeKey] = 0;
        }
    }
    
	/// @desc Elimina objetos/tipos permitidos.
	/// @param {String} slotKey La llave del slot.
	/// @param {String, Array} itemOrTypeKey La llave del objeto o tipo a eliminar.
    static SlotPermitedRemove = function(_slotKey, _itemOrTypeKey)
    {
        var _slot = SlotGet(_slotKey);
        if (is_undefined(_slot)) return;
        
        if (mall_exists_type(_itemOrTypeKey)) {
            var _type_items = mall_get_type(_itemOrTypeKey);
            for (var i = 0; i < array_length(_type_items); i++) {
                struct_remove(_slot.permited, _type_items[i]);
            }
        } else {
            struct_remove(_slot.permited, _itemOrTypeKey);
        }
    }
    
	/// @desc Equipa un objeto en un slot.
	/// @param {String} slot_key La llave del slot.
	/// @param {String} item_key La llave del objeto a equipar.
	/// @return {Struct} { success: bool, previously_equipped: string_or_undefined }
    static SlotEquip = function(_slot_key, _item_key)
    {
        var _slot_inst = SlotGet(_slot_key);
        if (is_undefined(_slot_inst)) {
            return { success: false, previously_equipped: undefined };
        }
        
        var _result = _slot_inst.Equip(_item_key);
        if (_result.success) { RecalculateStats(); }
		
		return _result;
    }
    
	/// @desc Desequipa un objeto de un slot.
	/// @param {String} slot_key La llave del slot.
	/// @param {String} item_key La llave del objeto a desequipar.
	/// @return {Struct} { success: bool, unequipped_item: string_or_undefined }
    static SlotDesequip = function(_slot_key, _item_key)
    {
        var _slot_inst = SlotGet(_slot_key);
        if (is_undefined(_slot_inst)) {
            return { success: false, unequipped_item: undefined };
        }

        var _result = _slot_inst.Desequip(_item_key);
        if (_result.success) { RecalculateStats(); }
		
		return _result;
    }
    
    /// @desc Devuelve los objetos equipados en un slot.
	/// @param {String} key La llave del slot.
    /// @return {Array<String>} Un array con las llaves de los objetos equipados.
    static SlotGetEquipped = function(_key)
    {
        var _slot = SlotGet(_key);
        return (_slot.equipped_items);
    }
    
	/// @desc Comprueba si un objeto es permitido en un slot.
    /// @param {String} key La llave del slot.
    /// @param {String} ikey La llave del objeto a comprobar.
	/// @return {Bool}
    static SlotIsPermited = function(_key, _ikey)
    {
        var _slot = SlotGet(_key);
        return (struct_exists(_slot.permited, _ikey));
    }
    
	/// @desc Comprueba si un slot no tiene objetos equipados.
    /// @param {String} key La llave del slot.
    /// @return {Bool}
    static SlotIsEmpty = function(_key)
    {
        var _slot = SlotGet(_key);
        return (array_length(_slot.equipped_items) == 0);
    }

	/// @desc Ejecuta una función por cada slot de la entidad.
	/// @param {Function} fn La función a ejecutar. Recibe (slot_instance, slot_key).
	static SlotForeach = function(_fn)
	{
		var _keys = variable_struct_get_names(slots);
		for (var i = 0; i < array_length(_keys); i++)
		{
			var _key = _keys[i];
			_fn(slots[$ _key], _key);
		}
	}
	
	#endregion

	#region API de STATES
	/// @desc Obtiene la instancia de un estado.
	/// @param {String} key La llave del estado.
	/// @return {Struct.EntityStateInstance}
	static StateGet = function(_key)
	{
		return states[$ _key];
	}
	
	/// @desc Comprueba si un estado está activo en la entidad (si tiene al menos un efecto).
	/// @param {String} key La llave del estado.
	/// @return {Bool}
	static StateIsActive = function(_key)
	{
		var _state = StateGet(_key);
		if (is_undefined(_state)) return false;
		return _state.boolean_value;
	}
	
	/// @desc Añade un efecto a un estado de la entidad.
	/// @param {String} effect_key La llave de la plantilla del efecto a añadir.
	/// @return {Struct.DarkEffectInstance} La instancia del efecto creado, o undefined si falló.
	static EffectAdd = function(_effect_key)
	{
		var _effect_template = mall_get_effect(_effect_key);
		if (is_undefined(_effect_template)) return undefined;
		
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst)) return undefined;
		
		var _state_template = _state_inst.template;
		
		// 1. Comprobar inmunidades y prioridades
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) {
			var _current_state_inst = states[$ _state_keys[i]];
			if (!_current_state_inst.boolean_value) continue;
			
			if (array_contains(_current_state_inst.template.prevents_states, _state_key)) return undefined;
			if (_current_state_inst.template.restricts_action && _state_template.priority < _current_state_inst.template.priority) return undefined;
		}
		
		// 2. Limpiar otros estados
		var _states_to_clear = _state_template.clears_states;
		for (var i = 0; i < array_length(_states_to_clear); i++) {
			StateRemoveAllEffects(_states_to_clear[i]);
		}
		
		// 3. Crear y añadir la instancia del efecto
		var _effect_instance = new DarkEffectInstance(_effect_template);
		array_push(_state_inst.effects, _effect_instance);
		
		// 4. Activar el estado y ejecutar eventos
		if (!_state_inst.boolean_value) {
			_state_inst.boolean_value = true;
			_state_inst.event_on_start(self);
		}
		
		mall_get_function(_effect_template.event_on_start)(self, _effect_instance);
		
		RecalculateStats();
		return _effect_instance;
	}
	
	/// @desc Elimina una instancia de efecto de un estado.
	/// @param {Struct.DarkEffectInstance} effect_instance La instancia del efecto a eliminar.
	/// @return {Bool} Devuelve true si el efecto fue eliminado.
	static EffectRemove = function(_effect_instance)
	{
		if (is_undefined(_effect_instance)) return false;
		
		var _state_key = _effect_instance.template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst)) return false;
		
		var _removed = array_remove(_state_inst.effects, _effect_instance);
		
		if (_removed) {
			mall_get_function(_effect_instance.template.event_on_end)(self, _effect_instance);
			
			// Si ya no quedan efectos, desactivar el estado
			if (array_length(_state_inst.effects) == 0) {
				_state_inst.boolean_value = false;
				_state_inst.event_on_end(self);
			}
			
			RecalculateStats();
		}
		
		return _removed;
	}
	
	/// @desc Elimina todos los efectos de un estado específico.
	/// @param {String} key La llave del estado a limpiar.
	static StateRemoveAllEffects = function(_key)
	{
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst.boolean_value) {
			return;
		}
		
		// Disparar evento de finalización para cada efecto
		for (var i = 0; i < array_length(_state_inst.effects); i++) {
			var _effect_inst = _state_inst.effects[i];
			mall_get_function(_effect_inst.template.event_on_end)(self, _effect_inst);
		}
		
		_state_inst.effects = [];
		_state_inst.boolean_value = false;
		_state_inst.event_on_end(self);
		
		RecalculateStats();
	}

	/// @desc Actualiza los efectos de un estado específico según el momento del turno.
	/// @param {String} key La llave del estado a actualizar.
	/// @param {Enum.MALL_EFFECT_TURN} turn_type El momento del turno (START o END).
	static EffectsUpdateByTurn = function(_key, _turn_type)
	{
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst.boolean_value) return;
		
		// Iterar hacia atrás para poder eliminar efectos de forma segura
		for (var i = array_length(_state_inst.effects) - 1; i >= 0; i--) {
			var _effect_inst = _state_inst.effects[i];
			var _template = _effect_inst.template;
			
			// Comprobar si el efecto debe ejecutarse en este momento del turno
			if (_template.turn_type != _turn_type && _template.turn_type != MALL_EFFECT_TURN.BOTH) continue;
			
			// Seleccionar el iterador correcto
			var _iterator = (_turn_type == MALL_EFFECT_TURN.START) ? _effect_inst.iterator_start : _effect_inst.iterator_end;
			var _tick_result = _iterator.Tick();
			
			switch (_tick_result)
			{
				case MALL_ITERATOR_STATE.WORKING:
				case MALL_ITERATOR_STATE.CYCLE_END:
					// El efecto sigue activo, ejecutar su evento de turno
					var _event = (_turn_type == MALL_EFFECT_TURN.START) ? _template.event_on_turn_start : _template.event_on_turn_end;
					mall_get_function(_event)(self, _effect_inst);
					break;
				
				case MALL_ITERATOR_STATE.COMPLETED:
					// El efecto ha terminado, eliminarlo
					EffectRemove(_effect_inst);
					break;
			}
		}
		
		// Recalcular stats solo si no estamos en un bucle de actualización masiva
		if (!__is_updating_all_states) {
			RecalculateStats();
		}
	}
	
	/// @desc Actualiza todos los estados de la entidad según el momento del turno.
	/// @param {Enum.MALL_EFFECT_TURN} turn_type El momento del turno (START o END).
	static StateUpdateAll = function(_turn_type)
	{
		__is_updating_all_states = true;
		
		var _keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_keys); i++) {
			EffectsUpdateByTurn(_keys[i], _turn_type);
		}
		
		__is_updating_all_states = false;
		RecalculateStats();
	}
	
	#endregion

	#region API DE COMANDOS
	
	/// @desc Añade un comando a una categoría.
	/// @param {String} category_key La categoría donde añadir el comando.
	/// @param {String} command_key La llave del comando a añadir.
	/// @return {Bool} Devuelve true si se añadió correctamente.
	static CommandAdd = function(_category_key, _command_key)
	{
		if (!mall_exists_command(_command_key) ) return false;
		
		// Crear la categoría si no existe
		if (!struct_exists(commands.commands, _category_key) ) 
		{
			commands.commands[$ _category_key] = {};
			array_push(commands.commands_key, _category_key);
		}
		
		commands.commands[$ _category_key][$ _command_key] = true;
		return true;
	}
	
	/// @desc Elimina un comando de una categoría.
	/// @param {String} category_key La categoría del comando.
	/// @param {String} command_key La llave del comando a eliminar.
	/// @return {Bool} Devuelve true si se eliminó.
	static CommandRemove = function(_category_key, _command_key)
	{
		if (struct_exists(commands.commands, _category_key) )
		{
			return struct_remove(commands.commands[$ _category_key], _command_key);
		}
		
		return false;
	}
	
	/// @desc Comprueba si la entidad posee un comando en una categoría específica.
	/// @param {String} category_key La categoría a buscar.
	/// @param {String} command_key La llave del comando.
	/// @return {Bool}
	static CommandExists = function(_category_key, _command_key)
	{
		if (struct_exists(commands.commands, _category_key) ) 
		{
			return struct_exists(commands.commands[$ _category_key], _command_key);
		}
		
		return false;
	}
	
	/// @desc Obtiene la plantilla de un comando que la entidad posee.
	/// @param {String} category_key La categoría del comando.
	/// @param {String} command_key La llave del comando.
	/// @return {Struct.DarkCommand} La plantilla del comando, o undefined.
	static CommandGet = function(_category_key, _command_key)
	{
		if (CommandExists(_category_key, _command_key) ) 
		{
			return mall_get_dark(_command_key);
		}
		return undefined;
	}
	
	/// @desc Obtiene todas las llaves de los comandos de una categoría.
	/// @param {String} category_key La categoría a consultar.
	/// @return {Array<String>} Un array con las llaves de los comandos.
	static CommandGetAll = function(_category_key)
	{
		if (struct_exists(commands.commands, _category_key) ) 
		{
			return variable_struct_get_names(commands.commands[$ _category_key]);
		}
		
		return [];
	}
	
	/// @desc Obtiene una llave de comando al azar de una categoría.
	/// @param {String} category_key La categoría a consultar.
	/// @return {String} La llave de un comando al azar, o undefined.
	static CommandGetRandom = function(_category_key)
	{
		var _all_commands = CommandGetAll(_category_key);
		if (array_length(_all_commands) > 0) 
		{
			var _random_index = irandom(array_length(_all_commands) - 1);
			return _all_commands[_random_index];
		}
		
		return undefined;
	}
	
	/// @desc Obtiene todas las categorías de comandos de la entidad.
	/// @return {Array<String>}
	static CategoryGetAll = function()
	{
		return commands.commands_key;
	}
	
	#endregion

	#region API MISQ
	/// @desc Calcula y devuelve la experiencia y los objetos que suelta la entidad al ser derrotada.
	/// @return {Struct} Un struct con el formato { exp: Real, items: Array<Struct> }
	static GetDrops = function()
	{
		var _result = {
			exps: 0,
			items: []
		};
		
		// Calcular EXP
		if (is_array(exp_drop) ) 
		{
			// Si es un rango [min, max]
			_result.exps = irandom_range(exp_drop[0], exp_drop[1] );
		} 
		else 
		{
			// Si es un valor fijo
			_result.exps = exp_drop;
		}
		
		// Calcular Drops de Items
		for (var i = 0; i < array_length(drops); i++) 
		{
			var _drop_data = drops[i];
			var _chance = _drop_data.chance ?? 100;
			
			// Tirada de probabilidad
			if (random(100) < _chance) 
			{
				var _quantity = 0;
				var _quantity_data = _drop_data.quantity ?? 1;
				
				if (is_array(_quantity_data) ) 
				{
					// Cantidad en rango [min, max]
					_quantity = irandom_range(_quantity_data[0], _quantity_data[1]);
				} 
				else 
				{
					// Cantidad fija
					_quantity = _quantity_data;
				}
				
				if (_quantity > 0) 
				{
					array_push(_result.items, {
						key:		_drop_data.key,
						quantity:	_quantity
					});
				}
			}
		}
		
		return _result;
	}	

	/// @desc Añade un nuevo drop a la lista de la entidad en tiempo de ejecución.
	/// @param {String} key La llave del objeto a soltar.
	/// @param {Real, Array} quantity La cantidad (un número o un array [min, max]).
	/// @param {Real} [chance]=100 La probabilidad (0-100) de que el objeto se suelte.
	static AddDrop = function(_key, _quantity, _chance = 100)
	{
		array_push(drops, {
			key:		_key,
			quantity:	_quantity,
			chance:		_chance
		});
		
		return self;
	}

	/// @desc Se ejecuta al inicio del turno de la entidad en combate.
	static OnTurnStart = function()
	{
		// Actualiza todos los estados y efectos que se activan al inicio del turno.
		StateUpdateAll(MALL_EFFECT_TURN.START);
	}

	/// @desc Se ejecuta al final del turno de la entidad en combate.
	static OnTurnEnd = function()
	{
		// Actualiza todos los estados y efectos que se activan al final del turno.
		StateUpdateAll(MALL_EFFECT_TURN.END);
	}

	/// @desc Selecciona la acción a realizar en el turno.
	/// @param {Struct} battle_context Contexto del combate (aliados, enemigos).
	/// @return {Struct} La acción seleccionada.
	static SelectAction = function(_battle_context)
	{
		// Si la entidad tiene una instancia de IA, delega la decisión.
		if (!is_undefined(ai_instance) )
		{
			return ai_instance.SelectAction(_battle_context);
		}
    
		// Si no, podría esperar la entrada del jugador o realizar una acción por defecto.
		return undefined;
	}

	/// @desc Comprueba si la entidad puede realizar una acción en su turno.
	/// @return {Bool} Devuelve false si algún estado activo restringe la acción.
	static CanAct = function()
	{
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) 
		{
			var _state_inst = states[$ _state_keys[i]];
			
			// Si el estado está activo y su plantilla restringe la acción
			if (_state_inst.boolean_value && _state_inst.template.restricts_action) 
			{
				return false;
			}
		}
		
		return true;
	}
	
	#endregion

	#region API DE GUARDADO Y CARGA
	
	/// @desc Exporta el estado actual de la entidad a un struct.
	/// @return {Struct} Un struct con los datos de la entidad para guardar.
	static Export = function()
	{
		var _export_data = {
			"instance_id": id,
			template_key:	template_key,
			level:			level,
			group_key:		group_key,
			vars:			variable_clone(vars),
			stats:			{},
			slots:			{},
			states:			{},
			flags:			variable_clone(flags)
		};
		
		// Exportar estado de cada stat
		var _stat_keys = variable_struct_get_names(stats);
		for (var i = 0; i < array_length(_stat_keys); i++) 
		{
			var _key = _stat_keys[i];
			_export_data.stats[$ _key] = stats[$ _key].Export();
		}
		
		// Exportar estado de cada slot
		var _slot_keys = variable_struct_get_names(slots);
		for (var i = 0; i < array_length(_slot_keys); i++) 
		{
			var _key = _slot_keys[i];
			_export_data.slots[$ _key] = slots[$ _key].Export();
		}
		
		// Exportar estado de cada state
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) 
		{
			var _key = _state_keys[i];
			_export_data.states[$ _key] = states[$ _key].Export();
		}
		
		return _export_data;
	}
	
	/// @desc Importa y restaura el estado de la entidad desde un struct.
	/// @param {Struct} data El struct con los datos guardados.
	static Import = function(_data)
	{
		// Restaurar propiedades base
		id = _data[$ "instance_id"] ?? id;
		level = _data[$ "level"] ?? 1;
		group_key = _data[$ "group_key"] ?? "";
		vars =	_data[$ "vars"] ?? {};
		
		// Cargar flags
		flags = _data[$ "flags"] ?? {};
		
		// Importar estado de cada stat
		if (variable_struct_exists(_data, "stats") ) 
		{
			var _stat_keys = variable_struct_get_names(_data.stats);
			for (var i = 0; i < array_length(_stat_keys); i++) 
			{
				var _key = _stat_keys[i];
				if (struct_exists(stats, _key) ) 
				{
					stats[$ _key].Import(_data.stats[$ _key]);
				}
			}
		}
		
		// Importar estado de cada slot
		if (variable_struct_exists(_data, "slots") ) 
		{
			var _slot_keys = variable_struct_get_names(_data.slots);
			for (var i = 0; i < array_length(_slot_keys); i++) 
			{
				var _key = _slot_keys[i];
				if (struct_exists(slots, _key) ) 
				{
					slots[$ _key].Import(_data.slots[$ _key]);
				}
			}
		}
		
		// Importar estado de cada state
		if (variable_struct_exists(_data, "states") ) 
		{
			var _state_keys = variable_struct_get_names(_data.states);
			for (var i = 0; i < array_length(_state_keys); i++) 
			{
				var _key = _state_keys[i];
				if (struct_exists(states, _key) )
				{
					states[$ _key].Import(_data.states[$ _key]);
				}
			}
		}
		
		// Recalcular todo para aplicar los cambios cargados
		RecalculateStats();
	}
	
	#endregion

	#region API DE CONSULTA DE ESTADOS
	
	/// @desc Devuelve un array con las llaves de todos los estados activos.
	/// @return {Array<String>}
	static StateGetAllActive = function()
	{
		var _active_states = [];
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) {
			var _key = _state_keys[i];
			if (states[$ _key].boolean_value) {
				array_push(_active_states, _key);
			}
		}
		return _active_states;
	}
	
	/// @desc Devuelve un array con las llaves de los estados activos de una categoría específica.
	/// @param {String} type La categoría a buscar (ej: "AILMENT", "BUFF").
	/// @return {Array<String>}
	static StateGetAllByType = function(_type)
	{
		var _active_states = [];
		var _type_upper = string_upper(_type);
		var _state_keys = variable_struct_get_names(states);
		for (var i = 0; i < array_length(_state_keys); i++) {
			var _key = _state_keys[i];
			var _state_inst = states[$ _key];
			if (_state_inst.boolean_value && _state_inst.template.state_type == _type_upper) {
				array_push(_active_states, _key);
			}
		}
		return _active_states;
	}
	
	#endregion

	#region API DE FLAGS
	
	/// @desc Añade un flag a la entidad.
	/// @param {String} key La llave del flag (ej: "IMMUNE_TO_POISON").
	static FlagAdd = function(_key)
	{
		flags[$ _key] = true;
	}
	
	/// @desc Elimina un flag de la entidad.
	/// @param {String} key La llave del flag.
	static FlagRemove = function(_key)
	{
		struct_remove(flags, _key);
	}
	
	/// @desc Comprueba si la entidad tiene un flag específico.
	/// @param {String} key La llave del flag.
	/// @return {Bool}
	static FlagHas = function(_key)
	{
		return struct_exists(flags, _key);
	}
	
	#endregion
}

/// @desc Crea una plantilla de entidad desde data y la añade a la base de datos.
function party_create_entity_template(_key, _data)
{
    if (struct_exists(Systemall.__entities, _key))
    {
        show_debug_message($"[Systemall] Advertencia: El entity template '{_key}' ya existe. Se omitirá la duplicada.", true);
        return undefined;
    }
	
    // Guardamos el struct de datos directamente como plantilla.
	Systemall.__entities[$ _key] = _data;
    array_push(Systemall.__entities_keys, _key);
}

/// @desc Comprueba si una plantilla existe.
/// @param {String} key
function party_exists_entity_template(_key) 
{
	return (struct_exists(Systemall.__entities, _key) ); 
}

/// @desc Crea una INSTANCIA de una entidad a partir de una plantilla.
/// @param {String}	template_key La llave de la plantilla (ej: "JON", "SLIME").
/// @param {Real}	[level]=1 El nivel inicial de la instancia.
/// @return {Struct.PartyEntity}
function party_entity_create_instance(_template_key, _level=1)
{
    if (!party_exists_entity_template(_template_key) )
    {
        show_error($"[Systemall] Intento de crear una instancia de una plantilla no existente: '{_template_key}'", true);
        return undefined;
    }
    
    // Crear un ID único para la instancia (esto es una simplificación, se podría usar un contador global)
    var _instance_id = $"{_template_key}_{get_timer()}"; 
    
    var _entity = new PartyEntity(_template_key, _instance_id);
    _entity.FromTemplate();
    _entity.level = _level;
    _entity.RecalculateStats();
    
    return _entity;
}

/*
// Feather ignore all
/// @param	{String} entity_key
function PartyEntity(_key) : Mall(_key) constructor
{
    // Llave del grupo al que pertenece.
    group = "";
    // Estructuras
    level = __MALL_PARTY_LEVEL_MIN;
    // Estadisticas
    stats = {};
    array_foreach(mall_get_stat_keys(), __Init);
    
    // Control y estados
    controls = {};
    controlsKeys = [];
    
    // Slots y equipo
    slots = {};
    slotsKeys = [];
    
    // Manager de combate actual.
    wate = undefined;
    // Para batallas.
    battleGroup = "";
    battleState = "";
    battleAnimation = undefined;
    // Turno actual
    turn = 0;
    // Eventos para los turnos.
    turnEvent = [];
    
    // Como se comporta.
    conduct = "";
    // Drops a soltar.
    drops = [];
    // Que comandos puede realizar
    categories = {
        // Todas las categorias.
        defaults: {keys:[] }
    };
    categoriesKeys = [];
    // Para cuando es forzado.
    categoryForced = "";
    commandForced =  "";
    
    #region -- STATS
    /// @param	{Struct.MallStat} MallStat
	/// @ignore
    static AtomStat = function(stat) constructor
    {
        /// @ignore
        is = "AtomStat";
        /// @ignore
        key = stat.key;
		/// @ignore
        dKey = stat.dKey;
		/// @ignore
        canSave = stat.canSave;
        
        // -- Configuracion
        // Que pasar en la formula para subir de nivel
        vars = {};
        // Si sube de nivel individualmente
        single = stat.levelSingle;
        // Guardar metodo.
        eUpdate = method(self, stat.eUpdate);
        
        // Para los turnos
        eTurnStart = method(self, stat.eTurnStart);
        eTurnEnd = method(self, stat.eTurnEnd);
        // Al equipar un objeto (inicio) ejecuta esta función.
        eEquip = method(self, stat.eEquip);
        // Al desequipar un objeto ejecuta esta función.
        eDesequip = method(self, stat.eDesequip);
        
        // Niveles
        eLevelUp = method(self, stat.eLevelUp);
        eLevelCheck = method(self, stat.eLevelCheck);
        
        // Copiar iterador
        // Copiar la configuracion del otro iterador
        // Crear un iterador si no existe
        iterator = (stat.iterator != undefined) ? 
            stat.iterator.copy() : 
            new MallIterator();
        
        // -- Se ponen los valores inciales
        // Nivel de la estadistica si se usa individualmente
        level = stat.startLevel;
        base = stat.start;
        type = stat.type;
        // Valor maximo en que la estadistica puede estar
        limitMin = stat.limitMin;
        // Valor minimo en que la estadistica puede estar
        limitMax = stat.limitMax;

        // Valor de la estadistica actual maximo respecto al nivel
        peak = control;
        // El valor final tomando en cuenta el equipamiento
        equipment = control;        
        // El valor final tomando en cuenta el control
        control = base;
        // El valor actual de la estadistica
        current = control;
        
        // El ultimo valor maximo
        laspeak = control;
        // El anterior valor actual
        lascurrent = control;
        
        /// @desc Devuelve un struct con los valores actuales
        static Send = function()
        {
            var _this = self;
            return ({
                key: _this.key,
                // El valor con los controles/estados.
				control: _this.control,
				// El valor con los equipos.
                equipment: _this.equipment,
				// El valor maximo.
				peak: _this.peak,
				// El valor actual.
                current: _this.current,
                // -- Valores previos.
                laspeak: _this.laspeak,
                lascurrent: _this.lascurrent
            });
        }
        
        /// @desc Como guarda este componente.
		/// @param	{Bool}	[struct] devolver un struct o un JSON.
        static Export = function(_struct=false) 
        {
            var _this = self;
            with ({})
            {
                version = __MALL_MY_VERSION;
                is = _this.is;
                level = _this.level;
                iterator = _this.iterator.export();
                actual = _this.canSave ? _this.current : 0;
                return (_struct) ? self : json_stringify(self, true); 
            }
        }
        
        /// @desc Como carga este componente.
        /// @param	{Struct} load_struct
        static Import = function(_l) 
        {
            if (_l.is != is) exit;
            switch (_l.version) 
            {
                default:
                    level = _l.level;
                    iterator.Import(_l.iterator);
                    // Cargar valor actual.
                    if (canSave) {current = _l.current ?? peak; }
                break;
            }
            
            return self;
        }
    }
    
    /// @desc Obtiene un AtomStat a partir de la llave
    /// @param {String} stat_key
    /// @returns {Struct.PartyEntity$$AtomStat}
    static StatGet = function(_key)
    {
		// Por Hash.
        if (is_numeric(_key) ) {return (struct_get_from_hash(stats, _key) ); }
        return (struct_get(stats, _key) );
    }
    
    /// @desc Establece el valor actual de una estadistica teniendo como limites "limMin" y "control"
    /// @param	{String}			stat_key    Si es "all" permite cambiar el valor de todos los atomos
    /// @param	{Real}				value       Valor para establecer
    /// @param	{ENUM.MALL_NUMTYPE}	numtype     Tipo de numero
    /// @return	{Real}
    static StatSet = function(_key, _value, _numtype=MALL_NUMTYPE.REAL)
    {
        static SKeys = mall_get_stat_keys();
        
        #region Cambiar a todas las estadisticas a este valor
        if (_key == all)  
        {
            var i=0; repeat(array_length(SKeys) ) {StatSet(SKeys[i++], _value, _numtype); }
        } 
        #endregion
        
        #region Cambiar solo 1
        else
		{
            var _stat = StatGet(_key);
            if (is_undefined(_stat) ) return 0;
            with (_stat) 
            {
				var _t = (_numtype == MALL_NUMTYPE.PERCENT) ? (control * _value) / 100 : _value;
				lascurrent = current;
				current = clamp(_t, limitMin, control);
				
                return (current);
            }
        }
        #endregion
    }
    
    /// @desc Suma/Resta "current" de una estadistica teniendo como limite "limitMax" y "limitMin". Obtiene cuanto se modifico el valor.
    /// @param	{String}			stat_key	Llave de estadistica
    /// @param	{Real}				value		Valor para sumar/restar
    /// @param	{ENUM.MALL_NUMTYPE} numtype		Tipo de numero
    /// @param	{ENUM.STAT_NUMTARG} [numtarg]	Que "value" usar 0: current, 1:lascurrent, 2: peak, 3: laspeak, 4: equipment, 5: control, Solo porcentajes!
    /// @return	{Real} Devuelve el valor que se añadio
    static StatAdd = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarg=STAT_NUMTARG.CURRENT) 
    {
        var _stat = StatGet(_key);
        if (is_undefined(_stat) ) return 0;
		// Valor default.
        var _toadd = _value;
		
		// Obtener porcentaje.
		if (_numtype == MALL_NUMTYPE.PERCENT)
		{
			var _topercent;
            switch (_numtarg) 
            {
                case STAT_NUMTARG.CURRENT:		_topercent = _stat.current;		break;
                case STAT_NUMTARG.LASCURRENT:	_topercent = _stat.lascurrent;	break;
                    
                case STAT_NUMTARG.PEAK:			_topercent = _stat.peak;		break;
                case STAT_NUMTARG.LASPEAK:		_topercent = _stat.laspeak;		break;
                    
                case STAT_NUMTARG.EQUIPMENT:	_topercent = _stat.equipment;	break;
                case STAT_NUMTARG.CONTROL:		_topercent = _stat.control;		break;
            }
			// Utilizar el porcentaje.
			_toadd = (_topercent * _value) / 100;
		}
		
		// Establecer nuevo valor.
		StatSet(_key, round(_stat.current + _toadd) );
		
        // Obtener cuanto se modifico el valor.
        return (_stat.control - _stat.current);
    }
    
    /// @param	{String}			stat_key    Llave de estadistica
    /// @param	{Real}				base_value  Valor de base
    /// @param	{ENUM.MALL_NUMTYPE}	base_type   Tipo de numero
    /// @return {Struct.PartyEntity}
    static StatBaseSet = function(_statKey, _baseValue, _baseType) 
    {
        var i=0; repeat(argument_count div 3) 
        {
            var _key = argument[i];
            var _val = argument[i + 1];
            var _typ = argument[i + 2];
            
            var _atom = statGet(_key);
            // Actualizar valores bases
            _atom.base = _val;
            _atom.type = _typ;
            
            #region DEBUG
            if (__MALL_PARTY_TRACE) {
            show_debug_message($"MallRPG Party: {_key} base set to {_val}{StringNumtype(_typ)}");
            }
            #endregion
            
            i = i + 3;
        }
        
        return self;
    }
    
    /// @desc Evento a ejecutar cuando si inicia el proceso de subir de nivel.
    static eLevelStart = function() {};
    
    /// @desc Evento a ejecutar cuando si termina el proceso de subir de nivel.
    static eLevelEnd = function() {};
    
    /// @desc Funcion para comprobar si puede subir de nivel.
    static eLevelCheck = function() {};
    
    /// @param {Real}   new_level   Nuevo nivel
    /// @param {String} [stat_key]  Solo si es individual
    /// @return {Struct.PartyStat}
    static LevelSet = function(_level, _key) 
    {
        #region Global
        if (_key == undefined) 
        {
            level = _level
        }
        #endregion
        
        #region Individual
        else if (is_string(_key) )
        {
            var _stat = StatGet(_key);
            _stat.level = _level;
        }
        #endregion
        
        // Forzar subida de nivel
        StatLevelUp(false, 0, true);
        
        return self;
    }
    
    /// @param {Bool} [set_or_add]=false    Sumar o establecer el nivel. false: Add
    /// @param {Real} [level]=0             Nivel
    /// @param {Bool} [force]=false         Forzar el subir de nivel
    static StatLevelUp  = function(_set=false, _setLevel=0, _force=false) 
    {
        var _statKeys = mall_get_stat_keys();
        var _size = array_length(_statKeys);
		
        // Para feather
        var _return = {
            statKey: {
                key: "",
                
                current:    0,
                peak:       0,
                control:    0,
                equipment:  0,
                // Ultimas.
                lascurrent: 0,
                lascurrent: 0
            },
        };
        // Eliminar
        struct_remove(_return, "statKey");
        
        // Revisar check global
        var _globalCheck = eLevelCheck() + _force;
        if (!_globalCheck) exit;
        
        // Operar y Limitar niveles
        level = clamp(
            (!_set) ? level + _setLevel : _setLevel, 
            __MALL_PARTY_LEVEL_MIN, 
            __MALL_PARTY_LEVEL_MAX
        );
        
        // Funcion al iniciar el subir de nivel
        eTurnStart();
        
        #region Ciclar por cada stat
        var i=0; repeat(_size)
		{
            // Feather ignore all
            var _key = _statKeys[i];
            var _stat = StatGet(_key);
            // Solo si es independiente, nivel a usar
            var _check = undefined, _level = 1;
            // Si tiene un check individual.
            if (_stat.single)
            {
                _stat.level = (!_set) ? _stat.level + _setLevel : _setLevel;
                _level = _stat.level;
                _check = _stat.eLevelCheck(self);
            }
            // Remplazar por nivel global
            else
            {
                _level = level;
                _check =  true;
            }
            // Comprobar check
            var _enterGlobal = (_globalCheck && _check != undefined);
            
            #region Subir de nivel
            if (_force || (_check || _enterGlobal) ) 
            {
				// Obtener cambios del control respecto a los cambios en el equipo.
                var _restControl = (_stat.control - _stat.equipment);
				// Obtener cambios del equipamiento respecto al valor maximo de la estadistica.
                var _restSlot = (_stat.equipment - _stat.peak);
                /// Ejecutar evento para subir de nivel.
                var _sum = _stat.eLevelUp(self);
				
                // Actualizar valores
                _stat.peak = clamp(_sum, _stat.limitMin, _stat.limitMax);
				// Obtener valor del equipamiento.
                _stat.equipment = _stat.peak + _restSlot;
				// Obtener valor del control.
                _stat.control = _stat.peak + _restSlot + _restControl;
				
                // El primero deja peak, equipment y control igual.
                var _iter = _stat.iterator;
                var _work = _iter.Iterate();
				
                // Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo
				if (_work == MALL_ITERATOR.REINITIATED) 
				{
					_stat.current = (_iter.type) ? _stat.control : _stat.limitMin;
				}
				
				// Primera llamada.
                if (!_iter.firstCall) 
                {
                    // Actualizar valor final
                    _stat.laspeak = _stat.level(self, max(1, _level - 1) );
                    // Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo.
                    if (_iter.active) 
                    {
                        _stat.current = (_iter.type) ? _stat.control : _stat.limitMin;
                    }
                    // Establecer al valor maximo.
                    else 
                    {
                        _stat.current = _stat.control;
                        _stat.lascurrent = _stat.control; 
                    }
					
                    // Indicar que ya no será la primera ejecución.
                    _iter.firstCall = true;
                }
				
                // Mostrar los valores en el debugger
                if (__MALL_PARTY_TRACE) {show_debug_message($"M_Party: {_key} set to {_stat.control}"); }
				
				// Poner valores para regresar
                _return[$ _key] = _stat.Send();
            }
            
            #endregion
            
            i++;
        }
        #endregion
		
        // Ejecutar funcion al terminar de subir de nivel
        eLevelEnd();
        
        return (_return );
    }
    
    /// @desc Sube solo un stat.
    /// @param	{String}	stat_key
    /// @param	{Real}		[new_level]
    static StatLevelUpSingle = function(_key, _level)
    {
        var _stat = StatGet(_key);
        var _restControl = (_stat.control - _stat.equipment);
        var _restSlot = (_stat.equipment - _stat.peak);
        
		// Establecer nuevo nivel.
        _stat.level = _level;
        var _sum = _stat.eLevelUp(self);
		
        // Actualizar valores.
        _stat.peak = clamp(_sum, _stat.limitMin, _stat.limitMax);
        _stat.equipment = _stat.peak + _restSlot;
        _stat.control = _stat.peak + _restSlot + _restControl;
		
        // el primero deja peak, equipment y control igual.
        var _iter = _stat.iterator;
        var _work = _iter.Iterate();
		
        // Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo.
        if (_work == MALL_ITERATOR.REINITIATED) 
		{
			_stat.current = (_iter.type) ? _stat.control : _stat.limitMin;
		}
		
		return (_stat.Send() );
    }
    
    #endregion
    
    #region -- SLOTS
    /// @param {String}     slot_key            
    /// @param {String}     [display_key]       
    /// @param {Function}   [check_function]    function(entity, item) {return Bool; }
    /// @param {Bool}       [is_active]
	/// @ignore
    static AtomSlot = function(_key, _display, _active=true) constructor
    {
        is  = "AtomSlot";
        
        // Llaves.
        key = _key;
        dKey = _display;
        // Objetos permitidos
        permited = {};
        // Si se puede usar este slot
        active = _active;
        // Donde se almacenan los objetos que lleva.
        equipped = undefined;
        // Objeto anterior que se llevo.
        previous = undefined;
        // Indicar si se esta desequipando algo
        desequip = false;
        
        eItemCheck = function(entity, item) {return true; }
        
        /// @desc Guarda este componente.
		/// @param	{Bool}	[struct] devolver un struct o un JSON.
        static Export = function(_struct=false) 
        {
            var _this = self;
            with ({})
            {
                version = __MALL_MY_VERSION;
                // Guardar que es.
                is = _this.is;
				// Guardar llaves.
                key = _this.key;
                dKey = _this.dKey;
                // Propiedades.
                permited = variable_clone(_this.permited);
                equipped = (_this.equipped == undefined) ? undefined : _this.equipped.key;
                previous = (_this.previous == undefined) ? undefined : _this.previous.key;
                active = _this.active;
                
                return (!_struct) ? json_stringify(self, true) : self;
            }
        }
        
        /// @param {Struct} load_struct
        static Import = function(_l)
        {
            switch (_l.version) 
            {
				default:
		            // Llaves.
		            key = _l.key;
		            dKey = _l.dKey;
		            // Importar permitidos.
		            permited = _l.permited;
		            // Items.
		            equipped = (is_ptr(_l.equipped) ) ? undefined : pocket_item_get(_l.equipped);
		            previous = (is_ptr(_l.previous) ) ? undefined : pocket_item_get(_l.previous);
		            active = _l.active;
				break;
			}
			
            return self;
        }
    }
    
    /// @param	{String}	slot_key            
    /// @param	{String}	[display_key]       
    /// @param	{Function}	[check_function]	function(entity, item) {return Bool; }
    /// @param	{Bool}		[is_active]
    static SlotCreate = function(_key, _display, _check, _active=false)
    {
        // Crear AtomSlot.
        slots[$ _key] = new AtomSlot(_key, _display ?? _key, _check, _active);
		
		// Guardar llaves.
        array_push(slotsKeys, _key);
        
        return self;
    }
    

	
    #endregion
    
    #region -- STATES Y CONTROL
    /// @ignore
    /// @param {String} key
    /// @param {String} [display_key]
    static AtomState = function(_key, _display, _init=false) constructor
    {
        /// @ignore
        is = "AtomState";
        /// @ignore Trackear entidad.
        entity = weak_ref_create(other);
        // Configuracion
        // Llave de este estado
        key = _key;
        // LLave display de este estado.
        dKey = _display;
        
        // Estado a que reinicia.
        stateinit = _init;
        // Estado actual.
        state = _init;
        // Numero que utiliza este estado.
        type = MALL_NUMTYPE.REAL;
        // Si acepta el mismo control varias veces.
        same = false;
        // infinity se pueden agregar elementos infinitos.
        controls = infinity;
        
        // Valores que varian [real, porcentual] son actualizados.
        values = array_create(2, 0);
        // Para las estadisticas.
        stats = {};
        statsKeys = [];
        
        // Contenidos que posee este atomo.
        contents = array_create(0);
        // Flags que posee este atomo.
        flags = array_create(0);
        
        /// @return {Array<Struct.DarkEffect>}
        static GetContent = function()
        {
            // Feather ignore all
            return contents;
        }
        
        /// @desc Como guarda este componente
		/// @param	{Bool} [struct] devolver un struct o un JSON.
        static Export = function(_struct=false)
        {
			/// @param	{Struct.DarkEffect}	DarkEffect
			static ExportEffects = function(_effect) 
			{
				array_push(contents, _effect.Export() );
			}
			
            var _this = self;
            with ({contents: [] }) 
            {
                version = __MALL_MY_VERSION;
                is = _this.is;
                // Llaves
                key = _this.key;
                dKey = _this.displayKey;
				// Estados.
                stateinit = _this.stateinit;
                state = _this.state;
                // Valores.
                values = _this.values;
                // Numero que utiliza este estado.
                type = _this.type;
                // Si acepta el mismo control varias veces.
                same = _this.same;
                // infinity se pueden agregar elementos infinitos.
                controls = _this.controls
                flags = _this.flags;
                
                // Stats
                stats = _this.stats;
                statsKeys = _this.statsKeys;
                
                // Guardar contenido.
                array_foreach(_this.contents, ExportEffects);
                
                return (!_struct) ? json_stringify(self, true) : self;
            }
        }
        
        /// @desc Como carga este componente.
        /// @param	{Struct} load_struct
        static Import = function(_l)
        {
			/// @param	{Struct.DarkEffect}	DarkEffect
			static ImportEffects = function(_effect) 
            {
                // Obtener llave del efecto para poder buscarlo en la base de datos y crearlo.
                var _key = _effect.key;
                if (dark_exists(_key) ) 
                {
                    // Obtener constructor y crear efecto.
                    var _constructor = dark_get(_key);
                    var _neweffect = new _constructor();
                    // Importar valores
                    _neweffect.Import(_effect);
					
                    // Agregar a la entidad.
                    entity.ref.ControlEffectAdd(_neweffect)
                }
            }
			
            // Version.
            if (_l.is != is) return false;
			// Llaves.
            key = _l.key;
            dKey = _l.displayKey;
            // Por versión.
            switch (_l.version)
            {
                default:
                    // Estados.
                    stateinit = _l.stateinit;
                    state = _l.state;
                    // Valores.
                    values = _l.values;
                    type = _l.type;
                    // Configuracion.
                    same = _l.same;
                    controls = _l.controls;
                    // Estadisticas.
                    stats = _l.stats;
                    statsKeys = _l.statsKeys;
                    // Cargar flags.
                    flags = variable_clone(_l.flags);
                    
                    // Asegurarse que la entidad continue viva.
                    if (!weak_ref_alive(entity) ) return false;
					
                    // Contenido.
                    array_foreach(_l.contents, ImportEffects);
                break;
            }
            
            return true;
		}
    }
    
    /// @desc Añade un estado nuevo.
    /// @param	{String}	control_key
    /// @param	{String}	[display_key]
    /// @param	{Bool}		[state_init]
    static ControlCreate = function(_key, _display, _init=false) 
    {
        var _atom = new AtomState(_key, _display ?? _key, _init);
        controls[$ _key] = _atom;
		
        // Añadir a la lista de controles.
        array_push(controlsKeys, _key);
        
        return (_atom);
    }
    
    /// @desc Obtiene un estado en el control
    /// @param	{String}	control_key
    /// @return {Struct.PartyEntity$$AtomState}
    static ControlGet = function(_key)
    {
        #region DEBUG
        if (__MALL_PARTY_SAFETY) {
        if (!struct_exists(controls, _key) ) {
        throw $"M_Party controlGet:: {_key} no existe";
        }
        }
        #endregion
		// Por Hash.
        if (is_numeric(_key) ) return (struct_get_from_hash(controls, _key) );
        return (struct_get(controls, _key) );
    }
    
    /// @desc Si existe un estado en el control.
    /// @param	{String}	control_key
    /// @return	{Bool}
    static ControlExists = function(_key)
    {
        return (struct_exists(controls, _key) );
    }
    
    /// @desc Elimina un estado del control.
    /// @param	{String}	control_key
    static ControlRemove = function(_key)
    {
        #region DEBUG
        if (__MALL_PARTY_SAFETY) {
        if (!struct_exists(controls, _key) ) {
        throw $"M_Party controlRemove:: {_key} no existe";
        }
        }
        #endregion
        struct_remove(controls, _key);
        return self;
    }
    
    /// @desc Establece un nuevo valor en "values" con el tipo de numero default o diferente.
    /// @param	{String}			control_key
    /// @param	{Array<Real>,Real}	value
    /// @param	{Enum.MALL_NUMTYPE}	type
    static ControlValuesSet = function(_key, _value, _type)
    {
        var _atom = ControlGet(_key);
        if (is_array(_value) ) 
        {
            _atom.values[0] = _value[0];
            _atom.values[1] = _value[1];
        }
		else 
        {
            _atom.values[_type] = _value;
        }
        
        return self;
    }
    
    /// @desc Añade un valor al control (suma/resta)
    /// @param	{String}			control_key
    /// @param	{Array<Real>,Real}	value
    /// @param	{Enum.MALL_NUMTYPE}	type
    static ControlValuesAdd = function(_key, _value, _type)
    {
        var _atom = ControlGet(_key);
        if (is_array(_value) ) 
        {
            _atom.values[0] += _value[0];
            _atom.values[1] += _value[1];
        } 
		else 
        {
            _atom.values[_type] += _value;
        }
        
        return self;
    }
    
    /// @desc Establebe el control a su valor inicial.
    /// @param	{String}	control_key	"all" para reiniciar todos
    static ControlValuesReset = function(_key)
    {
        #region Reiniciar todos.
        if (_key == all) 
        {
            var i=0; repeat(array_length(controlsKeys) ) {ControlValuesReset(controlsKeys[i++] ); }
        }
        #endregion
        
        #region Solo 1
        else
        {
            var _atom = ControlGet(_key);
            _atom.values = array_create(2, 0);
        }
        #endregion
        
        return self;
    }
    
    /// @desc Indica el estado en que se encuentra un estado/estadistica.
    /// @param	{String}	control_key
    /// @return {Bool}
    static ControlStateGet = function(_key) 
    {
        var _atom = ControlGet(_key);
        if (_atom == undefined) return undefined;
        return (_atom.state);
    }
    
    /// @desc Establece el estado de este control
    /// @param	{String}	control_key
    /// @return {Bool}
    static ControlStateSet = function(_key, _state)
    {
        var _atom = ControlGet(_key);
        return (_atom.state = _state);
    }
    
    /// @desc Establece el estado de un control a su valor original. Se puede usar "all" para reiniciar todos.
    /// @param	{String}	control_key 
    static ControlStateReset = function(_key)
    {
        if (_key == all)
        {
            var i=0; repeat(controlsKeys) {ControlStateReset(controlsKeys[i]); }
        }
        else
        {
            var _atom = ControlGet(_key);
            _atom.state = _atom.stateinit;
            
			return self;
        }
    }
    
    /// @desc Indica si hay efectos en este estado.
    /// @param	{String} control_key
    /// @return {Bool}
    static ControlHasContent = function(_key)
    {
        var _atom = ControlGet(_key);
		
        return (array_length(_atom.content) > 0);
    }
    
    /// @desc Agrega un efecto al control que afecta (stat/state/action). Si lo agrega "true" si no "false".
    /// @param	{Struct.DarkEffect} DarkEffect
    /// @return {Bool}
    static ControlEffectAdd = function(_effect)
    {
		/// @param	{Struct.DarkEffect}	DarkEffect
        static EffectSame = function(_effect)
        {
            return (_effect.id == search);
        }
        
        #region Comprobar state
        var _stateKey = _effect.stateKey;
        // Si no existe el control crear
        if (!ControlExists(_stateKey) )
		{
            #region TRACE
            if (__MALL_PARTY_TRACE) {
            show_debug_message($"PartyEntity controlEffectAdd:: {_stateKey} no existe y se va a crear"); 
            }
            #endregion
            ControlCreate(_stateKey);
        }
        
        #endregion
		
        // Obtener control.
        var _control = ControlGet(_stateKey);
        var _content = _control.GetContent();
        var _size = array_length(_content);
        
        #region Comprobar limite.
        // Si no es infinito
        if (_control.controls != infinity)
        {
            // Si supero el limite salir ya que no se pueden agregar más elementos.
            if (_size > _control.controls) return false;
        }
        
        #endregion
        
        #region Comprobar si permite el mismo.
        if (!_control.same) 
        {
            if (array_any(_content, method({search: _effect.id}, EffectSame) ) ) 
            {
                return false;
            }
        }
		
		#endregion
        
        // Al pasar todo agregar al contenido.
        array_push(_content, _effect);
        
		// Ejecutar evento al agregar un efecto nuevo.
        _effect.Added(self);
        
        // Aplicar valor inicial dependiendo del tipo.
        ControlValuesAdd(_stateKey, _effect.value, _effect.type);
        
        // Actualizar valores de las estadisticas.
        UpdateComponents();
        
        return true;
    }
    
    /// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos. 
	/// El filtro default borra el primer elemento.
    /// @param	{String}	control_key	
    /// @param	{Function}	filter		function(DarkEffect, i) {return Bool}
    static ControlEffectRemove = function(_key, _filter)
    {
        // El filtro default borra el primero de la lista
		/// @param	{Struct.DarkEffect} DarkEffect
        static DFilter = function(_effect, i) 
        {
            return (i==0);
        }
		
		// Obtener control.
        var _atom = ControlGet(_key);
        var _content = _atom.GetContent();
        
        #region Filtrar.
        var _index = array_find_index(_content, _filter ?? DFilter);
        // No existe el elemento.
        if (_index == -1) return undefined;
        
        #endregion
        
        // Obtener effecto que se va a eliminar.
        var _effect = _content[_index];
        // Eliminar del array de contenido.
        array_delete(_content, _index, 1);
        // Ejecutar funcion de eliminar.
        _effect.Remove(self);
        
        // Reducir valor.
        ControlValuesAdd(_key, -_effect.value, _effect.type);
        
        // Actualizar valores de las estadisticas.
        UpdateComponents();
        
        return (_effect);
    }
    
    /// @param	{String} control_key
    static ControlEffectRemoveAll = function(_key)
    {
        var _atom = ControlGet(_key);
        var _content = _atom.GetContent();
        // Ciclar por cada efecto.
        for (var i=0, n=array_length(_content); i<n; i++)
        {
            var _effect = _content[i];
            // Evento al remover este efecto.
            _effect.Remove(self);
            // Reducir valor.
            ControlValuesAdd(_key, -_effect.value, _effect.type);
            
			// Eliminar del array y actualizar contenido.
            array_delete(_content, 0, 1);
            n--;
        }
        // Actualizar valores de las estadisticas.
        UpdateComponents();
    }
    
    /// @desc Actualiza un control
    /// @param	{String}	control_key	"all" para actualizar a todos
    /// @param	{Real}		turn_type	0: Inicio del turno, 1: Final del turno, 2: Ambos
    static ControlEffectUpdate = function(_key, _type=0)
    {
        static Loop = false;
        
        var _return = {value: [0, 0], result: false};
        #region Actualizar solo un efecto.
        if (_key != all)
		{
            var _atom = ControlGet(_key);
            var _return = [0, 0];
            // Obtener contenido.
            var _content = _atom.GetContent();
            var _size = array_length(_content);
            
			// Actualizar contenidos.
            for (var i=0; i<_size; i++)
            {
                var _effect = _content[i];
                var _turnType = _effect.turnType;
                // Si no son el mismo tipo de turno saltar.
                if (_turnType != _type) continue;
                
                var _iterator = _effect.GetIterator(_type);
                // Iterar y guardar resultado.
                var _iterate = _iterator.iterate();
				// Obtener valor.
                var _value = _effect.value;
                var _numtype = _effect.type;
                
                // Aun esta funcionando.
                if (_iterate == MALL_ITERATOR.WORKING) 
                {
                    // Ejecutar funcion de actualizar de turno de inicio.
                    if (_type == 0) {_effect.eTurnStart(self); } else
                    if (_type == 1) {_effect.eTurnEnd(self);   }
					// Aumentar valores.
                    ControlValuesAdd(_key, _value, _numtype);
                    // Agregar al valor a regresar.
                    _return.value[_type] += _value;
                }
                // Termino este efecto.
                else if (_iterate == -1)
                {
                    // Ejecutar funcion de termino de efecto.
                    _effect.Ready(self);
                    _effect.isReady = true;
                    // Restar a los valores.
                    ControlValuesAdd(_key, -_value, _numtype);
                    // Agregar al valor a regresar.
                    _return.value[_type] -= _numtype;
                    // Eliminar del array.
                    array_delete(_content, i, 1);
                    
					// Restar al contenido.
                    _size--;
                }
            }
            
			// Actualizar componentes.
            if (!Loop) UpdateComponents("EffectUpdate");
            // Indicar que se completo esta funcion correctamente.
            _return.result = true;
            
            return (_return);
        }
        
        #endregion
        
        #region Actualizar todos
        else 
        {
            // No actualizar por cada elemento.
            Loop = true;
			// Ciclar por cada control.
            var i=0, _rn={}; repeat(array_length(controlsKeys) )
			{
                var _k = controlsKeys[i++];
                _rn[$ _k] = controlEffectUpdate(_k, _type);
            }
            // Actualizar componentes.
            updateComponents("EffectUpdate");
            // Evitar.
            Loop = false;
            
            return _rn;
        }
        
        #endregion
    }
    
    #endregion
    
    #region -- COMANDOS
    /// @desc Crea una nueva categoria para los comandos.
    /// @param	{String} category_key
    static CatCreate = function(_key)
    {
        // Agregar categoria de comandos si no existe.
        if (!struct_exists(categories, _key) )
        {
			// Añadir categoria.
            categories[$ _key] = { keys:[] };
            // Añadir a la lista.
            array_push(categoriesKeys, _key);
        }
        
        return self;
    }
    
    /// @desc Obtiene todas las categorias.
    /// @return {Array<string>}
    static CatAll = function()
    {
        return (categoriesKeys);
    }
    
    /// @desc Devuelve la primera categoria que posee el comando.
    /// @param	{String} command_key
    static CatSearch = function(_key)
    {
		/// @param	{String} key
		static CommandSearch = function(_name, _str)
        {
            if (struct_exists(_str, key) ) {result = _name; exit; }
        }
		
		// Crear un closure.
        var _closure = {key: _key, result: undefined};
		
		// Ciclar por cada categoria.
        struct_foreach(categories, method(_closure, CommandSearch) );
        
        return (_closure.result);
    }
    
    /// @desc Fuerza el siguiente comando a ejecutar.
    /// @param	{String} category_key    
    /// @param	{String} command_key     
    static CatForcedSet = function(_category, _command)
    {
        categoryForced = _category;
        commandForced =  _command;
        
        return self;
    }
    
    /// @desc Devuelve el comando forzado.
    static CatForcedGet = function()
    {
        if (categoryForced == "") return undefined;
        if (commandForced  == "") return undefined;
        return (CatCommandGet(categoryForced, commandForced) );
    }
    
    /// @desc Funcion para obtener un comando.
    eBattleCommandGet = function() {}
    
    /// @desc Establece una funcion para obtener comandos en una batalla de wate.
    /// @param {Function}	battle_function   
    static CatBattleSet = function(_fn) 
    {
        eBattleCommandGet = method(self, _fn);
        return self;
    }
    
    /// @param	{String}	category_key
    /// @param	{String}	dark_command_key
    static CatCommandAdd = function(_cat_key="default", _co_key)
    {
		#region SAFETY
        if (__MALL_PARTY_SAFETY) {
        if (_co_key == undefined)	{show_debug_message($"M_Party: Comando es undefined");} else
        if (!dark_exists(_co_key) )	{show_debug_message($"M_Party: {_co_key} no existe en la D.B de Dark"); }
        }
        #endregion
		
        // Si no existe la categoria crear.
        if (!struct_exists(categories, _cat_key) ) CatCreate(_cat_key);
        // Obtener categoria.
        var _category = categories[$ _co_key];
		// Si no existe el comando en la categoria agregar.
        if (!struct_exists(_category, _co_key) )
        {
            _category[$ _co_key] = dark_get(_co_key);
            array_push(_category.keys, _co_key);
        }
		// Si ya posee el comando.
        else
        {
            if (__MALL_DARK_TRACE) {
            show_debug_message($"M_Party: Esta entidad ya posee el comando {_co_key}");
            }
        }
		
        return self;
    }
    
    /// @param	{String}	category_key
    /// @param	{String}	dark_command_key
    static CatCommandGet = function(_cat_key, _co_key) 
    {
        return (commands[$ _cat_key][$ _co_key] );
    }
    
    /// @desc Devuelve todas las llaves de comando que posee una categoria.
    /// @param	{String}	category_key
    /// @return {Array<String>}
    static CatCommandAll = function(_cat_key)
    {
        var _command = commands[$ _cat_key];
        return (_command.keys);
    }
    
    /// @param	{String}	category_key
    static CatCommandRandom = function(_cat_key)
    {
        // Si no pasa una categoria busca una al azar.
		var _size = array_length(categoriesKeys) - 1;
        var _ckey = _cat_key ?? categoriesKeys[irandom(_size) ];
        // Obtener todos los comandos.
        var _commands = CatCommandAll(_ckey);
        var _random = irandom(array_length(_commands) - 1);
		
		// Obtener comando al azar.
        return (CatCommandGet(_ckey, _commands[_random] ) );
    }
    
    #endregion
    
    #region -- MISQ
    /// @desc Actualiza stats.
    static UpdateComponents = function(_from="")
    {
        var _slotStats = {};
        var _controlStats = {};
        var _statKeys = mall_get_stat_keys();
        var _statSize = array_length(_statKeys), _stat, _statKey;
		
        // Indices.
		var i=0, j=0, k=0;
        
		#region Obtener estadisticas de los objetos equipados.
        i=0; repeat(array_length(slotsKeys) ) 
        {
            var _slotkey = slotsKeys[i];
            var _slot = SlotGet(_slotkey);
            if (_slot.desequip) 
            {
                _slot.desequip = false; 
                i++;
				
                continue;
            }
			
			// Hay un objeto equipado.
            var _item = _slot.equipped;
            if (!is_undefined(_item) ) 
            {
                var _itemStatsKeys = _item.statsKeys;
                j=0; repeat(array_length(_itemStatsKeys) ) 
                {
                    var _itemStatKey = _itemStatsKeys[j];
                    if (struct_exists(_slotStats, _itemStatKey) )
                    {
                         // Obtener valores de la estadisticas.
                        var _itemStat = _item.stats[$ _itemStatKey];
                        // Obtener valores
                        var _itemValue = _itemStat[0];
                        var _itemType = _itemStat[1];
						
                        // Dependiendo del itemtype.
						switch (_itemType)
                        {
                            case MALL_NUMTYPE.REAL:
                                _slotStats[$ _itemStatKey] += _itemValue; 
                            break;
                        
                            case MALL_NUMTYPE.PERCENT:
                                var _stat = StatGet(_itemStatKey);
                                _slotStats[$ _itemStatKey] += (_stat.peak * _itemValue) / 100;
                            break;
                        }
                    }
                    
                    j++;
                }
            }
            
            i++;
        }
        
        #endregion
        
        #region Actualizar estados.
        i=0; repeat(array_length(controlsKeys) ) 
        {
            var _controlKey = controlsKeys[i];
            var _control = ControlGet(_controlKey);
            var _cnStats = _control.stats;
            // Ciclar por cada estadistica.
            j=0; repeat(_statSize) 
            {
                // llave de estadistica.
                _statKey = _statKeys[j];
                // Solo si existe el valor en el struct.
                if (struct_exists(_cnStats, _statKey) && struct_exists(_controlStats, _statKey) ) 
                {
                    var _cnStat = _cnStats[$ _statKey] ?? 0;
                    // Valor real (0).
                    var _cnReal = _cnStat[0];
                    // Valor porcentual (0).
                    var _cnPerc = _cnStat[1];
                    // Cambiar valor del control.
                    _stat = StatGet(_statKey);
                    _controlStats[$ _statKey] = _cnReal + ((_stat.peak * _cnPerc) / 100);
                }
                
                j++;
            }
            
            i++;
        }
        
        #endregion
        
        #region Actualizar Estadisticas.
        i=0; repeat(_statSize) 
        {
            var _statKey = _statKeys[i]
            var _stat = StatGet(_statKey);
            // Equipamiento (no puede ser menor al limite menor.
            var _equipment = _stat.peak + _slotStats[$ _statKey];
            _stat.equipment = max(_equipment, _stat.limitMin);
            
			// Control y efectos.
            var _control = _controlStats[$ _statKey];
            _stat.control = max(_stat.equipment + _control, _stat.limitMin);
            
            i++;
        }
        
        #endregion
    }
    
    /// @desc Guarda los datos de esta entidad en json
	/// @param	{Bool} [struct] devolver un struct o un JSON.
    static Export = function(_struct=false) 
    {
        var _this = self;
        var _save =  {
            categories: {},	categoriesKeys:	variable_clone(_this.categoriesKeys), 
            slots: {},		slotsKeys:		variable_clone(_this.slotsKeys), 
            controls: {},	controlsKeys:	variable_clone(_this.controlsKeys),
            stats: {}
        };
        
        with (_save) 
        {
            // Guardar version en la que se hizo el save.
            version = __MALL_MY_VERSION;
            is = _this.is;
            key = _this.key;
            dKey = _this.displayKey;
            // Grupo al que pertenece.
            group = _this.group;
            index = _this.index;
            // Nivel.
            level = _this.level;
            // Guardar Stats.
            var _keys = mall_get_stat_keys(), _key;
            var i=0; repeat(array_length(_keys) ) 
            {
                var _key = _keys[i];
                stats[$ _key] = _this.StatGet(_key).Export(true);
                i++;
            }
            // Guardar Slots.
            i=0; repeat(array_length(_this.slotsKeys) ) 
            {
                _key = _this.slotsKeys[i];
                slots[$ _key] = _this.SlotGet(_key).Export(true);
                i++;
            }
            
			// Guardar Control.
            i=0; repeat(array_length(_this.controlsKeys) ) 
            {
                _key = _this.controlsKeys[i];
                controls[$ _key] = _this.ControlGet(_key).Export(true);
                i++;
            }
            
            // Guardar categorias y comandos.
            var _cat;
            i=0; repeat(array_length(_this.categoriesKeys) ) 
            {
                _key = _this.categoriesKeys[i];
                _cat = _this.categories[$ _key];
                var _ckeys = variable_clone(_cat.keys);
                var _cstrc = {keys: _ckeys};
                // 
                var j=0; repeat(array_length(_ckeys) ) 
                {
                    var _ckey = _ckeys[j];
                    var _comm = _cat[$ _ckey];
                    if (!is_undefined(_comm) ) {_cstrc[$ _ckey] = _comm.key; }
                    j++;
                }
				
                // Agregar version.
                _cstrc[$ "version"] = __MALL_MY_VERSION;
                categories[$ _key] = _cstrc;
                
				i++;
            }
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Carga desde un struct datos
    /// @param	{String} load_struct
    /// @return {Struct.PartyEntity}
    static Import = function(_l)
    {
        if (_l.is != is) exit;
        switch (_l.version)
		{
			default:
		        // Llaves.
		        key = _l.key;
		        dKey = _l.dKey;
		        // Grupo.
		        group = _l.group;
		        index = _l.index;
		        // Cargar nivel.
		        level = _l.level;
		        // Subir de nivel.
		        StatLevelUp(false, 0, true);
				
		        var i, _key, _keys, _str;
				
		        // Cargar estadisticas.
		        _keys = mall_get_stat_keys();
		        i=0; repeat(array_length(_keys) ) 
		        {
		            _key = _keys[i];
		            // Obtener valores guardados
		            _str = _l.stats[$ _key];
		            // Cargar
		            StatGet(_key).Import(_str);
		            
					i++;
		        }
        
		        // Cargar slots.
		        i=0; repeat(array_length(_l.slotsKeys) ) 
		        {
		            _key = slotsKeys[i];
		            _str = _l.slots[$ _key];
		            // Cargar slots
		            var _slot = SlotGet(_key);
					
		            // Si no existe.
		            if (is_undefined(_slot) ) 
		            {
		                SlotCreate(_slot.key).Import(_str);
		            }
		            else 
					{
		                _slot.Import(_str);
		            }
            
		            i++;
		        }
        
		        // Cargar control.
		        i=0; repeat(array_length(_l.controlsKeys) ) 
		        {
		            _key = controlsKeys[i];
		            _str = _l.controls[$ _key];
		            // Cargar control
		            var _control = ControlGet(_key);
		            if (is_undefined(_control) ) 
		            {
						ControlCreate(_control).Import(_str);
		            }
		            else 
		            {
						_control.Import(_str);
		            }
            
		            i++;
		        }
        
		        // Cargar categorias y comandos.
		        i=0; repeat(array_length(_l.categoriesKeys) )
				{
		            var _key = _l.categoriesKeys[i];
		            var _cat = _l.categories[$ _key];
		            // Comprobar que existe la categoria
		            if (!struct_exists(categories, _key) ) {CatCreate(_key); }
		            // Agregar comandos.
		            var j=0; repeat(array_length(_cat.keys) ) 
		            {
		                var _ckey = _cat.keys[j];
		                // Obtener comando para agregar en la categoria.
		                CatCommandAdd(_key, _ckey);
                
		                j++;
		            }
            
		            i++;
		        }
        
		        // Actualizar componentes.
		        UpdateComponents();
        
		        return self;			
			
			break;
		}
    }
  
    /// @param	{String}			item_key
    /// @param	{Real, Array<Real>}	quantity
    /// @param	{Real}				probability
    static BtAddDrop = function(_key, _value, _probability)
    {
        array_push(drops, {
			// Llaves.
            key: _key,
            // Puede ser un array.
            value:	!is_array(_value) ? _value : irandom_range(_value[0], _value[1] ),
            prob:	_probability
        });
        
		return self;
    }
    
    /// @desc Avanza el turno de esta entidad.
    static BtTurnAdvance = function()
    {
        turn++;
        if (__MALL_PARTY_TRACE) __mall_entity_trace($"M_PartyEntity: ha avanzado el turno personal {turn}." );
        return self;
    }
    
    /// @desc Añade un evento a los turnos.
    /// @param	{Real}		turn		
    /// @param	{Funcion}	function	
    static BtTurnEventAdd = function(_turn, _fn)
    {
        array_insert(turnEvent, _turn, _fn);
        return self;
    }
    
    /// @desc Ejecuta un evento.
    static BtTurnEventExecute = function()
    {
        if (turn < array_length(turnEvent) )
        {
            var _event = turnEvent[turn];
            if (is_callable(_event) ) return (_event() );
        }
        
        return undefined;
    }
    
    /// @desc Se utiliza en los combates y permite a esta instancia buscar sus propios objetivos 
    /// sin usar el default del DarkCommand.
	eBattleGetTarget = undefined;
    
    /// @desc Establecer como esta entidad busca objetivos.
    /// @param	{Function}	function  
    /// @param	{Struct}	[ref]     
    static BtSetTarget = function(_fn, _tg)
    {
        
        if (is_undefined(_tg) ) {eBattleGetTarget = method(self, _fn); }
        else                    {eBattleGetTarget = method(_tg,  _fn); }
        return self;
    }
    
    /// @desc Que hacer cuando no encuentra un objetivo.
    eBattleGetTargetFail = undefined;
    
    /// @desc Que hacer cuando no encuentra un objetivo.
    /// @param	{Function}	function  
    /// @param	{Struct}	[ref]
    static BtSetTargetFail = function(_fn, _tg)
    {
        if (_tg==undefined) {eBattleGetTargetFail = method(self, _fn); }
        else                {eBattleGetTargetFail = method(_tg , _fn); }
        return self;
    }
	
    #endregion
	
	#region PRIVATE
	
    /// @ignore
    /// @param	{String} stat_key
    static __Init = function(_key)
    {
        var _stat = mall_get_stat(_key);
        stats[$ _key] = new AtomStat(_stat);
        
		// Iniciar funcion de inicio.
        _stat.eInStart(self);
    }
    
    /// @ignore
    /// @desc Mostrar mensajes en consola
    /// @param	{String} message Mensage a mostrar en la consola
    static __mall_entity_trace = function(_msg)
    {
        show_debug_message($"M_Party {key}: {_msg}");
    }
    
    /// @ignore
    /// @desc Error
    /// @param	{String} error Error a mostrar
    static __mall_entity_error = function(_msg)
    {
        throw ($"M_Party {key}: {_msg}");
    }
    
    /// @ignore
    static __mall_entity_trace_stats = function()
    {
        var _str = "";
        var i=0; repeat(array_length(statsKeys) ) 
        {
            var _key = statsKeys[i];
            var _stat = StatGet(_key);
            
            _str += $"{_key}: control: [{_stat.control}], current: [{_stat.current}], ";
            
            i++;
        }
		
        return (__mall_entity_trace(_str) );
    }
    
    /// @ignore
    static __mall_entity_trace_controls = function()
    {
        var _str = "";
        var i=0; repeat(array_length(controlsKeys) ) 
        {
            var _ckey = controlsKeys[i++];
            var _control = ControlGet(_ckey);
            
            _str += $"{_ckey}: {_control.state}";
        }
		
		return (__mall_entity_trace(_str) );
    }
    
	#endregion
}


