/// @desc Define la plantilla base para un "espacio" en una entidad donde se pueden equipar objetos.
/// @param {String} key
function MallSlot(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Slot ---
	
    /// @desc Cuántos objetos se pueden equipar en este slot.
	/// @type {Real}
    max_items = 1;
	
    /// @desc Si el slot está desactivado por defecto.
	/// @type {Bool}
    is_disabled = false;
	
    /// @desc Si el slot está dañado (puede tener efectos negativos).
	/// @type {Bool}
    is_damaged = false;
	
    /// @desc La llave de otro slot del que depende para estar activo.
	/// @type {String}
    depends_on_slot = "";
	
    /// @desc Un struct con las llaves de los objetos/tipos permitidos. Si está vacío, se aceptan todos.
	/// @type {Struct}
    permited = {};
	
    // --- Llaves de Eventos ---
	
	/// @desc Se ejecuta una vez cuando la instancia del slot es creada para una entidad.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_start = "";
	
	/// @desc (Sin implementación actual en el motor)
    event_on_end = "";
	
	/// @desc Se ejecuta en cada llamada a RecalculateStats.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_update = "";
    
    // Eventos de Turno
	
	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_update = "";
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_start = "";
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_end = "";
    
    // Eventos de Equipamiento
	
	/// @desc Se ejecuta después de que un objeto ha sido equipado exitosamente en este slot.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.PocketItem} item_template El objeto que fue equipado.
    event_on_equip = "";
	
	/// @desc Se ejecuta después de que un objeto ha sido desequipado exitosamente de este slot.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.PocketItem} item_template El objeto que fue desequipado.
    event_on_desequip = "";

	/// @desc Valida si un objeto se puede equipar. Debe devolver bool.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.PocketItem} item_template El objeto a comprobar.
	event_can_equip = "";
	
	/// @desc Valida si el objeto actual se puede desequipar. Debe devolver bool.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.PocketItem} item_template El objeto a comprobar.
	event_can_desequip = "";
	
	// Evento al atacar
	
	/// @desc Se ejecuta cuando la entidad ataca.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.PartyEntity} target El objetivo del ataque.
    event_on_attack = "";
	
	/// @desc Se ejecuta cuando la entidad es atacada.
	/// @context EntitySlotInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.PartyEntity} attacker El atacante.
    event_on_defend = "";

	#region PRIVATE

    /// @desc (Privado) Método auxiliar para poblar la lista de objetos permitidos.
    /// @param {String, Array} data La llave o array de llaves a añadir.
    /// @ignore
    static __PopulatePermited = function(_data)
    {
        if (is_array(_data) )
        {
			var i=0; repeat(array_length(_data) ) { __PopulatePermited( _data[i++] ); }
        }
        else if (is_string(_data) )
        {
            if (mall_exists_type(_data) )
            {
                var _type_items = mall_get_type(_data);
				var i=0; repeat(array_length(_type_items) ) { permited[$ _type_items[i++] ] = 0; }
            }
            else
            {
                permited[$ _data] = 0;
            }
        }
    }
	
	/// @desc (Privado) Cargar string de eventos para ser usados más adelante.
	/// @param {Struct} data El struct con los datos del slot.
	/// @ignore
	static __LoadFunctions = function(_data)
	{
	    event_on_start =		_data[$ "event_on_start"]	?? "";
	    event_on_end =			_data[$ "event_on_end"]		?? "";
	    event_on_update =		_data[$ "event_on_update"]	?? "";
	    event_on_turn_update =	_data[$ "event_on_turn_update"] ?? "";
	    event_on_turn_start =	_data[$ "event_on_turn_start"]	?? "";
	    event_on_turn_end =		_data[$ "event_on_turn_end"]	?? "";
	    event_on_equip =		_data[$ "event_on_equip"]		?? "";
	    event_on_desequip =		_data[$ "event_on_desequip"]	?? "";
		event_can_equip =		_data[$ "event_on_item_check"]	?? "";
		event_can_desequip =	_data[$ "event_can_desequip"]	?? "";
	    event_on_attack =		_data[$ "event_on_attack"]		?? "";
	    event_on_defend =		_data[$ "event_on_defend"]		?? "";
	}
	
	#endregion
	
	#region API
	
    /// @desc Configura el slot a partir de un struct de datos.
    /// @param {Struct} data El struct con los datos del slot.
    static FromData = function(_data)
    {
        max_items =			_data[$ "max_items"]		?? 1;
        is_disabled =		_data[$ "is_disabled"]		?? false;
        is_damaged =		_data[$ "is_damaged"]		?? false;
        depends_on_slot =	_data[$ "depends_on_slot"]	?? "";
        
		// Cargar objetos permitidos.
		if (struct_exists(_data, "permited") ) { __PopulatePermited(_data.permited); }
		
		// Cargar eventos.
		__LoadFunctions(_data);
		
        return self;
    }
	
	#endregion
}

/// @desc Crea una plantilla de slot desde data y la añade a la base de datos.
/// @param {String} key La llave del slot (ej: "SLOT_ARMA").
/// @param {Struct} data El struct de datos leído del JSON.
function mall_create_slot_from_data(_key, _data)
{
    if (mall_exists_slot(_key) )
    {
		return __mall_print($"Advertencia: El slot '{_key}' ya existe. Se omitirá la duplicada.");
	}	

    var _slot = (new MallSlot(_key) ).FromData(_data);
	
    Systemall.__slots[$ _key] = _slot;
    array_push(Systemall.__slots_keys, _key);
}

/// @desc Crea un slot en tiempo de ejecución.
/// @param {String} key La llave del slot (ej: "SLOT_ARMA").
/// @param {Struct.MallSlot} component La instancia del constructor del slot.
function mall_create_slot(_key, _component)
{
    if (mall_exists_slot(_key) )
    {
		return __mall_print($"Advertencia: El slot '{_key}' ya existe. Se omitirá la duplicada.");
	}
	
    Systemall.__slots[$ _key] = _component;
    array_push(Systemall.__slots_keys, _key);
}

/// @desc Devuelve la plantilla de un slot.
/// @param {String} key La llave del slot.
/// @return {Struct.MallSlot}
function mall_get_slot(_key) 
{
	return Systemall.__slots[$ _key]; 
}

/// @desc Comprueba si un slot existe en la base de datos.
/// @param {String} key La llave del slot.
/// @return {Bool}
function mall_exists_slot(_key) 
{
	return struct_exists(Systemall.__slots, _key); 
}

/// @desc Devuelve un array con las llaves de todos los slots creados.
/// @return {Array<String>}
function mall_get_slot_keys() 
{
	return Systemall.__slots_keys; 
}