// Feather ignore all
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
	ai_instance = undefined;	// Instancia del cerebro de la IA 
	faction = "NEUTRAL";		// Facción de la entidad
	aggro = 0;					// Nivel de amenaza
	learnset = [];				// Lista de comandos a aprender
	
	// Variables propias fuera del sistema Mall.
	vars = {};
	
	// --- Estado de la Instancia ---
	level = 1;
    stats = {};
    slots = {};
    states = {};
    commands = {};
	flags = {};
	
	// -- Eventos --
	
	/// @desc Funcion al terminar de subir de nivel.
	/// @context self
	event_on_level_up = "";
	
	/// @desc Funcion para comprobar si debe o no subir de nivel.
    /// @context self
	event_on_level_check = "";
	
	/// @context self
	event_on_action_select = "";
	
	#region MÉTODOS PRIVADOS DE CARGA
	
	static __LoadFunctions = function(_template)
	{
		event_on_level_up =		method(self, mall_get_function(_template.event_on_level_up) );
		event_on_level_check =	method(self, __mall_get_function_check_true(_template.event_on_level_check) );
		
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
		
        if (variable_struct_exists(_template, "slots") ) 
		{
            var _template_slots = _template.slots;
            var _template_slot_keys = variable_struct_get_names(_template_slots);
            for (var i = 0; i < array_length(_template_slot_keys); i++) 
			{
                var _slot_key = _template_slot_keys[i];
                var _slot_data = _template_slots[$ _slot_key];
                
                if (is_struct(_slot_data) ) {
                    if (variable_struct_exists(_slot_data, "permited")) 
					{
                        var _permited_mods = _slot_data.permited;
                        for (var j = 0; j < array_length(_permited_mods); j++) {
                            var _mod_string = _permited_mods[j];
                            var _prefix = string_char_at(_mod_string, 1);
                            var _key = string_delete(_mod_string, 1, 1);
                            
                            if (_prefix == "+") { SlotPermitedAdd(_slot_key, _key); } 
							else if (_prefix == "-") { SlotPermitedRemove(_slot_key, _key); }
                        }
                    }
					
                    if (variable_struct_exists(_slot_data, "equip")) 
					{
                        var _to_equip = _slot_data.equip;
                        if (is_array(_to_equip)) 
						{
                            for (var j = 0; j < array_length(_to_equip); j++) { SlotEquip(_slot_key, _to_equip[j]); }
                        }
						else 
						{ 
							SlotEquip(_slot_key, _to_equip); 
						}
                    }
                } 
				else 
				{
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
		exp_drop =	_template[$ "exp_drop"]	?? exp_drop;
		drops =		_template[$ "drops"]	?? drops;
		faction =	_template[$ "faction"]	?? faction;
		learnset =	_template[$ "learnset"]	?? learnset;
		flags =		_template[$ "flags"]	?? flags;
		
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
        if (!event_on_level_check(_levels_to_add) ) exit; 
		
		var _old_level = level;
        level = clamp(level + _levels_to_add, __MALL_PARTY_LEVEL_MIN, __MALL_PARTY_LEVEL_MAX);
        
		// Comprobar si se han aprendido nuevos comandos
		for (var i = 0; i < array_length(learnset); i++) 
		{
			var _learn_data = learnset[i];
			// Si el nivel requerido está entre el nivel antiguo y el nuevo
			if (_learn_data.level > _old_level && _learn_data.level <= level) 
			{
				CommandAdd(_learn_data.category, _learn_data.command);
			}
		}
		
		// Calcular las nuevas estadisticas.
        RecalculateStats();
        
        // Ejecutar funcion al subir de nivel.
		event_on_level_up();
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

	/// @desc Añade amenaza (aggro) a la entidad.
	/// @param {Real} amount La cantidad de amenaza a añadir.
	static AggroAdd = function(_amount)
	{
		aggro += _amount;
		return self;
	}
	
	/// @desc Obtiene la amenaza (aggro) actual de la entidad.
	/// @return {Real}
	static AggroGet = function()
	{
		return aggro;
	}
	
	/// @desc Resetea la amenaza (aggro) de la entidad a 0.
	static AggroReset = function()
	{
		aggro = 0;
		return self;
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

/// @desc Registra una instancia de entidad en el gestor global.
/// @param {Struct.PartyEntity} entity La instancia de la entidad a registrar.
function party_register_instance(_entity)
{
    if (is_struct(_entity) && variable_struct_exists(_entity, "id"))
    {
        Systemall.__instances[$ _entity.id] = _entity;
    }
}

/// @desc Elimina una instancia de entidad del gestor global.
/// @param {Struct.PartyEntity} entity La instancia de la entidad a eliminar.
function party_unregister_instance(_entity)
{
    if (is_struct(_entity) && variable_struct_exists(_entity, "id"))
    {
        struct_remove(Systemall.__instances, _entity.id);
    }
}

/// @desc Obtiene una instancia de entidad por su ID único.
/// @param {String} id El ID de la instancia.
/// @return {Struct.PartyEntity} La instancia de la entidad, o undefined si no se encuentra.
function party_get_instance(_id)
{
    return Systemall.__instances[$ _id];
}