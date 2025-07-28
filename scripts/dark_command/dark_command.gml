/// @desc Plantilla base para un comando de batalla o menú.
/// @param {String} key
function DarkCommand(_key) : MallEvents(_key) constructor
{
    // --- Propiedades del Comando ---
	command_type = "";          // Tipo de comando (ej: "PHYSICAL", "MAGIC").
    targets = 1;                // Cuántos objetivos puede afectar.
    
    // Capacidades de objetivo
    can_target_self = false;
    can_target_ally = false;
    can_target_enemy = false;
    
    // Si el mismo objetivo puede ser seleccionado varias veces (para comandos multi-objetivo).
    can_target_same = true;
    
    // --- Llaves de Eventos ---
	event_check = "";       // Función para comprobar si el comando acierta.
    event_execute = "";     // Función que se ejecuta al acertar.
    event_fail = "";        // Función que se ejecuta al fallar.
    event_cinematic = "";   // Función para ejecutar una cinemática.
    event_get_target = "";  // Función por defecto para buscar objetivos.
	
    /// @desc Configura el comando a partir de un struct de datos.
    static FromData = function(_data)
    {
        command_type = _data[$ "command_type"] ?? "";
        targets = _data[$ "targets"] ?? 1;
        can_target_same = _data[$ "can_target_same"] ?? true;
        
        // Cargar tipos de objetivo desde el array
        var _targets = _data[$ "target_types"] ?? [];
        if (is_array(_targets) )
        {
            for (var i = 0; i < array_length(_targets); i++)
            {
                switch (_targets[i] )
                {
                    case "self":	can_target_self = true; break;
                    case "ally":	can_target_ally = true; break;
                    case "enemy":	can_target_enemy = true; break;
                }
            }
        }
        
        // Cargar eventos.
        event_check =		_data[$ "event_check"]		?? "";
        event_execute =		_data[$ "event_execute"]	?? "";
        event_fail =		_data[$ "event_fail"]		?? "";
        event_cinematic =	_data[$ "event_cinematic"]	?? "";
        event_get_target =	_data[$ "event_get_target"]	?? "";
        
        return self;
    }
}

/// @desc Crea una plantilla de comando desde data y la añade a la base de datos.
function mall_command_create_from_data(_key, _data)
{
    if (mall_exists_command(_key) ) return;
    var _command = (new DarkCommand(_key) ).FromData(_data);
	
    // Los comandos también se guardan en la DB de __dark
    Systemall.__dark[$ _key] = _command;
    array_push(Systemall.__dark_keys, _key);
}

/// @desc Comprueba si una plantilla de comando existe.
function mall_exists_command(_key) 
{
	return struct_exists(Systemall.__dark, _key); 
}

/// @desc Devuelve la plantilla de un efecto o comando.
function mall_get_dark(_key)
{
	return Systemall.__dark[$ _key]; 
}