/// @ignore Core library semantic version.
#macro __MALL_VERSION		"4.1.0"
/// @ignore Build/version suffix used in save payload metadata.
#macro __MALL_VERSION_MINE	__MALL_VERSION+"::1.0.0"
/// @ignore Enables Systemall trace logging.
#macro __MALL_ALERT			true
/// @ignore Enables Systemall error logging.
#macro __MALL_ERROR			true
/// @ignore Aborts execution on critical Systemall errors. Keep false when running the test-suite.
#macro __MALL_STRICT_MODE	false
/// @ignore Enables additional runtime safety checks.
#macro __MALL_SAFETY		true

/// @ignore Default args assigned to components if their data does not specify them.
#macro __MALL_DEFAULT_ARGS	{ /* arg_name: default_value */ }
/// @ignore Default vars assigned to components if their data does not specify them.
#macro __MALL_DEFAULT_VARS	{ /* vars_name: default_value */ }
/// @ignore Default type assigned to components if their data does not specify one.
#macro __MALL_TYPE_DEFAULT ["No-Type"]

/// @ignore Default state assigned to entities if their data does not specify one.
#macro __MALL_STATE_DEFAULT_TYPE "AILMENT"

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
	/// @ignore List of registered command keys for caching and iteration.
	static __commands_keys = [];	
	
	/// @ignore Effects database.
	static __effects = {};
	/// @ignore
	static __effects_keys = [];
	
	/// @ignore Runtime type database.
	static __types = { /* type: [value1, value2, value3] */ };
	/// @ignore
	static __types_keys = [];
	/// @ignore Fast runtime type database: type -> { value: true }.
	static __types_fast = {};
	/// @ignore Type hierarchy graph: child -> [parents].
	static __types_hierarchy = {};
	/// @ignore Cached ancestors graph: tag -> { ancestor: true }.
	static __types_ancestors_fast = {};
	/// @ignore Cached descendants graph: tag -> { descendant: true }.
	static __types_descendants_fast = {};
	/// @ignore Mutex graph: tag -> { incompatible_tag: true }.
	static __types_mutex = {};
	
	/// @ignore Battle encounter database.
	static __battle_manager = undefined;
	/// @ignore
	static __battle = { encounters: {} };
	/// @ignore
	static __battle_keys = [];
	
	/// @ignore
	static __ai_packages = {};
	/// @ignore
	static __ai_packages_keys = [];

	/// @ignore
	static __ai_rules = {};
	/// @ignore
	static __ai_rules_keys = [];
	
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
	static __process_order = ["STATS", "ITEMS", "SLOTS", "STATES", "EFFECTS", "COMMANDS", "AI", "ENTITIES", "GROUPS", "BAGS", "BATTLE"];
	/// @ignore
	static __is_absolute_path = function(_path)
	{
		if (!is_string(_path)) return false;

		var _len = string_length(_path);
		if (_len <= 0) return false;

		var _c1 = string_char_at(_path, 1);
		if (_c1 == "/" || _c1 == "\\") return true;

		if (_len >= 2 && string_char_at(_path, 2) == ":") return true;

		return false;
	};
	/// @ignore
	static __entry_factories = {
		STATS:		mall_create_stat_from_data,
		ITEMS:		mall_create_item_from_data,
		SLOTS:		mall_create_slot_from_data,
		STATES:		mall_create_state_from_data,
		EFFECTS:	mall_create_effect_from_data,
		COMMANDS:	mall_create_command_from_data,
		ENTITIES:	mall_create_entity_template,
		GROUPS:		mall_create_group_from_data,
		BAGS:		mall_create_bag_from_data
	};

	var _files_loaded = 0;
	var _files_failed = 0;
	var _entries_created = 0;
	var _entries_failed = 0;
	var _master_base_path = filename_path(_master_file_path);

	__mall_alert($"mall_init started with master '{_master_file_path}'.");

	// Ensure built-in core callbacks are available before loading data files.
	__mall_register_core_events_commands();
	
	#region COLLECT_ALL_DATA

	if (!file_exists(_master_file_path) )
	{
		__mall_error($"Master file not found: '{_master_file_path}'.");
		exit;
	}

	// Catch any errors during master file loading and parsing to prevent silent failures and provide feedback.
	try 
	{
		// Read master file content.
		var _master_file = file_text_open_read(_master_file_path);
		var _master_json = "";
		while (!file_text_eof(_master_file) ) { _master_json += file_text_readln(_master_file); }
		file_text_close(_master_file);
		
		// Parse master JSON content.
		var _master_data = json_parse(_master_json);
		if (!is_struct(_master_data) ) 
		{
			__mall_error("Master file is not valid JSON.");
			exit;
		}
	}
	catch (_error)
	{
		__mall_error("An error occurred while loading the master file:");
		__mall_error(string(_error) );
		exit;
	}

	// Store master data for reference and debugging.
	__Systemall.__master = _master_data;
	
	// Struct grouping loaded payloads by type.
	var _temp_data_pool = {};
	var _categories = struct_get_names(_master_data);
	var _categories_size = array_length(_categories);
	for (var i = 0; i < _categories_size; i++)
	{
		var _category_name = _categories[i];
		var _file_paths = _master_data[$ _category_name];
		if (!is_array(_file_paths) )
		{
			_files_failed++;
			__mall_error($"Category '{_category_name}' must be an array of file paths.");
			continue;
		}
		var _file_paths_size = array_length(_file_paths);
		__mall_alert($"Collecting category '{_category_name}' with {_file_paths_size} file(s).");

		// Read each file listed in the master entry.
		for (var j = 0; j < _file_paths_size; j++)
		{
			var _data_file_path = _file_paths[j];
			var _resolved_data_file_path = _data_file_path;

			if (!file_exists(_resolved_data_file_path) && !__is_absolute_path(_data_file_path) )
			{
				_resolved_data_file_path = _master_base_path + _data_file_path;
				if (file_exists(_resolved_data_file_path))
				{
					__mall_alert($"Resolved relative file '{_data_file_path}' to '{_resolved_data_file_path}'.");
				}
			}

			if (!file_exists(_resolved_data_file_path) ) 
			{
				_files_failed++;
				__mall_error($"File not found '{_data_file_path}' (category '{_category_name}').");
				__mall_alert($"File not found '{_data_file_path}'.");
				continue;
			}

			try
			{
				var _data_file = file_text_open_read(_resolved_data_file_path);
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
					_files_loaded++;
					__mall_alert($"Loaded file '{_resolved_data_file_path}' as type '{_type}'.");
				}
				else 
				{
					_files_failed++;
					__mall_error($"File '{_resolved_data_file_path}' has no valid 'type' field.");
					__mall_alert($"File '{_resolved_data_file_path}' has no valid 'type' field.");
				}
			}
			catch (_file_error)
			{
				_files_failed++;
				__mall_error($"Failed parsing '{_resolved_data_file_path}': {string(_file_error)}");
				continue;
			}
		}
	}
	__mall_alert($"Data collection completed. Loaded files={_files_loaded}, failed files={_files_failed}.");
	
	#endregion
	
	#region PROCESS_DATA_IN_ORDER
	var _order_length = array_length(__process_order);
	for (var i = 0; i < _order_length; i++) 
	{
		var _current_type = __process_order[i];
		
		if (!struct_exists(_temp_data_pool, _current_type) ) continue;
		
		var _data_array = _temp_data_pool[$ _current_type];
		var _data_array_length = array_length(_data_array);
		__mall_alert($"Processing type '{_current_type}' with {_data_array_length} block(s).");
		for (var j = 0; j < _data_array_length; j++) 
		{
			var _data_struct = _data_array[j];
			
			// AI and BATTLE files are consumed as full payloads.
			if (_current_type == "AI")
			{
				mall_create_ai_from_data(_data_struct);
				_entries_created++;
				__mall_alert($"Created AI block #{j+1}.");
				continue;
			}
			else if (_current_type == "BATTLE")
			{
				mall_create_battle_from_data(_data_struct);
				_entries_created++;
				__mall_alert($"Created BATTLE block #{j+1}.");
				continue;
			}	            

			if (!struct_exists(__entry_factories, _current_type) )
			{
				_entries_failed++;
				__mall_error($"No entry factory for type '{_current_type}'.");
				continue;
			}

			var _entry_factory = __entry_factories[$ _current_type];
			
			var _keys = struct_get_names(_data_struct);
			var _keys_length = array_length(_keys);

			for (var k = 0; k < _keys_length; k++) 
			{
				var _key = _keys[k];
				var _entry_data = _data_struct[$ _key];

				if (is_undefined(_entry_data))
				{
					_entries_failed++;
					__mall_error($"Type '{_current_type}' has undefined data for key '{_key}'.");
					continue;
				}

				try
				{
					_entry_factory(_key, _entry_data);
					_entries_created++;
					__mall_alert($"Created {_current_type} '{_key}'.");
				}
				catch (_entry_error)
				{
					_entries_failed++;
					__mall_error($"Failed creating {_current_type} '{_key}': {string(_entry_error)}");
				}
			}
		}
	}
	__mall_alert($"Data processing completed. Created entries={_entries_created}, failed entries={_entries_failed}.");
	
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

if (debug_mode)
{
	global.__systemall_debug = static_get(__Systemall);
}