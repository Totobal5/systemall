/// @desc Define la plantilla de un objeto del inventario.
/// @param {String} key
function PocketItem(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Item ---
    item_type = "UNDEFINED";
    
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
	
	// Comprobar si se puede equipar en un slot.
	/// @param self
	/// @param entity
	event_can_equip = "";
	
	// Comprobar si se puede desequipar de un slot.
	/// @param self
	/// @param entity	
    event_can_desequip = "";
	
	event_on_buy =	"";
	event_on_sell = "";
	
	event_on_world_step = "";
	event_on_world_enter = "";
	event_on_world_exit = "";
	
	event_on_attack = "";
	event_on_defense = "";
	
    /// @desc Configura el item a partir de un struct de datos.
    static FromData = function(_data)
    {
        item_type = string_upper(_data[$ "item_type"] ?? "UNDEFINED");
        
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
        
        // Cargar estadísticas
        if (variable_struct_exists(_data, "stats") )
        {
            var _stat_keys = variable_struct_get_names(_data.stats);
            for (var i = 0; i < array_length(_stat_keys); i++)
            {
                var _stat_key = _stat_keys[i];
                var _stat_array = _data.stats[$ _stat_key];
                var _value = _stat_array[0];
                var _type = (_stat_array[1] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;
                stats[$ _stat_key] = [_value, _type];
            }
        }
        
		// Cargar funciones.
		__LoadFunctions();
		
        return self;
    }

	/// @ignore
	static __LoadFunctions = function()
	{
        // Cargar eventos (heredados de MallEvents)
	    event_on_start =		mall_get_function(event_on_start);
	    event_on_end =			mall_get_function(event_on_end);
	    event_on_update =		mall_get_function(event_on_update);
    
	    // Eventos de Turno
	    event_on_turn_update =	mall_get_function(event_on_turn_update);
	    event_on_turn_start =	mall_get_function(event_on_turn_start);
	    event_on_turn_end =		mall_get_function(event_on_turn_end);
    
	    // Eventos de Equipamiento
		event_on_equip =		mall_get_function(event_on_equip);
		event_on_desequip =		mall_get_function(event_on_desequip);
		
		event_can_equip =		__mall_get_function_check_true(event_can_equip);
	    event_can_desequip =	__mall_get_function_check_true(event_can_desequip);
	
		event_on_buy =			mall_get_function(event_on_buy);
		event_on_sell =			mall_get_function(event_on_sell);
	
		event_on_world_step =	mall_get_function(event_on_world_step);
		event_on_world_enter =	mall_get_function(event_on_world_enter);
		event_on_world_exit =	mall_get_function(event_on_world_exit);
	
		event_on_attack =		mall_get_function(event_on_attack);
		event_on_defense =		mall_get_function(event_on_defense);
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