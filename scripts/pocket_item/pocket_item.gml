/// @desc Define la plantilla de un objeto del inventario.
/// @param {String} key
function PocketItem(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Item ---
    item_type = "UNDEFINED";
    is_stackable = true;    // Si el objeto se puede apilar.
    stack_limit = 99;       // Límite de apilamiento.
	vars = {};				// Variables únicas del objeto y que comparten todas las plantillas de este.
	
    // Capacidades de objetivo
    can_target_self = false;
    can_target_ally = true;
    can_target_enemy = false;
    
    // Valores de comercio
    buy_value = 0;
    sell_value = 0;
    can_sell = true;
    can_buy = true;
    
    // Estadísticas que el objeto otorga [valor, tipo]
    stats = {};

	// --- Eventos ---
	
	/// @desc Evento que se ejecuta en: PartyEntity.RecalculateStat
	/// @param {Struct.PartyEntity} entity
	event_on_update = "";
	
	/// @desc Valida si este objeto puede ser equipado por una entidad en un slot. Debe devolver bool.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} entity La entidad que intenta equipar.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot objetivo.
	event_can_equip = "";
	
	/// @desc Valida si este objeto puede ser desequipado. Debe devolver bool.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} entity La entidad que intenta desequipar.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot de donde se desequipa.
    event_can_desequip = "";
	
	/// @desc Se ejecuta cuando el objeto es comprado.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.MallShop} shop La tienda donde se compró.
	event_on_buy =	"";
	
	/// @desc Se ejecuta cuando el objeto es vendido.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.MallShop} shop La tienda donde se vendió.
	event_on_sell = "";
	
	/// @desc (Sin implementación en el motor)
	event_on_world_step = "";
	/// @desc (Sin implementación en el motor)
	event_on_world_enter = "";
	/// @desc (Sin implementación en el motor)
	event_on_world_exit = "";
	
	/// @desc Se ejecuta cuando la entidad equipada ataca.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} caster La entidad que ataca.
	/// @param {Struct.PartyEntity} target El objetivo del ataque.
	event_on_attack = "";
	
	/// @desc Se ejecuta cuando la entidad equipada es atacada.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} defender La entidad que es atacada.
	/// @param {Struct.PartyEntity} attacker El atacante.
	event_on_defense = "";

	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} entity La entidad que actualiza turno.
    event_on_turn_update =	"";
	
	/// @desc Se ejecuta al inicio del turno de la entidad que lo lleve activado.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} entity La entidad que actualiza turno.
    event_on_turn_start =	"";
	
	/// @desc Se ejecuta al final del turno de la entidad que lo lleve activado.
	/// @context PocketItem (la plantilla)
	/// @param {Struct.PartyEntity} entity La entidad que actualiza turno.
    event_on_turn_end =		"";

    /// @desc (Privado) Carga las estadísticas desde el struct de datos.
    /// @param {Struct} data El struct con los datos del item.
    /// @ignore
    static __LoadStats = function(_data)
    {
        if (variable_struct_exists(_data, "stats") )
        {
            var _mod_keys = variable_struct_get_names(_data.stats);
			var _mod_length = array_length(_mod_keys);
            for (var i = 0; i < _mod_length; i++)
            {
                var _mod_key_full = _mod_keys[i];
                var _len = string_length(_mod_key_full);
                var _suffix = string_char_at(_mod_key_full, _len);
                
                var _stat_key = _mod_key_full;
                var _type = MALL_NUMTYPE.REAL;
                
                // Comprobar si hay un sufijo
                if (_suffix == "%" || _suffix == "+") {
                    _stat_key = string_delete(_mod_key_full, _len, 1);
                    if (_suffix == "%") {
                        _type = MALL_NUMTYPE.PERCENT;
                    }
                }
                
                var _value = _data.stats[$ _mod_key_full];
                
                // La representación interna sigue siendo un array [valor, tipo]
                stats[$ _stat_key] = [_value, _type];
            }
        }
    }

	/// @ignore
	static __LoadFunctions = function(_data)
	{
        // Cargar eventos (heredados de MallEvents) No implementados
	    event_on_update =		mall_get_function( _data[$ "event_on_update"] );
    
	    // Eventos de Turno
	    event_on_turn_update =	mall_get_function( _data[$ "event_on_turn_update"] );
	    event_on_turn_start =	mall_get_function( _data[$ "event_on_turn_start"] );
	    event_on_turn_end =		mall_get_function( _data[$ "event_on_turn_end"] );
		
	    // Eventos de Equipamiento
		event_on_equip =		mall_get_function( _data[$ "event_on_equip"] );
		event_on_desequip =		mall_get_function( _data[$ "event_on_desequip"] );
		
		event_can_equip =		__mall_get_function_check_true( _data[$ "event_can_equip"] );
	    event_can_desequip =	__mall_get_function_check_true( _data[$ "event_can_desequip"] );
	
		event_on_buy =			mall_get_function( _data[$ "event_on_buy"] );
		event_on_sell =			mall_get_function( _data[$ "event_on_sell" ] );
	
		// event_on_world_step =	mall_get_function( _data[$ "event_on_world_step"] );
		// event_on_world_enter =	mall_get_function( _data[$ "event_on_world_enter"] );
		// event_on_world_exit =	mall_get_function( _data[$ "event_on_world_exit"] );
	
		event_on_attack =		mall_get_function( _data[$ "event_on_attack"] );
		event_on_defense =		mall_get_function( _data[$ "event_on_defense"] );
	}

    /// @desc Configura el item a partir de un struct de datos.
    static FromData = function(_data)
    {
        item_type =		string_upper(_data[$ "item_type"] ?? "UNDEFINED");
        is_stackable =	_data[$ "is_stackable"] ?? true;
        stack_limit =	_data[$ "stack_limit"] ?? 99;
		vars =			variable_clone( _data[$ "vars"] ?? vars );
	  
        // Se lee el array "target_types" del JSON. Si no existe, por defecto es ["ally"].
        var _targets = _data[$ "target_types"] ?? ["ally"];
        if (is_array(_targets))
        {
            // Se itera sobre el array y se activa cada booleano correspondiente.
            for (var i = 0; i < array_length(_targets); i++)
            {
                switch (_targets[i])
                {
                    case "self":	can_target_self = true; break;
                    case "ally":	can_target_ally = true; break;
                    case "enemy":	can_target_enemy = true; break;
                }
            }
        }
        
		// Economia
        buy_value =		_data[$ "buy_value"]	?? 0;
        sell_value =	_data[$ "sell_value"]	?? 0;
        can_sell =		_data[$ "can_sell"]		?? true;
        can_buy =		_data[$ "can_buy"]		?? true;
        
		// Cargar.
		__LoadStats(_data);
		__LoadFunctions(_data);
		
        return self;
    }
}

/// @desc Crea una plantilla de item desde data y la añade a la base de datos.
function pocket_create_item_from_data(_key, _data)
{
    if (pocket_item_exists(_key) ) 
	{
		show_debug_message($"[Systemall] Advertencia: El objeto '{_key}' ya existe. Se omitirá el duplicado.");
		return;
	}

    var _item = (new PocketItem(_key)).FromData(_data);
    Systemall.__items[$ _key] = _item;
    array_push(Systemall.__items_keys, _key);
    
    // Registrar el item en su categoría de tipo
    mall_create_type(_item.item_type, _key);
}

/// @desc Devuelve la plantilla de un objeto.
function pocket_item_get(_key) 
{ 
	return Systemall.__items[$ _key]; 
}

/// @desc Comprueba si un objeto existe.
function pocket_item_exists(_key) 
{ 
	return struct_exists(Systemall.__items, _key); 
}