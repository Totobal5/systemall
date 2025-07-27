/// @desc Define un "estado" alterado para una entidad (ej: veneno, bendecido).
/// @param {String} key
function MallState(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del State ---
    allow_multiple = false; // Si la entidad puede tener este estado varias veces.
    max_effects = 1;        // Cuántas veces se puede apilar si allow_multiple es true.
    
    // Iterador para manejar la duración del estado.
    iterator = new MallIterator();
    
    /// @desc Configura el estado a partir de un struct de datos.
    /// @param {Struct} data El struct con los datos del estado.
    static FromData = function(_data)
    {
        allow_multiple = _data.allow_multiple ?? false;
        max_effects = _data.max_effects ?? 1;
        
        if (variable_struct_exists(_data, "iterator"))
        {
            iterator.Configure(
                _data.iterator.duration ?? 1,
                _data.iterator.repeats ?? 0
            );
        }
        
        // Asignar llaves de eventos
        event_on_start = _data.event_on_start ?? "";
        event_on_end = _data.event_on_end ?? "";
        event_on_turn_start = _data.event_on_turn_start ?? "";
        event_on_turn_end = _data.event_on_turn_end ?? "";
        
        return self;
    }
}

/// @desc Crea una plantilla de state desde data y la añade a la base de datos.
/// @param {String} key
function mall_state_create_from_data(_key, _data)
{
    if (mall_exists_state(_key))
    {
        show_debug_message($"[Systemall] Advertencia: El state '{_key}' ya existe. Se omitirá la duplicada.");
        return;
	}
	
    var _state = (new MallState(_key)).FromData(_data);
    Systemall.__states[$ _key] = _state;
    array_push(Systemall.__states_keys, _key);
}

/// @desc Crea un state en tiempo de ejecución.
/// @param {String} key
function mall_create_state(_key, _component)
{
    if (mall_exists_state(_key))
    {
        show_debug_message($"[Systemall] Advertencia: El state '{_key}' ya existe. Se omitirá la duplicada.");
        return;
	}
	
    Systemall.__states[$ _key] = _component;
    array_push(Systemall.__states_keys, _key);
}

/// @desc Devuelve la plantilla de un state.
/// @param {String} key
function mall_get_state(_key) { return Systemall.__states[$ _key]; }

/// @desc Comprueba si un state existe.
/// @param {String} key
function mall_exists_state(_key) { return struct_exists(Systemall.__states, _key); }

/// @desc Devuelve las llaves de todos los states.
/// @return {Array<String>}
function mall_get_state_keys() { return Systemall.__states_keys; }