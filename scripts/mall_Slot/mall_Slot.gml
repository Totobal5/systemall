/// @desc Define un "espacio" en una entidad donde se pueden equipar objetos.
/// @param {String} key
function MallSlot(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Slot ---
    max_items = 1;          // Cuántos objetos se pueden equipar en este slot.
    is_disabled = false;    // Si el slot está desactivado por defecto.
    is_damaged = false;     // Si el slot está dañado (puede tener efectos negativos).
    depends_on_slot = "";   // La llave de otro slot del que depende para estar activo.
    permited = {};			// Lista de objetos permitidos. Si esta vacio se considera que acepta todos.
	
    // --- Llaves de Eventos ---
    event_on_start = "";
    event_on_end = "";
    event_on_update = "";
    
    // Eventos de Turno
    event_on_turn_update = "";
    event_on_turn_start = "";
    event_on_turn_end = "";
    
    // Eventos de Equipamiento
    event_on_equip = "";
    event_on_desequip = "";

	// Evento para comprobar el objeto que se le va a equipar.
	/// @param entity
	/// @param item	
	event_can_equip = ""
	
	// Evento para comprobar si el objeto se puede desequipar.
	/// @param entity
	/// @param item
	event_can_desequip = "";
	
	// Evento al atacar
    event_on_attack = "";
	// Evento al ser atacado.
    event_on_defend = "";

    /// @desc (Privado) Método auxiliar para poblar la lista de objetos permitidos.
    /// @param {String, Array} data La llave o array de llaves a añadir.
    /// @ignore
    static __PopulatePermited = function(_data)
    {
        if (is_array(_data))
        {
            // Si es un array, procesar cada entrada recursivamente.
            for (var i = 0; i < array_length(_data); i++)
            {
                __PopulatePermited(_data[i]);
            }
        }
        else if (is_string(_data))
        {
            // Si es un string, comprobar si es un tipo de objeto.
            if (mall_exists_type(_data))
            {
                var _type_items = mall_get_type(_data);
                for (var j = 0; j < array_length(_type_items); j++)
                {
                    permited[$ _type_items[j]] = 0;
                }
            }
            else
            {
                // Si no, es la llave de un único objeto.
                permited[$ _data] = 0;
            }
        }
    }

	static __LoadFunctions = function(_data)
	{
        // Asignar llaves de eventos
	    event_on_start =	_data[$ "event_on_start"]	?? "";
	    event_on_end =		_data[$ "event_on_end"]		?? "";
	    event_on_update =	_data[$ "event_on_update"]	?? "";
    
	    // Eventos de Turno
	    event_on_turn_update =	_data[$ "event_on_turn_update"] ?? "";
	    event_on_turn_start =	_data[$ "event_on_turn_start"]	?? "";
	    event_on_turn_end =		_data[$ "event_on_turn_end"]	?? "";
    
	    // Eventos de Equipamiento
	    event_on_equip =	_data[$ "event_on_equip"]		?? "";
	    event_on_desequip =	_data[$ "event_on_desequip"]	?? "";

		// Evento para comprobar el objeto que se le va a equipar.
		event_can_equip =		_data[$ "event_on_item_check"]	?? "";
		event_can_desequip =	_data[$ "event_can_desequip"]	?? "";
		
		// Evento al atacar
	    event_on_attack =		_data[$ "event_on_attack"]		?? "";
		// Evento al ser atacado.
	    event_on_defend =		_data[$ "event_on_defend"]		?? "";
	}

    /// @desc Configura el slot a partir de un struct de datos.
    /// @param {Struct} data El struct con los datos del slot.
    static FromData = function(_data)
    {
        max_items =			_data[$ "max_items"]		?? 1;
        is_disabled =		_data[$ "is_disabled"]		?? false;
        is_damaged =		_data[$ "is_damaged"]		?? false;
        depends_on_slot =	_data[$ "depends_on_slot"]	?? "";
        
		// Estos son globales luego cada entidad puede variarlos.
		// Procesar la lista de objetos permitidos usando el método auxiliar.
		if (variable_struct_exists(_data, "permited") )
		{
			__PopulatePermited(_data.permited);
		}
		
		// Cargar funciones.
		__LoadFunctions(_data);
		
        return self;
    }
}

/// @desc Crea una plantilla de slot desde data y la añade a la base de datos.
/// @param {String} key
function mall_create_slot_from_data(_key, _data)
{
    if (mall_exists_slot(_key))
    {
        show_debug_message($"[Systemall] Advertencia: El slot '{_key}' ya existe. Se omitirá la duplicada.");
        return;
	}	

    var _slot = (new MallSlot(_key)).FromData(_data);
	
    Systemall.__slots[$ _key] = _slot;
    array_push(Systemall.__slots_keys, _key);
}

/// @desc Crea un slot en tiempo de ejecución.
/// @param {String} key
function mall_create_slot(_key, _component)
{
    if (mall_exists_slot(_key))
    {
        show_debug_message($"[Systemall] Advertencia: El slot '{_key}' ya existe. Se omitirá la duplicada.");
        return;
	}
	
    Systemall.__slots[$ _key] = _component;
    array_push(Systemall.__slots_keys, _key);
}

/// @desc Devuelve la plantilla de un slot.
/// @param {String} key
function mall_get_slot(_key) 
{
	return Systemall.__slots[$ _key]; 
}

/// @desc Comprueba si un slot existe.
/// @param {String} key
function mall_exists_slot(_key) 
{
	return struct_exists(Systemall.__slots, _key); 
}

/// @desc Devuelve las llaves de todos los slots.
/// @return {Array<String>}
function mall_get_slot_keys() 
{
	return Systemall.__slots_keys; 
}