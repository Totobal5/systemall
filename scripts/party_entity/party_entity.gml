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
function EntityStatInstance(_template, _entity) constructor
{
	// Referencia a la plantilla MallStat
    parent_entity = _entity;
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
	
	// --- Eventos ---
	
	/// @desc Se ejecuta una vez cuando la instancia es creada para una entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
    event_on_start =		method(parent_entity, mall_get_function( template[$ "event_on_start"] ) );
	
	/// @desc (Sin implementación actual en el motor)
    event_on_end =			method(parent_entity, mall_get_function( template[$ "event_on_end"] ) );
	
	/// @desc Se ejecuta en cada llamada a RecalculateStats, después de calcular el peak_value.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
    event_on_update =		method(parent_entity, mall_get_function( template[$ "event_on_update"] ) );
	
	/// @desc Se ejecuta para calcular el peak_value de la estadística. Debe devolver el nuevo valor.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
	event_on_level_up =	method(parent_entity, __mall_get_function_stat_level_up( template[$ "event_on_level_up"] ) );	
	
	/// @desc (Para stats standalone) Comprueba si la estadística puede subir de nivel. Debe devolver bool.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
	event_on_level_check =	method(parent_entity, __mall_get_function_check_true( template[$ "event_on_level_check"] ) );	

	/// @desc Se ejecuta cuando se equipa un objeto en CUALQUIER slot de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde se equipó el objeto.
    event_on_equip =		method(parent_entity, mall_get_function( template[$ "event_on_equip"] ) );
	
	/// @desc Se ejecuta cuando se desequipa un objeto de CUALQUIER slot de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot de donde se desequipó el objeto.
    event_on_desequip =		method(parent_entity, mall_get_function( template[$ "event_on_desequip"] ) );

    // Eventos de Turno
	
	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
    event_on_turn_update =	method(parent_entity, mall_get_function( template[$ "event_on_turn_update"] ) );
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
    event_on_turn_start =	method(parent_entity, mall_get_function( template[$ "event_on_turn_start"] ) );
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStatInstance} stat_instance La instancia actual.
    event_on_turn_end =		method(parent_entity, mall_get_function( template[$ "event_on_turn_end"] ) );	
	
    /// @desc Recalcula el valor base de la estadística (peak_value).
    static Recalculate = function(_entity)
    {
		// Si sube de nivel de manera independiente.
		if (template.is_standalone_level)
		{
			if (is_callable(event_on_level_check) && event_on_level_check(self) )
			{
				return;
			}
		}
		
        if (is_callable(event_on_level_up) )
        {
            peak_value = event_on_level_up(self);
        }
        else
        {
            peak_value = base_value;
        }
		
		if (is_callable(event_on_update) ) event_on_update(self);
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

    // --- Eventos ---
	
	/// @desc Se ejecuta una vez cuando la instancia es creada para una entidad.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance La instancia actual.
	event_on_start =	method(parent_entity, mall_get_function( template[$ "event_on_start"] ) );
	
	/// @desc (Sin implementación actual en el motor)
	event_on_end =		method(parent_entity, mall_get_function( template[$ "event_on_end"] ) );
	
	/// @desc Se ejecuta en cada llamada a RecalculateStats.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance La instancia actual.
	event_on_update =	method(parent_entity, mall_get_function( template[$ "event_on_update"] ) );
    
	// Eventos de Turno
	
	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance La instancia actual.
	event_on_turn_update =	method(parent_entity, mall_get_function( template[$ "event_on_turn_update"] ) );
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance La instancia actual.
	event_on_turn_start =	method(parent_entity, mall_get_function( template[$ "event_on_turn_start"] ) );
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance La instancia actual.
	event_on_turn_end =		method(parent_entity, mall_get_function( template[$ "event_on_turn_end"] ) );
    
	// Eventos de Equipamiento
	
	/// @desc Se ejecuta después de que un objeto ha sido equipado exitosamente en este slot.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde fue equipado.
	/// @param {Struct.PocketItem} item_template El objeto que fue equipado.
	event_on_equip =	method(parent_entity, mall_get_function( template[$ "event_on_equip"] ) );
	
	/// @desc Se ejecuta después de que un objeto ha sido desequipado exitosamente de este slot.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde fue equipado.
	/// @param {Struct.PocketItem} item_template El objeto que fue desequipado.
	event_on_desequip =	method(parent_entity, mall_get_function( template[$ "event_on_desequip"] ) );

	/// @desc Valida si un objeto se puede equipar. Debe devolver bool.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde será equipado.
	/// @param {Struct.PocketItem} item_template El objeto a comprobar.
	event_can_equip =		method(parent_entity, __mall_get_function_check_true( template[$ "event_can_equip"] ) );
	
	/// @desc Valida si el objeto actual se puede desequipar. Debe devolver bool.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde será desequipado.
	/// @param {Struct.PocketItem} item_template El objeto a comprobar.
	event_can_desequip =	method(parent_entity, __mall_get_function_check_true( template[$ "event_can_desequip"] ) );
	
	/// @desc Se ejecuta cuando la entidad ataca.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot que esta atacando.
	/// @param {Struct.PartyEntity} target El objetivo del ataque.
	event_on_attack =		method(parent_entity, mall_get_function( template[$ "event_on_attack"] ) );

	/// @desc Se ejecuta cuando la entidad es atacada.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot que esta defendiendo.
	/// @param {Struct.PartyEntity} attacker El atacante.
	event_on_defend =		method(parent_entity, mall_get_function( template[$ "event_on_defend"] ) );

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
		var _can_equip_slot = event_can_equip(self, _item_to_equip);
		var _can_equip_item = _item_to_equip.event_can_equip(parent_entity, self);
		
		if (_can_equip_slot && _can_equip_item)
		{
			// --- Todas las comprobaciones pasaron, proceder con el equipamiento ---
			array_copy(last_equipped_items, 0, equipped_items, 0, array_length(equipped_items) );
			array_push(equipped_items, _item_key);
			
			// Disparar eventos de equipamiento
			event_on_equip(self, _item_to_equip);
			_item_to_equip.event_on_equip(parent_entity, self);
			
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
		var _can_desequip_slot = event_can_desequip(self, _item_to_remove);
		var _can_desequip_item = _item_to_remove.event_can_desequip(parent_entity, self);

		if (_can_desequip_slot && _can_desequip_item)
		{
			// --- Todas las comprobaciones pasaron, proceder con el desequipamiento ---
			_result.unequipped_item = _item_key;
			
			// Disparar eventos de desequipamiento
			event_on_desequip(self, _item_to_remove);
			_item_to_remove.event_on_desequip(parent_entity, self);
			
			// Limpiar el slot
			array_copy(last_equipped_items, 0, equipped_items, 0, array_length(equipped_items) );
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
/// @param {Struct.MallState} state_template
function EntityStateInstance(_template, _entity) constructor
{
	// Referencia a la plantilla MallState
	template = _template;
	
	// A quien pertenece esta instancia.
	parent_entity = _entity;
	
	// Valor booleano de estado actual de esta instancia
	boolean_value = template.boolean_value;
	reset_value = template.reset_value;
	
	// Array para contener las instancias de efectos activos
	effects = [];
	
	// Referencias a la estadisticas del template.
	stats = template.stats;
	
    // --- Llaves de Eventos ---
	
	/// @desc Se ejecuta cuando la instancia cambia su valor booleano y cuando es creada.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	event_on_start =	method(parent_entity, mall_get_function( template[$ "event_on_start"] ) );
	
	/// @desc Se ejecuta cuando la instancia cambia su valor booleano al original.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	event_on_end =		method(parent_entity, mall_get_function( template[$ "event_on_end"] ) );
	
	/// @desc Se ejecuta en cada llamada a RecalculateStats.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.	
	event_on_update =	method(parent_entity, mall_get_function( template[$ "event_on_update"] ) );
	
	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.	
	event_on_turn_update =	method(parent_entity, mall_get_function( template[$ "event_on_turn_update"] ) );
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.	
	event_on_turn_start =	method(parent_entity,mall_get_function( template[$ "event_on_turn_start"] ) );
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	event_on_turn_end =		method(parent_entity,mall_get_function( template[$ "event_on_turn_end"] ) );

	/// @desc Se ejecuta cuando se equipa un objeto en CUALQUIER slot de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde se equipó el objeto.
    event_on_equip =		method(parent_entity,mall_get_function( template[$ "event_on_equip"] ) );
	
	/// @desc Se ejecuta cuando se desequipa un objeto de CUALQUIER slot de la entidad.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot de donde se desequipó el objeto.
    event_on_desequip =		method(parent_entity,mall_get_function( template[$ "event_on_desequip"] ) );

	/// @desc Se ejecuta después de que un efecto es añadido a este estado.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	/// @param {Struct.DarkEffectInstance} effect_instance El efecto que fue añadido.
	event_on_add_effect =	method(parent_entity, mall_get_function( template[$ "event_on_add_effect"] ) );
	
	/// @desc Se ejecuta después de que un efecto es eliminado de este estado.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	/// @param {Struct.DarkEffectInstance} effect_instance El efecto que fue eliminado.
	event_on_remove_effect = method(parent_entity, mall_get_function( template[$ "event_on_remove_effect"] ) );

	/// @desc Valida si un efecto puede ser añadido a este estado. Debe devolver bool.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	/// @param {Struct.DarkEffect} effect_template La plantilla del efecto a añadir.
	event_can_add_effect = method(parent_entity, __mall_get_function_check_true( template[$ "event_can_add_effect"] ) );

	/// @desc Valida si un efecto puede ser eliminado de este estado. Debe devolver bool.
	/// @context PartyEntity
	/// @param {Struct.EntityStateInstance} state_instance La instancia actual.
	/// @param {Struct.DarkEffectInstance} effect_instance El efecto a eliminar.
	event_can_remove_effect = method(parent_entity, __mall_get_function_check_true( template[$ "event_can_remove_effect"] ) );
	
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
    
	// El valor numérico del efecto (ej: 15 de daño).
    value = template.value;
	// El tipo de valor (real o porcentual).
    num_type = template.num_type;
	// stats
	stats = template.stats;	
	// Copiar los parametros del template.
	params = variable_clone(template.params);
	
    // Cada instancia tiene sus propios iteradores
	var _duration = 1;
	var _repeats = 0;
	
	if (struct_exists(template, "iterator_start_config") )
	{
		var _i = template.iterator_start_config;
		_duration = _i[$ "duration"] ?? 1;
		_repeats = _i[$ "repeats"] ?? 0;
	}
	
    iterator_start = (new MallIterator() ).Configure(_duration, _repeats);
	
	if (struct_exists(template, "iterator_end_config") )
	{
		var _i = template.iterator_end_config;
		_duration = _i[$ "duration"] ?? 1;
		_repeats = _i[$ "repeats"] ?? 0;
	}
	
    iterator_end = (new MallIterator() ).Configure(_duration, _repeats);
	
	// -- Eventos --
	
	/// @desc Se ejecuta cuando el efecto es añadido a un estado.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity
	/// @param {Struct.EntityStateInstance} state_instance La instancia del estado que contiene este efecto.
    event_on_start =		method(self, mall_get_function( template[$ "event_on_start"] ) );
	
	/// @desc Se ejecuta cuando el efecto es eliminado de un estado.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity	
	/// @param {Struct.EntityStateInstance} state_instance La instancia del estado que contenía este efecto.
    event_on_end =			method(self, mall_get_function( template[$ "event_on_end"] ) );
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity	
	/// @param {Struct.DarkEffectInstance} effect_instance La instancia actual del efecto.
    event_on_turn_start =	method(self, mall_get_function( template[$ "event_on_turn_start"] ) );
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity	
	/// @param {Struct.DarkEffectInstance} effect_instance La instancia actual del efecto.
    event_on_turn_end =		method(self, mall_get_function( template[$ "event_on_turn_end"] ) );


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
	exp_value = 0;				// 
	loot_table_key = "";		// 
	bonus_drops = [];
	
	ai_instance = undefined;	// Instancia del cerebro de la IA 
	faction = "NEUTRAL";		// Facción de la entidad
	aggro = 0;					// Nivel de amenaza
	learnset = [];				// Lista de comandos a aprender
	
	// Variables propias fuera del sistema Mall.
	vars = {};
	
	// --- Estado de la Instancia ---
	level =		1;
    stats =		{};
    slots =		{};
    states =	{};
    commands =	{};
	flags =		{};
	
	// -- Eventos --
	
	/// @desc Se ejecuta al final de LevelUp, después de recalcular stats.
	/// @context PartyEntity
	/// @param {EntityStatInstance} stat	stat que esta subiendo de nivel
    event_on_level_up = "";
	
	/// @desc Se ejecuta al inicio de LevelUp para validar si puede subir de nivel. Debe devolver bool.
	/// @context PartyEntity
	/// @param {Real} levels_to_add La cantidad de niveles que se intentan subir.
    event_on_level_check = "";
	
	/// @desc Se ejecuta para que la IA decida una acción. Debe devolver una WateAction.
	/// @context PartyEntity
	/// @param {Struct} battle_context El contexto de la batalla.
	event_on_action_select = "";

	/// @desc Se ejecuta después de que un objeto es equipado en CUALQUIER slot.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot afectado.
	/// @param {Struct} result El resultado de la operación de equipamiento.
	event_on_equip = "";

	/// @desc Se ejecuta después de que un objeto es desequipado de CUALQUIER slot.
	/// @context PartyEntity
	/// @param {Struct.EntitySlotInstance} slot_instance El slot afectado.
	/// @param {Struct} result El resultado de la operación de desequipamiento.
    event_on_desequip = "";
	
	#region MÉTODOS PRIVADOS DE CARGA
	
	static __LoadFunctions = function(_template)
	{
		event_on_level_up =		method(self, mall_get_function(_template[$ "event_on_level_up"]) );
		event_on_level_check =	method(self, __mall_get_function_check_true(_template[$ "event_on_level_check"] ) );
		
		event_on_action_select = method(self, mall_get_function(_template[$ "event_on_action_select"] ) );
		
		event_on_equip = method(self, mall_get_function(_template[$ "event_on_equip"] ) );
		event_on_desequip = method(self, mall_get_function(_template[$ "event_on_desequip"] ) );
	}
	
	/// @desc (Privado) Carga las instancias de stats y aplica los valores base.
	/// @param {Struct} _template La plantilla de la entidad.
	/// @ignore
	static __LoadStats = function(_template)
	{
        var _all_stat_keys =	mall_get_stat_keys();
		var _all_stat_length =	array_length(_all_stat_keys);
		// Recorrer cada estadistica del sistema para añadirlo a la entidad.
        for (var i = 0; i < _all_stat_length; i++) 
		{
            var _stat_key = _all_stat_keys[i];
            var _stat_instance = new EntityStatInstance(mall_get_stat(_stat_key), self);
			
			stats[$ _stat_key] = _stat_instance;
			
			// Ejecutar funcion al iniciarse.
			var _start_event = _stat_instance.event_on_start;
			if (is_callable(_start_event) ) _start_event(_stat_instance);
        }
		
		// Cargar valores base.
		if (variable_struct_exists(_template, "stats") ) 
		{
			var _template_stats =		_template.stats;
			var _template_stat_keys =	variable_struct_get_names(_template_stats);
			var _template_stat_length =	array_length(_template_stat_keys);
			
			for (var i = 0; i < _template_stat_length; i++) 
			{
				var _stat_key = _template_stat_keys[i];
				if (struct_exists(stats, _stat_key) ) 
				{
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
        var _all_slot_length = array_length(_all_slot_keys);
		
		for (var i = 0; i < _all_slot_length; i++) 
		{
            var _slot_key = _all_slot_keys[i];
			var _slot_instance = new EntitySlotInstance(mall_get_slot(_slot_key), self);
			
            slots[$ _slot_key] = _slot_instance;
			
			// Ejecutar funcion al iniciarse.
			var _start_event = _slot_instance.event_on_start;
			if (is_callable(_start_event) ) _start_event(_slot_instance);			
        }
		
        if (variable_struct_exists(_template, "slots") ) 
		{
            var _template_slots = _template.slots;
            var _template_slot_keys = variable_struct_get_names(_template_slots);
			var _template_slot_keys_length = array_length(_template_slot_keys);
			
            for (var i = 0; i < _template_slot_keys_length; i++) 
			{
                var _slot_key = _template_slot_keys[i];
                var _slot_data = _template_slots[$ _slot_key];
                
                if (is_struct(_slot_data) ) 
				{
                    // Configurar los objetos permitidos en cada slot por instancia.
					if (variable_struct_exists(_slot_data, "permited") )
					{
                        var _permited_mods = _slot_data.permited;
						var _permited_mods_length = array_length(_permited_mods);
						
                        for (var j = 0; j < _permited_mods_length; j++)
						{
							// Obtener ultimo caracter al final de la llave.
                            var _mod_string = _permited_mods[j];
			                var _mod_len = string_length(_mod_string);
			                var _prefix = string_char_at(_mod_string, _mod_len);
                            var _key = string_delete(_mod_string, _mod_len, 1);
							
                            if (_prefix == "+")
							{ 
								SlotPermitedAdd(_slot_key, _key); 
							} 
							else if (_prefix == "-") 
							{ 
								SlotPermitedRemove(_slot_key, _key); 
							}
                        }
                    }
					
					// Configurar equipo inicial por instancia
                    if (variable_struct_exists(_slot_data, "equip") )
					{
                        var _to_equip = _slot_data.equip;
                        if (is_array(_to_equip) ) 
						{
							var j=0; repeat( array_length(_to_equip) ) SlotEquip( _slot_key, _to_equip[j++] );
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
		var _all_state_length = array_length(_all_state_keys);
		
        for (var i = 0; i < _all_state_length; i++) 
		{
            var _state_key = _all_state_keys[i];
			var _state_inst = new EntityStateInstance( mall_get_state(_state_key), self );
			
            states[$ _state_key] = _state_inst;
			
			// Ejecutar evento de inicio.
			if (is_callable(_state_inst.event_on_start) ) _state_inst.event_on_start(_state_inst);
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
        for (var i = 0; i < array_length(_stat_keys); i++)
		{
            var _stat_inst = stats[$ _stat_keys[i]];
            _stat_inst.Recalculate(self);
        }
	}
	
	/// @desc (Privado) Aplica los modificadores pasivos de los estados y efectos.
	/// @ignore
	static __ApplyStateModifiers = function()
	{
		var _stat_keys = variable_struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys)
		
        for (var i = 0; i < _stat_keys_length; i++) 
		{
            var _stat_inst = stats[$ _stat_keys[i]];
            _stat_inst.control_value = _stat_inst.equipment_value;
        }
        
        var _state_keys = variable_struct_get_names(states);
        var _state_keys_length = array_length(_state_keys);
		
		for (var i = 0; i < _state_keys_length; i++) 
		{
            var _state_inst = states[$ _state_keys[i]];
            if (!_state_inst.boolean_value) continue;

            // Aplicar modificadores de la plantilla del ESTADO
            var _state_modifiers =			_state_inst.stats;
            var _state_mod_keys =			variable_struct_get_names(_state_modifiers);
            var _state_mod_keys_length =	array_length(_state_mod_keys);
			
			for (var j = 0; j < _state_mod_keys_length; j++) 
			{
                var _stat_key =  _state_mod_keys[j];
                var _mod_array = _state_modifiers[$ _stat_key];
				
				if (!struct_exists(stats, _stat_key) ) continue;
				
                var _stat_to_mod = stats[$ _stat_key];
                var _mod_value = _mod_array[0];
                var _mod_type = _mod_array[1];
                            
                if (_mod_type == MALL_NUMTYPE.PERCENT) 
				{
                    _stat_to_mod.control_value += (_stat_to_mod.equipment_value * _mod_value) / 100;
                } 
				else 
				{
                    _stat_to_mod.control_value += _mod_value;
                }
            }

            // Aplicar modificadores PASIVOS de los EFECTOS dentro del estado
			var _effects_length = array_length(_state_inst.effects);
            for (var eff_idx = 0; eff_idx < _effects_length; eff_idx++) 
			{
                var _effect_inst = _state_inst.effects[eff_idx];
                var _effect_modifiers = _effect_inst.stats;
                var _effect_mod_keys = variable_struct_get_names(_effect_modifiers);
                var _effect_mod_keys_length = array_length(_effect_mod_keys);
				
                for (var j = 0; j < _effect_mod_keys_length; j++) 
				{
                    var _stat_key = _effect_mod_keys[j];
                    var _mod_array = _effect_modifiers[$ _stat_key];
                    
					if (_mod_array[2] == false && !struct_exists(stat, _stat_key) ) continue;
					
                    // Solo procesar si es un modificador pasivo ([valor, numtype, true])
                    var _stat_to_mod = stats[$ _stat_key];
                    var _mod_value = _mod_array[0];
                    var _mod_type = _mod_array[1];
                            
                    if (_mod_type == MALL_NUMTYPE.PERCENT) 
					{
                        _stat_to_mod.control_value += (_stat_to_mod.equipment_value * _mod_value) / 100;
                    } 
					else 
					{
                        _stat_to_mod.control_value += _mod_value;
                    }
                }
            }
        }
	}

	/// @desc (Privado) Aplica los modificadores del equipo.
	/// @ignore
	static __ApplyEquipmentModifiers = function()
	{
		var _stat_keys = variable_struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys);
		
        for (var i = 0; i < _stat_keys_length; i++) 
		{
            var _stat_inst = stats[$ _stat_keys[i] ];
            _stat_inst.equipment_value = _stat_inst.peak_value;
        }
        
        var _slot_keys = variable_struct_get_names(slots);
		var _slot_keys_length = array_length(_slot_keys);
		
        for (var i = 0; i < _slot_keys_length; i++) 
		{
            var _slot_inst = slots[$ _slot_keys[i]];
			if (!_slot_inst.is_active) continue;
			
			var _equipped_items_length = array_length(_slot_inst.equipped_items);
            for (var k = 0; k < _equipped_items_length; k++) 
			{
                var _item = pocket_item_get(_slot_inst.equipped_items[k]);
                if (is_undefined(_item) || !variable_struct_exists(_item, "stats") ) continue;
                    
                var _item_stat_keys = variable_struct_get_names(_item.stats);
				var _item_stat_keys_length = array_length(_item_stat_keys);
					
                for (var j = 0; j < _item_stat_keys_length; j++) 
				{
                    var _item_stat_key = _item_stat_keys[j];
					if (!struct_exists(stats, _item_stat_key) ) continue;

					var _stat_to_mod = stats[$ _item_stat_key];
					var _mod_array = _item.stats[$ _item_stat_key];
					var _mod_value = _mod_array[0];
					var _mod_type = _mod_array[1];
							
					if (_mod_type == MALL_NUMTYPE.PERCENT)
					{
						_stat_to_mod.equipment_value += (_stat_to_mod.peak_value * _mod_value) / 100;
					} 
					else 
					{
						_stat_to_mod.equipment_value += _mod_value;
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
		var _stat_keys_length = array_length(_stat_keys);
		
        for (var i = 0; i < _stat_keys_length; i++) 
		{
            var _stat_inst = stats[$ _stat_keys[i]];
			// Actualizar todos los valores.
            _stat_inst.last_peak_value =	_stat_inst.peak_value;
            _stat_inst.last_current_value = _stat_inst.current_value;
            _stat_inst.control_value =		__MALL_STAT_ROUND(clamp(_stat_inst.control_value, _stat_inst.template.min_value, _stat_inst.template.max_value));
            _stat_inst.current_value =		min(_stat_inst.current_value, _stat_inst.control_value);
        }
	}
	
	/// @desc (Privado) Despacha un evento a todas las instancias de stats.
	/// @ignore
	static __DispatchStatEvent = function(_event_name, _arg1 = undefined, _arg2 = undefined)
	{
		var _keys = variable_struct_get_names(stats);
		var _keys_length = array_length(_keys);
		
		for (var i = 0; i < _keys_length; i++)
		{
			var _stat_inst = stats[$ _keys[i]];
			var _event_func = _stat_inst[$ _event_name];
			if (is_callable(_event_func) ) 
			{
				_event_func(_stat_inst, _arg1, _arg2);
			}
		}
	}
	
	/// @desc (Privado) Despacha un evento a todas las instancias de slots.
	/// @ignore
	static __DispatchSlotEvent = function(_event_name, _arg1 = undefined, _arg2 = undefined)
	{
		var _keys = variable_struct_get_names(slots);
		var _keys_length = array_length(_keys);
		
		for (var i = 0; i < _keys_length; i++)
		{
			var _slot_inst = slots[$ _keys[i]];
			var _event_func = _slot_inst[$ _event_name];
			if (is_callable(_event_func) ) 
			{
				_event_func(_slot_inst, _arg1, _arg2);
			}
		}
	}
	
	/// @desc (Privado) Despacha un evento a todas las instancias de estados.
	/// @ignore
	static __DispatchStateEvent = function(_event_name, _arg1 = undefined, _arg2 = undefined)
	{
		var _keys = variable_struct_get_names(states);
		var _keys_length = array_length(_keys);
		
		for (var i = 0; i < _keys_length; i++)
		{
			var _state_inst = states[$ _keys[i]];
			var _event_func = _state_inst[$ _event_name];
			if (is_callable(_event_func)) 
			{
				_event_func(_state_inst, _arg1, _arg2);
			}
		}
	}
	
	/// @desc (Privado) Despacha un evento a todos los objetos equipados.
	/// @ignore
	static __DispatchEquippedItemEvent = function(_event_name, _arg1 = undefined, _arg2 = undefined)
	{
		static __function = function(_slot_inst, _slot_key)
		{
			var _equipped_items = _slot_inst.equipped_items;
			var _equipped_items_length = array_length(_equipped_items) 
			
			for (var i = 0; i < _equipped_items_length; i++) 
			{
				var _item_key = _equipped_items[i];
				var _item_template = pocket_item_get(_item_key);
				
				if (!is_undefined(_item_template) ) 
				{
					var _event_func = _item_template[$ event_name];
					if (is_callable(_event_func) ) 
					{
						_event_func(self, arg1, arg2);
					}
				}
			}
		}
		
		var _this = self;
		SlotForeach(method( { this: _this, event_name: _event_name, arg1: _arg1, arg2: _arg2 }, __function) ); 
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
		exp_value =			_template[$ "exp_value"]		?? exp_value;
		loot_table_key =	_template[$ "loot_table_key"]	?? loot_table_key;
		faction =			_template[$ "faction"]			?? faction;
		learnset =			_template[$ "learnset"]			?? learnset;
		flags =				_template[$ "flags"]			?? flags;
		
		// Recalcular stats después de que todo esté cargado y equipado.
        RecalculateStats();

		// Inicializar los valores actuales al máximo después del primer cálculo.
		var _stat_keys = variable_struct_get_names(stats);
		var _stat_keys_length = array_length(_stat_keys);
		
		for (var i = 0; i < _stat_keys_length; i++) 
		{
			var _stat_inst = stats[$ _stat_keys[i]];
			_stat_inst.current_value = _stat_inst.control_value;
		}
		
        return self;
    }
	
    /// @desc Recalcula todas las estadísticas (usado al subir de nivel o al equipar/desequipar).
    static RecalculateStats = function()
    {
		__CalculatePeakValues();
		__ApplyEquipmentModifiers();
		__ApplyStateModifiers();
		__FinalizeStatValues();
		
		// Notificar a todos los componentes que las estadísticas se han actualizado
		__DispatchStatEvent("event_on_update");
		__DispatchSlotEvent("event_on_update");
		__DispatchStateEvent("event_on_update");
		__DispatchEquippedItemEvent("event_on_update", self);
    }
	
    /// @desc Sube de nivel a la entidad y recalcula sus estadísticas.
	/// @param {Real} [levels_to_add]=1 El número de niveles a subir.
    static LevelUp = function(_levels_to_add = 1)
    {
        if (!event_on_level_check(_levels_to_add) ) exit; 
		
		var _old_level = level;
        level = clamp(level + _levels_to_add, __MALL_PARTY_LEVEL_MIN, __MALL_PARTY_LEVEL_MAX);
        
		// Comprobar si se han aprendido nuevos comandos
		var i=0; repeat(array_length(learnset) )
		{
			var _learn_data = learnset[i];
			// Si el nivel requerido está entre el nivel antiguo y el nuevo
			if (_learn_data.level > _old_level && _learn_data.level <= level) 
			{
				CommandAdd(_learn_data.category, _learn_data.command);
			}
			
			i++;	
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
        if (is_undefined(_stat) ) return 0;
		
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
    static SlotEquip = function(_slot_key, _item_key)
    {
        var _slot_inst = SlotGet(_slot_key);
        if (is_undefined(_slot_inst) ) return { success: false, previously_equipped: undefined };
        
        var _result = _slot_inst.Equip(_item_key);
        if (_result.success)
		{ 
			RecalculateStats();
			
			// Lanzar eventos de notificación a todos los componentes
			__DispatchStatEvent("event_on_equip", _slot_inst);
			__DispatchStateEvent("event_on_equip", _slot_inst);
			event_on_equip(_slot_inst, _result);
		}
		
		return _result;
    }
	
	/// @desc Desequipa un objeto de un slot.
	/// @param {String} slot_key La llave del slot.
	/// @param {String} item_key La llave del objeto a desequipar.
    static SlotDesequip = function(_slot_key, _item_key)
    {
        var _slot_inst = SlotGet(_slot_key);
        if (is_undefined(_slot_inst)) return { success: false, unequipped_item: undefined };

        var _result = _slot_inst.Desequip(_item_key);
        if (_result.success) 
		{ 
			RecalculateStats();
			
			// Lanzar eventos de notificación a todos los componentes
			__DispatchStatEvent("event_on_desequip", _slot_inst);
			__DispatchStateEvent("event_on_desequip", _slot_inst);
			event_on_desequip(_slot_inst, _result);
		}
		
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
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];
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
		var _result = { added: undefined, success: false, leftover: undefined }
		// Obtener efecto y si no existe salir.
		var _effect_template = mall_get_dark(_effect_key);
		if (is_undefined(_effect_template) ) return _result;
		
		// Obtener instancia de estado y si no existe salir.
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst) ) return _result;
		
		// Crear instancia de efecto y comprobar si se puede añadir.
		var _effect_instance = new DarkEffectInstance(_effect_template);
		// Comprobar si se puede añadir.
		if (is_callable(_state_inst.event_can_add_effect) && !(_state_inst.event_can_add_effect(_state_inst, _effect_instance) ) ) 
		{
			// Añadir instancia de efecto no agregada al resultado.
			_result.leftover = _effect_instance;
			return _result;
		}
		
		// Obtener template de estado.
		var _state_template = _state_inst.template;
		
		// Comprobar inmunidades y prioridades
		var _state_keys = variable_struct_get_names(states);
		var _state_keys_length = array_length(_state_keys);
		
		for (var i = 0; i < _state_keys_length; i++)
		{
			var _k = _state_keys[i];
			var _current_state_inst = states[$ _k];
			if (!_current_state_inst.boolean_value) continue;
			
			// Si el estado que se esta analizando previene el estado que se intenta añadir.
			if (array_contains(_current_state_inst.template.prevents_states, _state_key) ) return _result;
			
			// Comprobar prioridades.
			if (_current_state_inst.template.restricts_action && _state_template.priority < _current_state_inst.template.priority) return _result;
		}
		
		// Limpiar otros estados
		var _states_to_clear = _state_template.clears_states;
		var i=0; repeat(array_length(_states_to_clear) ) { StateRemoveAllEffects( _states_to_clear[i++] ); }
		
		// Crear y añadir la instancia del efecto
		array_push(_state_inst.effects, _effect_instance);
		
		// Si esta en un estado inicial
		if (_state_inst.boolean_value == _state_inst.reset_value) 
		{
			_state_inst.boolean_value = !_state_inst.reset_value;
			
			// Evento al cambiar de estado booleano.
			if (is_callable(_state_inst.event_on_start) ) _state_inst.event_on_start(_state_inst, _effect_instance);
		}
	
		// Ejecutar eventos.
		_state_inst.event_on_add_effect(_state_inst, _effect_instance);
		_effect_instance.event_on_start(self, _state_inst);
		
		// Recalcular estadisticas.
		RecalculateStats();
		
		// Cambiar resultado.
		_result.added = _effect_instance;
		_result.success = true;
		
		return _result;
	}
	
	/// @desc Elimina una instancia de efecto de un estado.
	/// @param {String} effect_key La llave de la plantilla del efecto a añadir.
	/// @param {Function} [filter] Una función opcional para encontrar un efecto específico. (_value, _index) context (template: EffectTemplate).
	static EffectRemove = function(_effect_key, _filter)
	{
		static __default_filter = function(_value, _index) {
			return (_value.template.key == template.key);
		}
		
		var _result = { removed: undefined, success: false }
		
		// Obtener efecto y si no existe salir.
		var _effect_template = mall_get_dark(_effect_key);
		if (is_undefined(_effect_template) ) return _result;
		
		var _state_key = _effect_template.state_key;
		var _state_inst = StateGet(_state_key);
		if (is_undefined(_state_inst) ) return _result;

		// Buscarlo por key y eliminarlo. Se buscará al primero que entregue true.
		var _index = array_find_index(_state_inst.effects, method( {template: _effect_template} , _filter ?? __default_filter) );
		var _effect_removed = undefined;
		
		if (_index > -1) _effect_removed = _state_inst.effects[_index];
		
		// Si no existe entonces devolver resultado.
		if (is_undefined(_effect_removed) ) return _result;
		
		// Validar si el efecto se puede eliminar
		var _can_remove_effect = _state_inst.event_can_remove_effect;
		if (is_callable(_can_remove_effect) && !_can_remove_effect(_state_inst, _effect_removed) ) 
		{
			return _result;
		}
		
		// Elimnar del array de efectos de la instacia de estados.
		array_delete(_state_inst.effects, _index, 1);
			
		// Ejecutar eventos de notificación
		_state_inst.event_on_remove_effect(_state_inst, _effect_removed);
		_effect_removed.event_on_end(self, _state_inst);
		
		// Si ya no quedan efectos, desactivar el estado
		if (array_length(_state_inst.effects) == 0)
		{
			_state_inst.boolean_value = _state_inst.reset_value;
			_state_inst.event_on_end(_state_inst);
		}
		
		// Calcular todas las estadisticas.
		if (!__is_updating_all_states) RecalculateStats();
			
		// Guardar resultados.
		_result.removed = _effect_removed;
		_result.success = true;

		return _result;
	}
	
	/// @desc Elimina todos los efectos de un estado específico.
	/// @param {String} key La llave del estado a limpiar.
	/// @param {Function} [filter] Una función opcional para encontrar un efecto específico. (_value, _index) context (template: EffectTemplate).	
	static StateRemoveAllEffects = function(_key, _filter)
	{
		var _results = { };
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst.boolean_value) return _results;
				
		// Disparar evento de finalización para cada efecto
		var _state_effects = _state_inst.effects;
		var _state_effects_length = array_length(_state_effects);
		
		// Flag para optimizar cada bucle.
		__is_updating_all_states = true;
		
		for (var i = array_length(_state_inst.effects) - 1; i >= 0; i--)
		{
			var _effect_inst =	_state_inst.effects[i];
			var _effect_key =	_effect_inst.template.key;
			
			struct_set(_results, _effect_key+i, EffectRemove(_effect_key, _filter) );
		}
		
		__is_updating_all_states = false;
		
		// Recalcular todas las estadisticas.
		RecalculateStats();
		
		return _results;
	}

	/// @desc Actualiza los efectos de un estado específico según el momento del turno.
	/// @param {String} key La llave del estado a actualizar.
	/// @param {Enum.MALL_EFFECT_TURN} turn_type El momento del turno (START o END).
	static EffectsUpdateByTurn = function(_key, _turn_type)
	{
		var _state_inst = StateGet(_key);
		if (is_undefined(_state_inst) || !_state_inst.boolean_value) return;

		// Flag para no recalcular los stats (optimizacion)
		__is_updating_all_states = true;
		
		// Iterar hacia atrás para poder eliminar efectos de forma segura
		for (var i = array_length(_state_inst.effects) - 1; i >= 0; i--) 
		{
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
					// Procesar efectos activos (que modifican current_value)
					var _effect_modifiers = _template.stats;
					var _effect_mod_keys = variable_struct_get_names(_effect_modifiers);
					var _effect_mod_keys_length = array_length(_effect_mod_keys);
					
					for (var j = 0; j < _effect_mod_keys_length; j++) 
					{
						var _stat_key = _effect_mod_keys[j];
						var _mod_array = _effect_modifiers[$ _stat_key];
						
						// Solo procesar si es un modificador activo ([valor, numtype, false])
						if (_mod_array[2] == true) continue;
						
						var _base_value = _mod_array[0];
						var _base_type = _mod_array[1];
						var _value_to_apply;
						var _type_to_apply = _base_type;
							
						// Comprobar si hay un evento de cálculo
						if (is_callable(_effect_inst.event_on_calculate) ) 
						{
							_value_to_apply = _effect_inst.event_on_calculate(self, _effect_inst, _base_value, _base_type);
							// El evento devuelve un valor ya calculado.
							_type_to_apply = MALL_NUMTYPE.REAL;
						} 
						else 
						{
							_value_to_apply = _base_value;
						}
							
						StatAdd(_stat_key, _value_to_apply, _type_to_apply);
					}
					
					// Llamar evento.
					var _event = (_turn_type == MALL_EFFECT_TURN.START) ? _effect_inst.event_on_turn_start : _effect_inst.event_on_turn_end;
					if (is_callable(_event) ) _event(self, _effect_inst);
					
					break;
				
				case MALL_ITERATOR_STATE.COMPLETED:
					// Establecer variable en el effecto indicando que debe ser eliminada.
					with (_effect_inst) __to_remove = true;
				
					// El efecto ha terminado, eliminarlo
					EffectRemove(_state_inst, function(_value, _index) {
						if (struct_exists(_value, "__to_remove") && _value.template.key == key)
						{
							return true;
						}
					});
					
					break;
			}
		}
		
		// Recalcular
		__is_updating_all_states = false;
		
		// Recalcular stats solo si no estamos en un bucle de actualización masiva
		if (!__is_updating_all_states) RecalculateStats();
	}

	
	/// @desc Actualiza todos los estados de la entidad según el momento del turno.
	/// @param {Enum.MALL_EFFECT_TURN} turn_type El momento del turno (START o END).
	static StateUpdateAll = function(_turn_type)
	{
		// Flag para optimizar.
		__is_updating_all_states = true;
		
		var _keys = variable_struct_get_names(states);
		var _keys_length = array_length(_keys);
		
		for (var i = 0; i < _keys_length; i++)
		{
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
			exps: exp_value,
			items: []
		};
		
		var _all_drops = [];
		array_copy(_all_drops, 0, bonus_drops, 0, array_length(bonus_drops) );
		
		// Obtener drops de la tabla de botín
		var _loot_table = mall_get_loottable(loot_table_key);
		if (!is_undefined(_loot_table) && variable_struct_exists(_loot_table, "items") ) 
		{
			var _table_items = _loot_table.items;
			array_copy(_all_drops, array_length(_all_drops), _table_items, 0, array_length(_table_items));
		}
		
		// Calcular Drops de Items
		for (var i = 0; i < array_length(_all_drops); i++) 
		{
			var _drop_data = _all_drops[i];
			var _chance = _drop_data.chance ?? 100;
			
			if (random(100) < _chance)
			{
				var _quantity = 0;
				var _quantity_data = _drop_data.quantity ?? 1;
				
				if (is_array(_quantity_data) ) 
				{
					_quantity = irandom_range(_quantity_data[0], _quantity_data[1]);
				} 
				else 
				{
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
		array_push(bonus_drops, {
			key: _key,
			quantity: _quantity,
			chance: _chance
		});
		
		return self;
	}
	
	/// @desc Se ejecuta al inicio del turno de la entidad en combate.
	static OnTurnStart = function()
	{
		// Actualiza todos los estados y efectos que se activan al inicio del turno.
		StateUpdateAll(MALL_EFFECT_TURN.START);
		
		// Notificar a todos los componentes
		__DispatchStatEvent("event_on_turn_start");
		__DispatchSlotEvent("event_on_turn_start");
		__DispatchEquippedItemEvent("event_on_turn_start", self);
	}

	/// @desc Se ejecuta al final del turno de la entidad en combate.
	static OnTurnEnd = function()
	{
		// Actualiza todos los estados y efectos que se activan al final del turno.
		StateUpdateAll(MALL_EFFECT_TURN.END);
		
		// Notificar a todos los componentes
		__DispatchStatEvent("event_on_turn_end");
		__DispatchSlotEvent("event_on_turn_end");
		__DispatchEquippedItemEvent("event_on_turn_end", self);		
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
function party_entity_create_instance(_template_key, _level=1, _args = {})
{
    if (!party_exists_entity_template(_template_key) )
    {
        show_error($"[Systemall] Intento de crear una instancia de una plantilla no existente: '{_template_key}'", true);
        return undefined;
    }
    
    // Crear un ID único para la instancia (esto es una simplificación, se podría usar un contador global)
    var _instance_id = $"{_template_key}_{get_timer()}"; 
    
    var _entity = new PartyEntity(_template_key, _instance_id);
	_entity.args = _args;
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