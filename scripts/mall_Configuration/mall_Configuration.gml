#macro __MALL_VERSION		"v2.8"
#macro __MALL_VERSION_MINE	__MALL_VERSION+"::1.0"
#macro __MALL_TRACE			true
#macro __MALL_ERROR			true
#macro __MALL_SAFETY		true

#region PARTY
// Indicar procesos realizados
#macro __MALL_PARTY_TRACE           true
#macro __MALL_PARTY_TRACE_LEVELUP   true

// Comprobar por errores
#macro __MALL_PARTY_SAFETY          false
#macro __MALL_PARTY_LEVEL_MIN       1
#macro __MALL_PARTY_LEVEL_MAX       100

#endregion

#region POCKET
#macro __MALL_POCKET_TRACE      true
#macro __MALL_POCKET_BAG_MIN    0
#macro __MALL_POCKET_BAG_MAX    99

#endregion

#region DARK
#macro __MALL_DARK_TRACE        true
#macro __MALL_DARK_SAFETY       false

/*	0: Inicio del turno
	1: Final  del turno
    2: En el inicio y final del turno */	
enum MALL_EFFECT_TURN 
{
	START, 
	END, 
	BOTH
}

#endregion

#region WATE
#macro __MALL_WATE_TRACE        true
#macro __MALL_WATE_SAFETY       false

#endregion

enum MALL_NUMTYPE   {REAL,  PERCENT}

enum MALL_NUMVAL    {VALUE, TYPE}

/// @desc Donde se guardan todos los datos que se utilizarán por Systemall.
function Systemall()
{
	/// @ignore Struct con todos los archivos cargados.
	static __master = {};
	/// @ignore Struct con todas las funciones accesibles por Systemall.
	static __functions = {};
	/// @ignore Struct con todas las instancias "vivas" de entidades en el juego.
	static __instances = {};

	// -- Componentes --
	/// @ignore Base de datos donde se guardan todos los constructors de estadisticas del sistema.
	static __stats = {};
	static __stats_keys = [];

	/// @ignore Base de datos donde se guardan los "Estados" del sistema.
	static __states = {}
	static __states_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los constructors de slots del sistema.
	static __slots = {};
	static __slots_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los items del sistema.
	static __items = {};
	static __items_keys = [];
	
	/// @ignore Base de datos donde se guardan todas las mochilas del sistema.
	static __bags = {};
	static __bags_keys = [];
	static __persistent_bags = [];	
	
	/// @ignore Base de datos donde se guardan todos los grupos del sistema.
	static __groups = {};
	static __groups_keys = [];
	static __persistent_groups = [];
	/// @ignore El grupo principal del jugador.
    static __player_group = undefined;

	
	/// @ignore Base de datos donde se guardan todas las entidades del sistema.
	static __entities = {};
	static __entities_keys = [];	
	
	/// @ignore Base de datos donde se guardan todos los comandos y efectos del sistema.
	static __dark = {};
	static __dark_keys = [];	
	
	/// @ignore Base de datos donde se guardan todos los "Tipos" del sistema.
    static __types = {
		// tipo: [valor 1, valor 2, valor 3]
	};
	static __types_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los "Grupos" de batalla del sistema (Para enfrentamientos).
    static __wate_manager = undefined;
	static __wate = {};
	static __wate_keys = [];
	
	/// @ignore
	static __ai_packages = {};
	static __ai_rules = {};
	static __ai_keys = [];
	
	/// @ignore Sistema de Broadcast y Mensajes para el sistema.
    static __broadcast = {};
	static __messages = [];
}

