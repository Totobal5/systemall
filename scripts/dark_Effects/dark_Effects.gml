/// @desc Plantilla para un efecto que se aplica a una entidad a través de un estado.
/// @param {String} key
function DarkEffect(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Efecto ---
    state_key = "";             // El estado al que este efecto está asociado.
    state_set_value = true;     // El valor booleano que este efecto intenta imponer al estado.
    params = {};				// Parámetros para configurar eventos reutilizables
	
	// Estadisticas que modifica usando el value y num_type que posee.
	// [valor, numtype, activo/pasivo]
	stats = {};
	
	// El valor numérico del efecto (ej: 15 de daño).
    value = 0;
	// El tipo de valor (real o porcentual).
    num_type = MALL_NUMTYPE.REAL;
    
    // Define en qué parte del turno se ejecuta el efecto.
    turn_type = MALL_EFFECT_TURN.START;
    
    // Configuración de los iteradores (no son las instancias).
    iterator_start_config = {};
    iterator_end_config =   {};

	// -- Eventos --
	
	/// @desc Se ejecuta cuando el efecto es añadido a un estado.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity
	/// @param {Struct.EntityStateInstance} state_instance La instancia del estado que contiene este efecto.
    event_on_start = "";
	
	/// @desc Se ejecuta cuando el efecto es eliminado de un estado.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity	
	/// @param {Struct.EntityStateInstance} state_instance La instancia del estado que contenía este efecto.
    event_on_end = "";
		
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity	
	/// @param {Struct.EntityStateInstance} state_instance La instancia del estado que contenía este efecto.
    event_on_turn_start = "";

	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context DarkEffectInstance
	/// @param {Struct.PartyEntity} entity	
	/// @param {Struct.EntityStateInstance} state_instance La instancia del estado que contenía este efecto.
    event_on_turn_end = "";
	
	/// @desc Se ejecuta para obtener un valor que aplicar.
	event_on_calculate = "";
	
    /// @desc Configura el efecto a partir de un struct de datos.
    static FromData = function(_data)
    {
        state_key =			_data[$ "state_key"] ?? "";
        state_set_value =	_data[$ "state_set_value"] ?? true;
        value =				_data[$ "value"] ?? 0;
        num_type =			(_data[$ "num_type"] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;

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
        
		// Cargar estadisticas
        __LoadStats(_data);
		
		// Cargar llaves de eventos...
		__LoadFunction(_data)
		
        return self;
    }
	
	/// @ignore
	static __LoadFunction = function(_data)
	{
		/// @desc Evento al ser añadido
        event_on_start =		_data[$ "event_on_start"]	?? "";
		// Al ser eliminado
        event_on_end =			_data[$ "event_on_end"]		?? "";
		
        event_on_turn_start =	_data[$ "event_on_turn_start"]	?? "";
        event_on_turn_end =		_data[$ "event_on_turn_end"]	?? "";			
	}
	
    /// @desc (Privado) Carga y estandariza las estadísticas desde el struct de datos.
    /// @param {Struct} data El struct con los datos del efecto.
    /// @ignore
    static __LoadStats = function(_data)
    {
        if (variable_struct_exists(_data, "stats") )
        {
            var _source_stats = _data.stats;
            var _mod_keys = variable_struct_get_names(_source_stats);
            var _mod_keys_length = array_length(_mod_keys);
			
            for (var i = 0; i < _mod_keys_length; i++)
            {
                var _mod_key_full = _mod_keys[i];
                var _mod_value_data = _source_stats[$ _mod_key_full];
                
                // --- Determinar stat_key y num_type a partir de la llave ---
                var _len = string_length(_mod_key_full);
                var _suffix = string_char_at(_mod_key_full, _len);
                var _stat_key = _mod_key_full;
                var _num_type = MALL_NUMTYPE.REAL;
                
                if (_suffix == "%" || _suffix == "+") 
				{
                    _stat_key = string_delete(_mod_key_full, _len, 1);
                    if (_suffix == "%") _num_type = MALL_NUMTYPE.PERCENT;
                }
                
                // --- Determinar value y is_passive a partir del valor ---
                var _value;
                var _is_passive;
                
                if (is_array(_mod_value_data) ) 
				{
                    _value = _mod_value_data[0];
                    _is_passive = (array_length(_mod_value_data) > 1) ? _mod_value_data[1] : false;
                } 
				else 
				{
					// Por defecto, un valor simple es un efecto activo
                    _value = _mod_value_data;
                    _is_passive = false;
                }
                
                // Guardar en el formato estandarizado
                stats[$ _stat_key] = [_value, _num_type, _is_passive];
            }
        }
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