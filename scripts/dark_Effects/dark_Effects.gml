/// @desc Plantilla para un efecto que se aplica a una entidad a través de un estado.
/// @param {String} key
function DarkEffect(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Efecto ---
    state_key = "";             // El estado al que este efecto está asociado.
    state_set_value = true;     // El valor booleano que este efecto intenta imponer al estado.
    params = {};				// Parámetros para configurar eventos reutilizables
	 
	// El valor numérico del efecto (ej: 15 de daño).
    value = 0;
	// El tipo de valor (real o porcentual).
    num_type = MALL_NUMTYPE.REAL;
    
    // Define en qué parte del turno se ejecuta el efecto.
    turn_type = MALL_EFFECT_TURN.START;
    
    // Configuración de los iteradores (no son las instancias).
    iterator_start_config = {};
    iterator_end_config =   {};
    
    /// @desc Configura el efecto a partir de un struct de datos.
    static FromData = function(_data)
    {
        state_key =	_data[$ "state_key"] ?? "";
        state_set_value = _data[$ "state_set_value"] ?? true;
        value =	_data[$ "value"] ?? 0;
        num_type = (_data[$ "num_type"] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;
		
		// Cargar parámetros
		params = _data[$ "params"] ?? {};
		
        var _tt = _data[$ "turn_type"] ?? "start";
        switch (_tt) 
		{
            case "end":		turn_type = MALL_EFFECT_TURN.END;	break;
            case "both":	turn_type = MALL_EFFECT_TURN.BOTH;	break;
            default:		turn_type = MALL_EFFECT_TURN.START; break;
        }
        
		// Cargar iteradores.
        if (variable_struct_exists(_data, "iterator_start_config")) 
		{
            iterator_start_config = _data.iterator_start_config;
        }
		
        if (variable_struct_exists(_data, "iterator_end_config") ) 
		{
            iterator_end_config = _data.iterator_end_config;
        }
        
        // Cargar llaves de eventos...
		__LoadFunction(_data)
        
        return self;
    }
	
	/// @ignore
	static __LoadFunction = function(_data)
	{
        event_on_start =		_data[$ "event_on_start"]	?? "";
		// Al ser eliminado
        event_on_end =			_data[$ "event_on_end"]		?? "";
		
        event_on_turn_start =	_data[$ "event_on_turn_start"]	?? "";
        event_on_turn_end =		_data[$ "event_on_turn_end"]	?? "";			
	}
}

/// @desc Crea una plantilla de efecto desde data y la añade a la base de datos.
function mall_effect_create_from_data(_key, _data)
{
    if (mall_exists_effect(_key) ) return;
	
    var _effect = (new DarkEffect(_key) ).FromData(_data);
    Systemall.__dark[$ _key] = _effect;
	
    array_push(Systemall.__dark_keys, _key);
}

/// @desc Comprueba si una plantilla de efecto existe.
function mall_exists_effect(_key)
{
    return struct_exists(Systemall.__dark, _key);
}