/// @desc Carga un archivo maestro y procesa los datos en un orden garantizado.
/// @param {String} master_file_path La ruta al archivo JSON maestro.
function mall_init(_master_file_path)
{
	static _process_order = [
        "STATS", "ITEMS", "SLOTS", "STATES", "EFFECTS", "COMMANDS", "AI", "PARTY", "GROUPS", "BAGS" 
    ];
	
    // --- FASE 1: RECOPILAR TODOS LOS DATOS ---
    
    if (!file_exists(_master_file_path)) {
        show_error($"[Systemall] ¡Error Crítico! El archivo maestro no existe: {_master_file_path}", true);
        return;
    }
    
    var _file = file_text_open_read(_master_file_path);
    var _json_string = "";
    while (!file_text_eof(_file)) { _json_string += file_text_readln(_file); }
    file_text_close(_file);
    
    var _master_data = json_parse(_json_string);
    if (!is_struct(_master_data)) {
        show_error("[Systemall] ¡Error Crítico! El archivo maestro no es un JSON válido.", true);
        return;
    }
    
    Systemall.__master = _master_data;
    var _temp_data_pool = {}; // Struct para agrupar datos por tipo
    
    var _categories = variable_struct_get_names(_master_data);
    for (var i = 0; i < array_length(_categories); i++) {
        var _category_name = _categories[i];
        var _file_paths = _master_data[$ _category_name];
        
        for (var j = 0; j < array_length(_file_paths); j++) {
            var _data_file_path = _file_paths[j];
            if (!file_exists(_data_file_path)) {
                show_debug_message($"[Systemall] Advertencia: Archivo no encontrado '{_data_file_path}'.");
                continue;
            }
            
            var _data_file = file_text_open_read(_data_file_path);
            var _data_json_string = "";
            while (!file_text_eof(_data_file)) { _data_json_string += file_text_readln(_data_file); }
            file_text_close(_data_file);
            
            var _loaded_data = json_parse(_data_json_string);
            
            if (is_struct(_loaded_data) && variable_struct_exists(_loaded_data, "type")) {
                var _type = string_upper(_loaded_data.type);
                if (!variable_struct_exists(_temp_data_pool, _type)) {
                    _temp_data_pool[$ _type] = [];
                }
                variable_struct_remove(_loaded_data, "type");
                array_push(_temp_data_pool[$ _type], _loaded_data);
            } else {
                show_debug_message($"[Systemall] Error: Archivo '{_data_file_path}' no tiene un campo 'type' válido.");
            }
        }
    }
    
    // --- FASE 2: PROCESAR LOS DATOS EN ORDEN --- 
    for (var i = 0; i < array_length(_process_order); i++) 
	{
        var _current_type = _process_order[i];
        
        if (!variable_struct_exists(_temp_data_pool, _current_type)) continue;
        
        var _data_array = _temp_data_pool[$ _current_type];
        
        for (var j = 0; j < array_length(_data_array); j++) 
		{
            var _data_struct = _data_array[j];
            var _keys = variable_struct_get_names(_data_struct);
            
            for (var k = 0; k < array_length(_keys); k++) 
			{
                var _key = _keys[k];
                var _entry_data = _data_struct[$ _key];
                
                switch (_current_type) {
                    case "STATS":
						mall_create_stat_from_data(_key, _entry_data);   
						
						break;

                    case "ITEMS":
						pocket_create_item_from_data(_key, _entry_data); 
						
						break;

                    case "SLOTS":
						mall_create_slot_from_data(_key, _entry_data);   
						
						break;

                    case "STATES":
						mall_state_create_from_data(_key, _entry_data);  
						
						break;

                    case "EFFECTS":
						mall_effect_create_from_data(_key, _entry_data); 
						
						break;

                    case "COMMANDS":
						mall_command_create_from_data(_key, _entry_data);
						
						break;

                    case "PARTY":
						party_create_entity_template(_key, _entry_data); 
						
						break;
						
                    case "GROUPS":	
						party_create_group_from_data(_key, _entry_data); 
						
						break;
						
					case "AI":
						mall_ai_create_from_data(_key, _entry_data);
						
						break;
						
						
                    // case "BAGS":    pocket_bag_create_from_data(_key, _entry_data);    break;
                }
            }
        }
    }
    
    // --- FASE 3: POBLAR LAS LISTAS DE LLAVES ---
    Systemall.__stats_keys      = variable_struct_get_names(Systemall.__stats);
    Systemall.__items_keys      = variable_struct_get_names(Systemall.__items);
    Systemall.__slots_keys      = variable_struct_get_names(Systemall.__slots);
    Systemall.__states_keys     = variable_struct_get_names(Systemall.__states);
    Systemall.__dark_keys       = variable_struct_get_names(Systemall.__dark);
    Systemall.__entities_keys   = variable_struct_get_names(Systemall.__entities);
    Systemall.__groups_keys     = variable_struct_get_names(Systemall.__groups);
    // ... etc.
    
    show_debug_message("[Systemall] Carga de la base de datos desde JSON completada.");
}

// -----------------------------------------------------------------------------
// API DE GUARDADO Y CARGA
// -----------------------------------------------------------------------------

