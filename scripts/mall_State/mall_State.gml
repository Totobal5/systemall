/// @desc Define la plantilla base para un "estado" alterado (ej: veneno, bendecido).
/// @param {String} key
function MallState(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del State ---
	
    /// @desc La categoría del estado (ej: "BUFF", "AILMENT").
	/// @type {String}
	state_type = "AILMENT";
	
    /// @desc La prioridad para resolver conflictos con otros estados.
	/// @type {Real}
	priority = 0;
	
    /// @desc Una lista de llaves de otros estados que este estado elimina al ser aplicado.
	/// @type {Array<String>}
	clears_states = [];
	
    /// @desc Una lista de llaves de estados que no se pueden aplicar mientras este esté activo.
	/// @type {Array<String>}
	prevents_states = [];
	
    /// @desc Si es true, la entidad no puede ejecutar comandos mientras el estado esté activo.
	/// @type {Bool}
	restricts_action = false;
	
    /// @desc El valor booleano inicial de este estado.
	/// @type {Bool}
	boolean_value = false;
	
    /// @desc El valor al que se reinicia el estado booleano.
	/// @type {Bool}
	reset_value = false;
	
    /// @desc Si la entidad puede tener múltiples efectos de este estado a la vez.
	/// @type {Bool}
    allow_multiple = false;
	
    /// @desc Cuántas veces se puede apilar un efecto si allow_multiple es true.
	/// @type {Real}
    max_effects = 1;
	
    /// @desc Un struct con los modificadores de estadísticas pasivos que aplica este estado.
	/// @type {Struct}
	stats = {};
	
    /// @desc El iterador que controla la duración del estado.
	/// @type {Struct.MallIterator}
    iterator = new MallIterator();

    // --- Llaves de Eventos ---
	
	/// @desc Se ejecuta una vez cuando la instancia del estado es creada para una entidad.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_start = "";
	
	/// @desc (Sin implementación actual en el motor)
    event_on_end = "";
	
	/// @desc Se ejecuta en cada llamada a RecalculateStats.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_update = "";
	
	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_update = "";
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_start = "";
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_end = "";
	
	/// @desc Se ejecuta después de que un efecto es añadido a este estado.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.DarkEffectInstance} effect_instance El efecto que fue añadido.
	event_on_add_effect = "";
	
	/// @desc Se ejecuta después de que un efecto es eliminado de este estado.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.DarkEffectInstance} effect_instance El efecto que fue eliminado.
	event_on_remove_effect = "";

	/// @desc Valida si un efecto puede ser añadido a este estado. Debe devolver bool.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.DarkEffect} effect_template La plantilla del efecto a añadir.
	event_can_add_effect = "";
	
	/// @desc Valida si un efecto puede ser eliminado de este estado. Debe devolver bool.
	/// @context EntityStateInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.DarkEffectInstance} effect_instance El efecto a eliminar.
	event_can_remove_effect = "";
	
	#region PRIVATE
	
    /// @desc (Privado) Carga las llaves de los eventos desde el struct de datos.
    /// @ignore
	static __LoadFunctions = function(_data)
	{
        // Asignar llaves de eventos
		event_on_start =		_data[$ "event_on_start"]		?? "";
		event_on_end =			_data[$ "event_on_end"]			?? "";
		event_on_update =		_data[$ "event_on_update"]		?? "";
	    event_on_turn_update =	_data[$ "event_on_turn_update"]	?? "";
	    event_on_turn_start =	_data[$ "event_on_turn_start"]	?? "";
	    event_on_turn_end =		_data[$ "event_on_turn_end"]	?? "";
	    event_on_add_effect =		_data[$ "event_on_add_effect"]		?? "";
	    event_on_remove_effect =	_data[$ "event_on_remove_effect"]	?? "";
		event_can_add_effect =		_data[$ "event_can_add_effect"]		?? "";
		event_can_remove_effect =	_data[$ "event_can_remove_effect"]	?? "";
	}
	
	#endregion
	
	#region API
	
    /// @desc Configura el estado a partir de un struct de datos.
    /// @param {Struct} data El struct con los datos del estado.
    static FromData = function(_data)
    {
		// Cargar nuevas propiedades
		state_type =		string_upper(_data.state_type ?? "AILMENT");
		priority =			_data.priority ?? 0;
		clears_states =		_data.clears_states ?? [];
		prevents_states =	_data.prevents_states ?? [];
		restricts_action =	_data.restricts_action ?? false;
		
		// Cargar propiedades existentes
        boolean_value =		_data.boolean_value ?? false;
        reset_value =		_data.reset_value ?? false;
        allow_multiple =	_data.allow_multiple ?? false;
        max_effects =		_data.max_effects ?? 1;
        
        if (struct_exists(_data, "stats") ) { stats = variable_clone(_data.stats); }
        
        if (struct_exists(_data, "iterator") )
        {
            iterator.Configure(
                _data.iterator[$ "duration"] ?? 1,
                _data.iterator[$ "repeats"] ?? 0
            );
        }
		
		// Cargar eventos.
        __LoadFunctions(_data);
		
        return self;
    }	

	#endregion
}

/// @desc Crea una plantilla de state desde data y la añade a la base de datos.
/// @param {String} key La llave del estado (ej: "STATE_VENENO").
/// @param {Struct} data El struct de datos leído del JSON.
function mall_state_create_from_data(_key, _data)
{
    if (mall_exists_state(_key) ) 
	{
		return __mall_print($"Advertencia: El state '{_key}' ya existe. Se omitirá el duplicada.");
	}
	
    var _state = (new MallState(_key) ).FromData(_data);
	
    Systemall.__states[$ _key] = _state;
    array_push(Systemall.__states_keys, _key);
	
	// Registrar el estado en su categoría de tipo.
	mall_create_type(_state.state_type, _key);
}

/// @desc Crea un state en tiempo de ejecución.
/// @param {String} key La llave del estado (ej: "STATE_VENENO").
/// @param {Struct.MallState} component La instancia del constructor del estado.
function mall_create_state(_key, _component)
{
    if (mall_exists_state(_key) )
	{
		return __mall_print($"Advertencia: El state '{_key}' ya existe. Se omitirá el duplicada.");
	}
	
    Systemall.__states[$ _key] = _component;
    array_push(Systemall.__states_keys, _key);
	
	// Registrar el estado en su categoría de tipo
	mall_create_type(_component.state_type, _key);
}

/// @desc Devuelve la plantilla de un state.
/// @param {String} key La llave del estado.
/// @return {Struct.MallState}
function mall_get_state(_key) 
{ 
	return Systemall.__states[$ _key]; 
}

/// @desc Comprueba si un state existe en la base de datos.
/// @param {String} key La llave del estado.
/// @return {Bool}
function mall_exists_state(_key) 
{
	return struct_exists(Systemall.__states, _key); 
}

/// @desc Devuelve un array con las llaves de todos los states creados.
/// @return {Array<String>}
function mall_get_state_keys() 
{
	return Systemall.__states_keys; 
}