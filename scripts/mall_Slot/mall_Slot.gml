/// @desc Define un "espacio" en una entidad donde se pueden equipar objetos.
/// @param {String} key
function MallSlot(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Slot ---
    max_items = 1;          // Cuántos objetos se pueden equipar en este slot.
    is_disabled = false;    // Si el slot está desactivado por defecto.
    is_damaged = false;     // Si el slot está dañado (puede tener efectos negativos).
    depends_on_slot = "";   // La llave de otro slot del que depende para estar activo.
    
    // --- Llaves de Eventos ---
	// Evento para comprobar el objeto que se le va a equipar.
	event_on_item_check = ""
	// Evento al atacar
    event_on_attack = "";
	// Evento al ser atacado.
    event_on_defend = "";

    /// @desc Configura el slot a partir de un struct de datos.
    /// @param {Struct} data El struct con los datos del slot.
    static FromData = function(_data)
    {
        max_items = _data.max_items ?? 1;
        is_disabled = _data.is_disabled ?? false;
        is_damaged = _data.is_damaged ?? false;
        depends_on_slot = _data.depends_on_slot ?? "";
        
        // Asignar llaves de eventos
        event_on_equip = _data.event_on_equip ?? "";
        event_on_desequip = _data.event_on_desequip ?? "";
        event_on_attack = _data.event_on_attack ?? "";
        event_on_defend = _data.event_on_defend ?? "";
        
        return self;
    }
}

/// @desc Crea una plantilla de slot desde data y la añade a la base de datos.
/// @param {String} key
function mall_slot_create_from_data(_key, _data)
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
function mall_get_slot(_key) { return Systemall.__slots[$ _key]; }

/// @desc Comprueba si un slot existe.
/// @param {String} key
function mall_exists_slot(_key) { return struct_exists(Systemall.__slots, _key); }

/// @desc Devuelve las llaves de todos los slots.
/// @return {Array<String>}
function mall_get_slot_keys() { return Systemall.__slots_keys; }