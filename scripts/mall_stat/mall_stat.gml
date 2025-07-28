#macro __MALL_STAT_ROUND        round
#macro __MALL_STAT_MIN          0
#macro __MALL_STAT_MAX          9999

#macro __MALL_STAT_LEVEL_MIN    1
#macro __MALL_STAT_LEVEL_MAX    100

/// @desc Propiedades de una estadística. Ahora se configura a través de FromData.
/// @param {String} key
function MallStat(_key) : MallEvents(_key) constructor 
{
    // --- Propiedades de la Estadística ---
    
    // Tipo de número que utiliza ("real" o "percent").
    num_type = MALL_NUMTYPE.REAL;
    // Si la entidad puede tener múltiples efectos que afecten esta stat.
    allow_multiple_effects = false;
    // Cuántos efectos de esta stat puede tener una entidad. -1 para infinitos.
    max_effects = -1;
    
    // Si el valor actual se restaura al máximo al equipar algo que lo modifique.
    restore_on_equip = false;
	
    // Límite mínimo que puede alcanzar el valor.
    min_value = __MALL_STAT_MIN;
    // Límite máximo que puede alcanzar el valor.
    max_value = __MALL_STAT_MAX;
    
    // Nivel mínimo.
    min_level = __MALL_STAT_LEVEL_MIN;
    // Nivel máximo.
    max_level = __MALL_STAT_LEVEL_MAX;
    // Si esta estadística sube de nivel de forma independiente.
    is_standalone_level = false;
    
    // Iterador para efectos pasivos o degenerativos (ej: regeneración por turno).
    iterator = new MallIterator();
    
    // --- Llaves de Eventos ---
    // Estas variables ahora guardan el NOMBRE de la función, no la función en sí.
    event_on_start =		"";
    event_on_end =			"";
    event_on_update =		"";
    event_on_level_up =		"";
    event_on_level_check =	"";
    event_on_equip =		"";
    event_on_desequip =		"";

    // Eventos de Turno
    event_on_turn_update =	"";
    event_on_turn_start =	"";
    event_on_turn_end =		"";

    /// @desc Configura la estadística a partir de un struct de datos (leído del JSON).
    /// @param {Struct} data El struct con los datos de la estadística.
    static FromData = function(_data)
    {
        // Tipo de dato.
        num_type = (_data[$ "num_type"] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;
		
        allow_multiple_effects = _data[$ "allow_multiple_effects"] ?? false;
        max_effects = _data[$ "max_effects"] ?? -1;
        
        restore_on_equip = _data[$ "restore_on_equip"] ?? false;
        
        base_value = _data[$ "base_value"] ?? 0;
        min_value = _data[$ "min_value"] ?? __MALL_STAT_MIN;
        max_value = _data[$ "max_value"] ?? __MALL_STAT_MAX;
        
        base_level = _data[$ "base_level"] ?? 1;
        min_level = _data[$ "min_level"] ?? __MALL_STAT_LEVEL_MIN;
        max_level = _data[$ "max_level"] ?? __MALL_STAT_LEVEL_MAX;
        
        is_standalone_level = _data[$ "is_standalone_level"] ?? false;
        
        // Configurar el iterador si existe la data para ello.
        if (variable_struct_exists(_data, "iterator"))
        {
            iterator.Configure(
                _data.iterator[$ "duration"] ?? 1,
                _data.iterator[$ "repeats"]	 ?? 0
            );
        }
        
        // Asignar las llaves de los eventos.
        event_on_start =		_data[$ "event_on_start"]		?? "";
        event_on_end =			_data[$ "event_on_end"]			?? "";
        event_on_update =		_data[$ "event_on_update"]		?? "";
        event_on_level_up =		_data[$ "event_on_level_up"]	?? "";
        event_on_level_check =	_data[$ "event_on_level_check"]	?? "";
        event_on_equip =		_data[$ "event_on_equip"]		?? "";
        event_on_desequip =		_data[$ "event_on_desequip"]	?? "";
	  
		// Eventos de Turno.
		event_on_turn_update =	_data[$ "event_on_turn_update"]	?? "";
	    event_on_turn_start =	_data[$ "event_on_turn_start"]	?? "";
	    event_on_turn_end =		_data[$ "event_on_turn_end"]	?? "";

		
        return self;
    }
}

/// @desc Crea una nueva plantilla de estadística desde data y la añade a la base de datos.
/// @param {String} key La llave de la estadística (ej: "EN").
/// @param {Struct} data El struct de datos leído del JSON.
function mall_create_stat_from_data(_key, _data)
{
    if (mall_exists_stat(_key) )
    {
        show_debug_message($"[Systemall] Advertencia: La estadística '{_key}' ya existe. Se omitirá la duplicada.");
        return;
    }
    
    // Se crea una instancia vacía y luego se configura con los datos.
    var _stat = new MallStat(_key);
    _stat.FromData(_data);
    
    Systemall.__stats[$ _key] = _stat;
    array_push(Systemall.__stats_keys, _key);
}

/// @param {String}          key
/// @param {Struct.MallStat} Stat
function mall_create_stat(_key, _component) 
{
    if (mall_exists_stat(_key) )
    {
        show_debug_message($"[Systemall] Advertencia: La estadística '{_key}' ya existe. Se omitirá la duplicada.");
        return;
	}

	Systemall.__stats[$ _key] = _component;
	array_push(Systemall.__stats_keys, _key);
}

/// @param {String} key
/// @desc Devuelve la estructura de la estadistica
/// @return {Struct.MallStat}
function mall_get_stat(_statKey) 
{
	return (Systemall.__stats[$ _statKey] ); 
}

/// @param {String} key
function mall_exists_stat(_statKey) 
{ 
	return (struct_exists(Systemall.__stats, _statKey) ); 
}

/// @desc Devuelve un array con las llaves de todos las estadisticas creadas
/// @return {Array<String>}
function mall_get_stat_keys() 
{
	return (Systemall.__stats_keys); 
}