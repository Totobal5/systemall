/// @ignore Core library semantic version.
#macro __MALL_VERSION		"4.0.0"
/// @ignore Build/version suffix used in save payload metadata.
#macro __MALL_VERSION_MINE	__MALL_VERSION+"::1.0"
/// @ignore Enables Systemall trace logging.
#macro __MALL_ALERT			true
/// @ignore Enables Systemall error logging.
#macro __MALL_ERROR			true
/// @ignore Aborts execution on critical Systemall errors. Keep false when running the test-suite.
#macro __MALL_STRICT_MODE	false
/// @ignore Enables additional runtime safety checks.
#macro __MALL_SAFETY		true

#region STATS
/// @ignore Rounding method used for stat values.
#macro __MALL_STAT_ROUNDING_METHOD	round
/// @ignore Minimum stat value.
#macro __MALL_STAT_MIN	0
/// @ignore Maximum stat value.
#macro __MALL_STAT_MAX	9999

/// @ignore Minimum standalone stat level (when is_standalone_level is true).
#macro __MALL_STAT_LEVEL_MIN	1
/// @ignore Maximum standalone stat level (when is_standalone_level is true).
#macro __MALL_STAT_LEVEL_MAX	100

#endregion

#region ENTITIES & GROUP

/// @ignore Enables trace logs for groups and entities.
#macro __MALL_ENTITIES_ALERT			__MALL_ALERT && true
/// @ignore Enables level-up trace logs for entities.
#macro __MALL_ENTITIES_ALERT_LEVELUP	__MALL_ENTITIES_ALERT && true
/// @ignore Enables additional safety checks for groups and entities.
#macro __MALL_ENTITIES_SAFETY			__MALL_SAFETY && true
/// @ignore Minimum allowed entity level.
#macro __MALL_ENTITIES_LEVEL_MIN		1
/// @ignore Maximum allowed entity level.
#macro __MALL_ENTITIES_LEVEL_MAX		100

#endregion

#region BAG & ITEMS
/// @ignore Enables trace logs for bag operations.
#macro __MALL_BAG_ALERT   __MALL_ALERT && true
/// @ignore 
#macro __MALL_BAG_SAFETY  __MALL_SAFETY && true
/// @ignore Minimum allowed bag size.
#macro __MALL_BAG_MIN    0
/// @ignore Maximum allowed bag size.
#macro __MALL_BAG_MAX    99

#endregion

#region COMMAND & EFFECTS
/// @ignore Enables trace logs for command systems.
#macro __MALL_COMMAND_ALERT       __MALL_ALERT && true
/// @ignore Enables extra runtime validation for command systems.
#macro __MALL_COMMAND_SAFETY      __MALL_SAFETY && true
/// @ignore Enables trace logs for effect systems.
#macro __MALL_EFFECT_ALERT        __MALL_ALERT && true
/// @ignore Enables extra runtime validation for effect systems.
#macro __MALL_EFFECT_SAFETY       __MALL_SAFETY && true

#endregion

#region BATTLE
/// @ignore Enables trace logs for Battle encounter flow.
#macro __MALL_BATTLE_ALERT        __MALL_ALERT && true
/// @ignore Enables extra runtime validation for Battle systems.
#macro __MALL_BATTLE_SAFETY       __MALL_SAFETY && true

#endregion

#region BROADCAST
/// @ignore Enables trace logs for broadcast and message systems.
#macro __MALL_BROADCAST_ALERT      __MALL_ALERT && true

#endregion