/// @desc Guarda el estado completo del juego en un archivo.
/// @param {String} filename El nombre del archivo de guardado (ej: "savegame1.sav").
/// @return {Bool} Devuelve true si el guardado fue exitoso.
function mall_save_system(_filename)
{
    try
    {
        var _save_data = {
            version:	__MALL_VERSION_MINE,
            instances:	[],
            bags:		{},
            groups:		{}
        };
        
        // --- 1. Guardar Instancias de Entidades ---
        var _instance_keys = variable_struct_get_names(Systemall.__instances);
        for (var i = 0; i < array_length(_instance_keys); i++)
        {
            var _inst = Systemall.__instances[$ _instance_keys[i]];
            array_push(_save_data.instances, _inst.Export());
        }
        
        // --- 2. Guardar Mochilas Persistentes ---
        for (var i = 0; i < array_length(Systemall.__persistent_bags); i++)
        {
            var _bag_key = Systemall.__persistent_bags[i];
            if (pocket_bag_exists(_bag_key))
            {
                var _bag = pocket_bag_get(_bag_key);
                _save_data.bags[$ _bag_key] = _bag.Export();
            }
        }
        
        // --- 3. Guardar Grupos Persistentes ---
        for (var i = 0; i < array_length(Systemall.__persistent_groups); i++)
        {
            var _group_key = Systemall.__persistent_groups[i];
            if (party_exists_group(_group_key))
            {
                var _group = party_get_group(_group_key);
                _save_data.groups[$ _group_key] = _group.Export();
            }
        }
        
        // --- 4. Convertir a JSON y Guardar en Archivo ---
        var _json_string = json_stringify(_save_data);
        
        var _file = file_text_open_write(_filename);
        file_text_write_string(_file, _json_string);
        file_text_close(_file);
        
        show_debug_message($"[Systemall] Partida guardada exitosamente en '{_filename}'.");
        return true;
    }
    catch (_ex)
    {
        show_error($"[Systemall] Error al guardar la partida: " + exception_get_string(_ex), true);
        return false;
    }
}

/// @desc Carga el estado completo del juego desde un archivo.
/// @param {String} filename El nombre del archivo de guardado.
/// @return {Bool} Devuelve true si la carga fue exitosa.
function mall_load_system(_filename)
{
    if (!file_exists(_filename))
    {
        show_debug_message($"[Systemall] Archivo de guardado no encontrado: '{_filename}'.");
        return false;
    }
    
    try
    {
        // --- 1. Cargar y Parsear el Archivo ---
        var _file = file_text_open_read(_filename);
        var _json_string = "";
        while (!file_text_eof(_file)) { _json_string += file_text_readln(_file); }
        file_text_close(_file);
        
        var _load_data = json_parse(_json_string);
        
        // --- 2. Limpiar el Estado Actual del Juego ---
        Systemall.__instances = {};
        
        // Limpiar grupos persistentes antes de cargar
        for (var i = 0; i < array_length(Systemall.__persistent_groups); i++) {
            var _group = party_get_group(Systemall.__persistent_groups[i]);
            if (!is_undefined(_group)) _group.Clean();
        }
        
        // --- 3. Cargar Instancias de Entidades ---
        var _saved_instances = _load_data.instances ?? [];
        for (var i = 0; i < array_length(_saved_instances); i++)
        {
            var _inst_data = _saved_instances[i];
            var _template_key = _inst_data.template_key;
            
            // Crear una nueva instancia (se registra automáticamente)
            var _new_inst = party_entity_create_instance(_template_key, 1);
            
            // Importar el estado guardado
            _new_inst.Import(_inst_data);
        }
        
        // --- 4. Cargar Grupos Persistentes ---
        // Esto debe hacerse DESPUÉS de cargar las instancias, para que las entidades existan.
        if (variable_struct_exists(_load_data, "groups"))
        {
            var _saved_groups = _load_data.groups;
            var _group_keys = variable_struct_get_names(_saved_groups);
            for (var i = 0; i < array_length(_group_keys); i++)
            {
                var _key = _group_keys[i];
                if (party_exists_group(_key)) {
                    var _group = party_get_group(_key);
                    _group.Import(_saved_groups[$ _key]);
                }
            }
        }
        
        // --- 5. Cargar Mochilas Persistentes ---
        if (variable_struct_exists(_load_data, "bags"))
        {
            var _saved_bags = _load_data.bags;
            var _bag_keys = variable_struct_get_names(_saved_bags);
            for (var i = 0; i < array_length(_bag_keys); i++)
            {
                var _key = _bag_keys[i];
                if (pocket_bag_exists(_key)) {
                    var _bag = pocket_bag_get(_key);
                    _bag.Import(_saved_bags[$ _key]);
                }
            }
        }
        
        // --- 6. Notificar al resto del juego ---
        mall_broadcast_post("ON_GAME_LOADED", { success: true });
        show_debug_message("[Systemall] Partida cargada exitosamente.");
        return true;
    }
    catch (_ex)
    {
        show_error($"[Systemall] Error al cargar la partida: " + exception_get_string(_ex), true);
        mall_broadcast_post("ON_GAME_LOADED", { success: false });
        return false;
    }
}


// Generar statics
script_execute(Systemall);
script_execute(Mall);
script_execute(MallEvents);
script_execute(MallIterator);

script_execute(MallStat);
script_execute(MallSlot);
script_execute(MallState);
script_execute(MallResult);

mall_init("mall_database.json");


var _entity = party_entity_create_instance("JON", 10);
