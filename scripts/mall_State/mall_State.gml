/// @desc Define un "estado" alterado para una entidad (ej: veneno, bendecido).
/// @param {String} key
function MallState(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del State ---
	state_type = "AILMENT";			// Categoría del estado (buff, debuff, ailment).
	priority = 0;					// Prioridad para resolver conflictos con otros estados.
	clears_states = [];				// Lista de estados que este estado elimina al ser aplicado.
	prevents_states = [];			// Lista de estados que no se pueden aplicar mientras este esté activo.
	restricts_action = false;		// Si es true, la entidad no puede ejecutar comandos.
	
	boolean_value = false;			// Valor booleano inicial de este estado.
	reset_value = false;			// Valor a que reinicia este estado.
    allow_multiple = false;			// Si la entidad puede tener este estado varias veces.
    max_effects = 1;				// Cuántas veces se puede apilar si allow_multiple es true.
    
	// Estadísticas que afectará este estado.
	stats = {};
	
    // Iterador para manejar la duración del estado.
    iterator = new MallIterator();

    // --- Llaves de Eventos ---
    event_on_start = "";
    event_on_end = "";
    event_on_update = "";
    event_on_turn_update = "";
    event_on_turn_start = "";
    event_on_turn_end = "";
    event_on_equip = "";
    event_on_desequip = "";
	
    /// @desc (Privado) Carga las llaves de los eventos desde el struct de datos.
    /// @ignore
	static __LoadFunctions = function(_data)
	{
        // Asignar llaves de eventos
		event_on_start =	_data.event_on_start ?? "";
		event_on_end =		_data.event_on_end ?? "";
		event_on_update =	_data.event_on_update ?? "";
	    event_on_turn_update =	_data.event_on_turn_update ?? "";
	    event_on_turn_start =	_data.event_on_turn_start	?? "";
	    event_on_turn_end =		_data.event_on_turn_end		?? "";
	    event_on_equip =		_data.event_on_equip ?? "";
	    event_on_desequip =		_data.event_on_desequip	?? "";
	}
	
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
        
        if (variable_struct_exists(_data, "stats")) {
            stats = variable_clone(_data.stats);
        }
        
        if (variable_struct_exists(_data, "iterator"))
        {
            iterator.Configure(
                _data.iterator.duration ?? 1,
                _data.iterator.repeats ?? 0
            );
        }

        __LoadFunctions(_data);
		
        return self;
    }	
}

/// @desc Crea una plantilla de state desde data y la añade a la base de datos.
function mall_state_create_from_data(_key, _data)
{
    if (mall_exists_state(_key)) return;
    var _state = (new MallState(_key)).FromData(_data);
    Systemall.__states[$ _key] = _state;
    array_push(Systemall.__states_keys, _key);
	
	// Registrar el estado en su categoría de tipo
	mall_create_type(_state.state_type, _key);
}

/// @desc Crea un state en tiempo de ejecución.
function mall_create_state(_key, _component)
{
    if (mall_exists_state(_key)) return;
    Systemall.__states[$ _key] = _component;
    array_push(Systemall.__states_keys, _key);
	
	// Registrar el estado en su categoría de tipo
	mall_create_type(_component.state_type, _key);
}

/// @desc Devuelve la plantilla de un state.
/// @param {String} key
function mall_get_state(_key) 
{ 
	return Systemall.__states[$ _key]; 
}

/// @desc Comprueba si un state existe.
/// @param {String} key
function mall_exists_state(_key) 
{
	return struct_exists(Systemall.__states, _key); 
}

/// @desc Devuelve las llaves de todos los states.
/// @return {Array<String>}
function mall_get_state_keys() 
{
	return Systemall.__states_keys; 
}