/// @ignore
/// @desc Internal global runtime container used by the Mall systems.
function __Systemall()
{
	/// @ignore Struct with all loaded data files.
	static __master = {};
	/// @ignore Struct with all functions exposed to __Systemall.
	static __events = {};
	/// @ignore Struct with all live entity instances in the current game session.
	static __instances = {};

	// -- Components --
	/// @ignore Stat template database.
	static __stats = {};
	/// @ignore
	static __stats_keys = [];

	/// @ignore State template database.
	static __states = {}
	/// @ignore
	static __states_keys = [];
	
	/// @ignore Slot template database.
	static __slots = {};
	/// @ignore
	static __slots_keys = [];
	
	/// @ignore Item template database.
	static __items = {};
	/// @ignore
	static __items_keys = [];
	
	/// @ignore Bag template database.
	static __bags = {};
	/// @ignore
	static __bags_keys = [];
	/// @ignore
	static __persistent_bags = [];	
	
	/// @ignore Shop template database.
	static __shops = {};
	/// @ignore
	static __shops_keys = [];
	
	/// @ignore Group template database.
	static __groups = {};
	/// @ignore
	static __groups_keys = [];
	/// @ignore
	static __persistent_groups = [];
	/// @ignore Primary player group instance.
	static __player_group = undefined;

	/// @ignore Entity template database.
	static __entities = {};
	/// @ignore
	static __entities_keys = [];	
	
	/// @ignore Loot table database.
	static __loot_tables = {};
	/// @ignore
	static __loot_tables_keys = [];
	
	/// @ignore Shared database for commands and effects.
	static __commands = {};
	/// @ignore
	static __commands_keys = [];	
	
	/// @ignore Effects database.
	static __effects = {};
	/// @ignore
	static __effects_keys = [];
	
	/// @ignore Runtime type database.
	static __types = { /* type: [value1, value2, value3] */ };
	/// @ignore
	static __types_keys = [];
	
	/// @ignore Battle encounter database.
	static __battle_manager = undefined;
	/// @ignore
	static __battle = { encounters: {} };
	/// @ignore
	static __battle_keys = [];
	
	/// @ignore
	static __ai_packages = {};
	/// @ignore
	static __ai_rules = {};
	/// @ignore
	static __ai_keys = [];
	
	/// @ignore Broadcast and message subsystem state.
	static __broadcast = {};
	/// @ignore
	static __messages = [];
	
	/// @ignore Public assets accessible by __Systemall.
	static __assets = {};
}

