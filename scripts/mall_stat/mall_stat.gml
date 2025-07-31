#macro __MALL_STAT_ROUND        round
#macro __MALL_STAT_MIN          0
#macro __MALL_STAT_MAX          9999

#macro __MALL_STAT_LEVEL_MIN    1
#macro __MALL_STAT_LEVEL_MAX    100

/// @desc Define la plantilla base para una estadística del juego.
/// @param {String} key
function MallStat(_key) : MallEvents(_key) constructor 
{
    // --- Propiedades de la Estadística ---
    
    /// @desc El tipo de valor que utiliza la estadística (REAL o PERCENT).
	/// @type {Enum.MALL_NUMTYPE}
    num_type = MALL_NUMTYPE.REAL;
    
    /// @desc Si la entidad puede tener múltiples efectos que afecten esta stat.
	/// @type {Bool}
    allow_multiple_effects = false;
    
    /// @desc Cuántos efectos de esta stat puede tener una entidad. -1 para infinitos.
	/// @type {Real}
    max_effects = -1;
    
    /// @desc Si el valor actual se restaura al máximo al equipar algo que lo modifique.
	/// @type {Bool}
    restore_on_equip = false;
	
    /// @desc El límite mínimo que puede alcanzar el valor de la estadística.
	/// @type {Real}
    min_value = __MALL_STAT_MIN;
    
    /// @desc El límite máximo que puede alcanzar el valor de la estadística.
	/// @type {Real}
    max_value = __MALL_STAT_MAX;
    
    /// @desc El nivel mínimo de la estadística.
	/// @type {Real}
    min_level = __MALL_STAT_LEVEL_MIN;
    
    /// @desc El nivel máximo de la estadística.
	/// @type {Real}
    max_level = __MALL_STAT_LEVEL_MAX;
    
    /// @desc Si esta estadística sube de nivel de forma independiente al nivel de la entidad.
	/// @type {Bool}
    is_standalone_level = false;
    
    /// @desc Un iterador para efectos pasivos o degenerativos (ej: regeneración por turno).
	/// @type {Struct.MallIterator}
    iterator = new MallIterator();
    
    // --- Llaves de Eventos ---
	
	/// @desc Se ejecuta una vez cuando la instancia es creada para una entidad.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_start =		"";
	
	/// @desc (Sin implementación actual en el motor)
    event_on_end =			"";
	
	/// @desc Se ejecuta en cada llamada a RecalculateStats, después de calcular el peak_value.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_update =		"";
	
	/// @desc Se ejecuta para calcular el peak_value de la estadística. Debe devolver el nuevo valor.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_level_up =		"";
	
	/// @desc (Para stats standalone) Comprueba si la estadística puede subir de nivel. Debe devolver bool.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_level_check =	"";
	
	/// @desc Se ejecuta cuando se equipa un objeto en CUALQUIER slot de la entidad.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot donde se equipó el objeto.
    event_on_equip =		"";
	
	/// @desc Se ejecuta cuando se desequipa un objeto de CUALQUIER slot de la entidad.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
	/// @param {Struct.EntitySlotInstance} slot_instance El slot de donde se desequipó el objeto.
    event_on_desequip =		"";

    // Eventos de Turno
	
	/// @desc Se ejecuta en cada actualización de turno del WateManager.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_update =	"";
	
	/// @desc Se ejecuta al inicio del turno de la entidad.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_start =	"";
	
	/// @desc Se ejecuta al final del turno de la entidad.
	/// @context EntityStatInstance
	/// @param {Struct.PartyEntity} entity La entidad dueña.
    event_on_turn_end =		"";


	#region PRIVATE

	/// @desc (Privado) Cargar string de eventos para ser usados más adelante.
	/// @param {Struct} data El struct con los datos de la estadística.
	/// @ignore
	static __LoadFunctions = function(_data)
	{
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
	}
	
	#endregion
	
	
	#region API
	
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
        
		// Cargar eventos
		__LoadFunctions(_data);

        return self;
    }
	
	#endregion
}

/// @desc Crea una nueva plantilla de estadística desde data y la añade a la base de datos.
/// @param {String} key La llave de la estadística (ej: "EN").
/// @param {Struct} data El struct de datos leído del JSON.
function mall_stat_create_from_data(_key, _data)
{
    if (mall_exists_stat(_key) )
    {
		return __mall_print($"Advertencia: La estadística '{_key}' ya existe. Se omitirá la duplicada.");
    }
    
    // Se crea una instancia vacía y luego se configura con los datos.
    var _stat = new MallStat(_key).FromData(_data);
	
    Systemall.__stats[$ _key] = _stat;
    array_push(Systemall.__stats_keys, _key);
}

/// @desc Crea una estadística en tiempo de ejecución.
/// @param {String} key La llave de la estadística.
/// @param {Struct.MallStat} component La instancia del constructor de la estadística.
function mall_create_stat(_key, _component) 
{
    if (mall_exists_stat(_key) )
    {
		return __mall_print($"Advertencia: La estadística '{_key}' ya existe. Se omitirá la duplicada.");
    }
	
	Systemall.__stats[$ _key] = _component;
	array_push(Systemall.__stats_keys, _key);
}

/// @desc Devuelve la plantilla de una estadística.
/// @param {String} statKey La llave de la estadística.
/// @return {Struct.MallStat}
function mall_get_stat(_statKey) 
{
	return (Systemall.__stats[$ _statKey] ); 
}

/// @desc Comprueba si una estadística existe en la base de datos.
/// @param {String} statKey La llave de la estadística.
/// @return {Bool}
function mall_exists_stat(_statKey) 
{ 
	return (struct_exists(Systemall.__stats, _statKey) ); 
}

/// @desc Devuelve un array con las llaves de todas las estadísticas creadas.
/// @return {Array<String>}
function mall_get_stat_keys() 
{
	return (Systemall.__stats_keys); 
}