/// @desc Loads a master file and processes data in a deterministic order.
/// @param {String} master_file_path Master JSON file path.
function mall_init(_master_file_path)
{
	/// @ignore
	static __process_order = [
		"STATS", "ITEMS", "SLOTS", "STATES", "EFFECTS", "COMMANDS", "AI", "ENTITIES", "GROUPS", "BAGS", "BATTLE"
	];

	// Ensure built-in core callbacks are available before loading data files.
	__mall_register_core_events_commands();
	
	#region COLLECT_ALL_DATA
	
	if (!file_exists(_master_file_path) )
	{
		__mall_error($"Master file not found: '{_master_file_path}'.");
		exit;
	}

	var _master_file = file_text_open_read(_master_file_path);
	var _master_json = "";
	while (!file_text_eof(_master_file) ) { _master_json += file_text_readln(_master_file); }
	file_text_close(_master_file);

	var _master_data = json_parse(_master_json);
	if (!is_struct(_master_data) ) 
	{
		__mall_error("Master file is not valid JSON.");
		exit;
	}
	
	__Systemall.__master = _master_data;
	
	// Struct grouping loaded payloads by type.
	var _temp_data_pool = {};
	var _categories = struct_get_names(_master_data);
	var _categories_size = array_length(_categories);
	for (var i = 0; i < _categories_size; i++)
	{
		var _category_name = _categories[i];
		var _file_paths = _master_data[$ _category_name];
		var _file_paths_size = array_length(_file_paths);

		// Read each file listed in the master entry.
		for (var j = 0; j < _file_paths_size; j++)
		{
			var _data_file_path = _file_paths[j];
			if (!file_exists(_data_file_path) ) 
			{
				__mall_alert($"File not found '{_data_file_path}'.");
				continue;
			}

			var _data_file = file_text_open_read(_data_file_path);
			var _data_json = "";
			while (!file_text_eof(_data_file) ) { _data_json += file_text_readln(_data_file); }
			file_text_close(_data_file);
			
			var _loaded_data = json_parse(_data_json);
			if (is_struct(_loaded_data) && struct_exists(_loaded_data, "type") )
			{
				var _type = string_upper(_loaded_data.type);
				if (!struct_exists(_temp_data_pool, _type) ) { _temp_data_pool[$ _type] = []; }
				struct_remove(_loaded_data, "type");

				array_push(_temp_data_pool[$ _type], _loaded_data);
			}
			else 
			{
				__mall_alert($"File '{_data_file_path}' has no valid 'type' field.");
			}
		}
	}
	
	#endregion
	
	#region PROCESS_DATA_IN_ORDER
	var _order_length = array_length(__process_order);
	for (var i = 0; i < _order_length; i++) 
	{
		var _current_type = __process_order[i];
		
		if (!struct_exists(_temp_data_pool, _current_type) ) continue;
		
		var _data_array = _temp_data_pool[$ _current_type];
		var _data_array_length = array_length(_data_array);
		for (var j = 0; j < _data_array_length; j++) 
		{
			var _data_struct = _data_array[j];
			
			// AI and BATTLE files are consumed as full payloads.
			if (_current_type == "AI") 
			{
				mall_create_ai_from_data(_data_struct);
				continue;
			}
			else if (_current_type == "BATTLE")
			{
				mall_create_battle_from_data(_data_struct);
				continue;
			}	            
			
			var _keys = struct_get_names(_data_struct);
			var _keys_length = array_length(_keys);

			for (var k = 0; k < _keys_length; k++) 
			{
				var _key = _keys[k];
				var _entry_data = _data_struct[$ _key];
				
				switch (_current_type) {
					case "STATS":
						mall_create_stat_from_data(_key, _entry_data);   
						
						break;

					case "ITEMS":
						mall_create_item_from_data(_key, _entry_data); 
						
						break;

					case "SLOTS":
						mall_create_slot_from_data(_key, _entry_data);   
						
						break;

					case "STATES":
						mall_create_state_from_data(_key, _entry_data);  
						
						break;

					case "EFFECTS":
						mall_create_effect_from_data(_key, _entry_data); 
						
						break;

					case "COMMANDS":
						mall_create_command_from_data(_key, _entry_data);
						
						break;

					case "ENTITIES":
						mall_create_entity_template(_key, _entry_data); 
						
						break;
						
					case "GROUPS":	
						mall_create_group_from_data(_key, _entry_data); 
						
						break;
						
						
					case "BAGS":    
						mall_create_bag_from_data(_key, _entry_data);
						
						break;
						
				}
			}
		}
	}
	
	#endregion
	
	#region REBUILD_KEY_CACHES
	__Systemall.__stats_keys		= struct_get_names(__Systemall.__stats);
	__Systemall.__items_keys		= struct_get_names(__Systemall.__items);
	__Systemall.__slots_keys		= struct_get_names(__Systemall.__slots);
	__Systemall.__states_keys		= struct_get_names(__Systemall.__states);
	__Systemall.__bags_keys			= struct_get_names(__Systemall.__bags);
	__Systemall.__shops_keys		= struct_get_names(__Systemall.__shops);
	__Systemall.__groups_keys		= struct_get_names(__Systemall.__groups);
	__Systemall.__entities_keys		= struct_get_names(__Systemall.__entities);
	__Systemall.__commands_keys		= struct_get_names(__Systemall.__commands);
	__Systemall.__effects_keys		= struct_get_names(__Systemall.__effects);
	__Systemall.__types_keys		= struct_get_names(__Systemall.__types);
	__Systemall.__battle_keys		= struct_get_names(__Systemall.__battle.encounters);
	__Systemall.__ai_keys			= struct_get_names(__Systemall.__ai_packages);
	
	#endregion
	
	// Initialize default animation curves.
	__mall_init_curves();
	
	__mall_alert("JSON database load completed.");
}

/// @desc Resets all runtime databases and caches inside __Systemall.
function mall_system_cleanup()
{
	var _mall = static_get(__Systemall);
	var _keys = struct_get_names(_mall);
	var _count = array_length(_keys);

	for (var i = 0; i < _count; i++)
	{
		var _key = _keys[i];
		var _value = _mall[$ _key];

		if (_key == "__battle")
		{
			// Preserve expected battle payload shape.
			_mall[$ _key] = { encounters: {} };
			continue;
		}

		if (is_struct(_value))
		{
			_mall[$ _key] = {};
		}
		else if (is_array(_value))
		{
			_mall[$ _key] = [];
		}
		else
		{
			_mall[$ _key] = undefined;
		}
	}
}

// Initialize statics

// -- CORE --
script_execute(__Systemall);
script_execute(Mall);
script_execute(MallBehavior);
script_execute(MallIterator);

// -- Core Data Types --
script_execute(MallStat);
script_execute(MallSlot);
script_execute(MallState);
script_execute(MallResult);