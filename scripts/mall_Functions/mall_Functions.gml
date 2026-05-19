#region SAVE / LOAD API

/// @desc Saves the complete game state to a file.
/// @param {String} filename Save file path (for example "savegame1.sav").
/// @returns {Bool} True when the save operation succeeds.
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
		
		// --- Save entity instances ---
		var _instances = __Systemall.__instances;
		var _instance_keys = struct_get_names(_instances);
		var _instance_count = array_length(_instance_keys);
		for (var i = 0; i < _instance_count; i++)
		{
			var _inst = _instances[$ _instance_keys[i]];
			var _inst_export = _inst[$ "Export"];
			if (is_callable(_inst_export)) array_push(_save_data.instances, _inst_export());
		}
		
		// --- Save persistent bags ---
		var _persistent_bags = __Systemall.__persistent_bags;
		var _persistent_bag_count = array_length(_persistent_bags);
		for (var i = 0; i < _persistent_bag_count; i++)
		{
			var _bag_key = _persistent_bags[i];
			if (mall_bag_exists(_bag_key))
			{
				var _bag = mall_get_bag(_bag_key);
				var _bag_export = _bag[$ "Export"];
				if (is_callable(_bag_export))
				{
					_save_data.bags[$ _bag_key] = _bag_export();
				}
			}
		}
		
		// --- Save persistent groups ---
		var _persistent_groups = __Systemall.__persistent_groups;
		var _persistent_group_count = array_length(_persistent_groups);
		for (var i = 0; i < _persistent_group_count; i++)
		{
			var _group_key = _persistent_groups[i];
			if (mall_exists_group(_group_key))
			{
				var _group = mall_get_group(_group_key);
				var _group_export = _group[$ "Export"];
				if (is_callable(_group_export)) _save_data.groups[$ _group_key] = _group_export();
			}
		}
		
		// --- Write JSON payload ---
		var _json_string = json_stringify(_save_data);
		
		var _file = file_text_open_write(_filename);
		file_text_write_string(_file, _json_string);
		file_text_close(_file);
		
		__mall_alert($"Save completed successfully: '{_filename}'.");
		return true;
	}
	catch (_ex)
	{
		__mall_error($"Save failed: {_ex}");
		return false;
	}
}

/// @desc Loads the complete game state from a file.
/// @param {String} filename Save file path.
/// @returns {Bool} True when the load operation succeeds.
function mall_load_system(_filename)
{
	if (!file_exists(_filename))
	{
		__mall_alert($"Save file not found: '{_filename}'.");
		return false;
	}
	
	try
	{
		// --- Read and parse save file ---
		var _load_file = file_text_open_read(_filename);
		var _load_json = "";
		while (!file_text_eof(_load_file) ) { _load_json += file_text_readln(_load_file); }
		file_text_close(_load_file);

		var _load_data = json_parse(_load_json);
		if (!is_struct(_load_data))
		{
			__mall_error($"Load failed: save file is not valid JSON '{_filename}'.");
			mall_broadcast_post("ON_GAME_LOADED", { success: false });
			return false;
		}

		var _save_version = _load_data[$ "version"] ?? "0.0.0";
		if (_save_version != __MALL_VERSION_MINE)
		{
			__mall_alert($"Load version mismatch: save='{_save_version}', runtime='{__MALL_VERSION_MINE}'.");
		}
		
		// --- Clear current runtime state ---
		__Systemall.__instances = {};
		var _persistent_groups = __Systemall.__persistent_groups;
		var _persistent_groups_count = array_length(_persistent_groups);
		for (var i = 0; i < _persistent_groups_count; i++)
		{
			var _group_key = _persistent_groups[i];
			if (mall_exists_group(_group_key) )
			{
				var _group = mall_get_group(_group_key);
				if (!is_undefined(_group)) _group.Clean();
			}
		}

		// --- Load entity instances ---
		var _saved_instances = _load_data.instances ?? [];
		var _saved_instances_count = array_length(_saved_instances);
		for (var i = 0; i < _saved_instances_count; i++)
		{
			var _inst_data = _saved_instances[i];
			var _template_key = _inst_data.template_key;
			
			// Create a new instance and register it in runtime storage.
			var _new_inst = mall_entity_create_instance(_template_key, 1);
			
			if (is_undefined(_new_inst))
			{
				__mall_alert($"mall_load_system: skipping saved entity \u2014 template '{_template_key}' is no longer registered.");
				continue;
			}
			
			// Import saved state.
			_new_inst.Import(_inst_data);
			__Systemall.__instances[$ _new_inst.id] = _new_inst;
		}
		
		// --- Load persistent groups ---
		// This must happen after loading instances so entity references exist.
		if (struct_exists(_load_data, "groups"))
		{
			var _saved_groups = _load_data.groups;
			var _group_keys = struct_get_names(_saved_groups);
			var _group_keys_count = array_length(_group_keys);
			for (var i = 0; i < _group_keys_count; i++)
			{
				var _key = _group_keys[i];
				if (mall_exists_group(_key) )
				{
					var _group = mall_get_group(_key);
					_group.Import(_saved_groups[$ _key]);
				}
			}
		}
		
		// --- Load persistent bags ---
		if (struct_exists(_load_data, "bags"))
		{
			var _saved_bags = _load_data.bags;
			var _bag_keys = struct_get_names(_saved_bags);
			var _bag_keys_count = array_length(_bag_keys);
			for (var i = 0; i < _bag_keys_count; i++)
			{
				var _key = _bag_keys[i];
				if (mall_bag_exists(_key) ) 
				{
					var _bag = mall_get_bag(_key);
					_bag.Import(_saved_bags[$ _key]);
				}
			}
		}
		
		// --- Notify the rest of the game ---
		mall_broadcast_post("ON_GAME_LOADED", { success: true });
		__mall_alert("Game loaded successfully.");
		return true;
	}
	catch (_ex)
	{
		__mall_error($"Load failed: {_ex}");
		mall_broadcast_post("ON_GAME_LOADED", { success: false });
		return false;
	}
}

/// @desc Returns a read-only debug snapshot for runtime diagnostics.
/// @returns {Struct}
function mall_get_debug_info()
{
	var _instance_count = array_length(struct_get_names(__Systemall.__instances));
	var _group_count = array_length(__Systemall.__groups_keys);
	var _bag_count = array_length(__Systemall.__bags_keys);
	var _battle_manager = __Systemall.__battle_manager;
	var _battle_active = is_struct(_battle_manager) && (_battle_manager[$ "is_battle_active"] ?? false);

	return {
		version: __MALL_VERSION_MINE,
		instances: _instance_count,
		groups: _group_count,
		bags: _bag_count,
		battle_active: _battle_active,
		persistent_groups: variable_clone(__Systemall.__persistent_groups),
		persistent_bags: variable_clone(__Systemall.__persistent_bags)
	};
}

#endregion

#region PRIVATE

/// @ignore
/// @desc Validates common _from_data arguments and duplicate keys.
/// @param {String} _fn_name Function name for error context.
/// @param {String|undefined} [_key=undefined] Candidate registry key.
/// @param {Struct|undefined} [_data=undefined] Candidate payload.
/// @param {Function|undefined} [_exists_fn=undefined] Optional exists checker callable.
/// @param {String} [_entry_name="Entry"] Entity label used in duplicate alerts.
/// @param {Bool} [_requires_key=true] Whether key validation is required.
/// @param {Bool} [_requires_data=true] Whether payload validation is required.
/// @returns {Bool}
function __mall_validate_registry_args(_fn_name, _key = undefined, _data = undefined, _exists_fn = undefined, _entry_name = "Entry", _requires_key = true, _requires_data = true)
{
	if (_requires_key && (!is_string(_key) || _key == ""))
	{
		__mall_error($"{_fn_name} expected a non-empty string key.");
		return false;
	}

	if (_requires_data && !is_struct(_data))
	{
		if (_requires_key)
		{
			__mall_error($"{_fn_name} expected struct data for key '{_key}'.");
		}
		else
		{
			__mall_error($"{_fn_name} expected a struct payload.");
		}
		return false;
	}

	if (_requires_key && is_callable(_exists_fn) && _exists_fn(_key))
	{
		__mall_alert($"{_entry_name} '{_key}' already exists. Duplicate creation was skipped.");
		return false;
	}

	return true;
}

/// @ignore
/// @desc Logs a system trace message when tracing is enabled.
/// @param {String} message Message to log.
function __mall_alert(_msg)
{
	static _origin = "unknown:0";
	if (__MALL_ALERT)
	{
		var _stack = debug_get_callstack(2);
		if (is_array(_stack))
		{
			if (array_length(_stack) > 1) _origin = _stack[1];
			else if (array_length(_stack) > 0) _origin = _stack[0];
		}
		// Remove common GML prefixes to improve readability of debug messages.
		if (string_starts_with(_origin, "gml_GlobalScript_") ) { _origin = string_delete(_origin, 1, 17); }
		if (string_starts_with(_origin, "gml_Object_") ) { _origin = string_delete(_origin, 1, 11); }

		show_debug_message($"Systemall Alert:: {_origin}: {_msg}");
	}
}

/// @ignore
/// @desc Logs a system error and optionally aborts execution in strict mode.
/// @param {String} message Message to log.
function __mall_error(_msg)
{
	static _origin = "unknown:0";
	if (__MALL_ERROR)
	{
		var _stack = debug_get_callstack(2);
		if (is_array(_stack) )
		{
			if (array_length(_stack) > 1) _origin = _stack[1];
			else if (array_length(_stack) > 0) _origin = _stack[0];
		}

		// Remove common GML prefixes to improve readability of debug messages.
		if (string_starts_with(_origin, "gml_GlobalScript_") ) { _origin = string_delete(_origin, 1, 17); }
		if (string_starts_with(_origin, "gml_Object_") ) { _origin = string_delete(_origin, 1, 11); }
		
		show_debug_message($"Systemall Error:: {_origin}: {_msg}");

		// If strict mode is enabled crash the game with an error message to avoid silent failures.
		if (__MALL_STRICT_MODE) { show_error($"Systemall Fatal Error:: {_origin}: {_msg}", true); }
	}
}

/// @ignore
/// @desc Initializes default system animation curves.
function __mall_init_curves()
{
	// --- LINEAR CURVE ---
	var _linear = animcurve_create();
	_linear.name = "linear";
	var _linear_channel = animcurve_channel_new();
	_linear_channel.name = "linear";
	_linear_channel.type = animcurvetype_linear;
	var _linear_points = array_create(2);
	_linear_points[0] = animcurve_point_new();
	_linear_points[0].posx = 0;
	_linear_points[0].value = 0;
	_linear_points[1] = animcurve_point_new();
	_linear_points[1].posx = 1;
	_linear_points[1].value = 1;
	_linear_channel.points = _linear_points;
	_linear.channels = [_linear_channel];
	mall_add_asset("linear", _linear);
	
	// --- EXPONENTIAL CURVE (x^2) ---
	var _exponential = animcurve_create();
	_exponential.name = "exponential";
	var _exp_channel = animcurve_channel_new();
	_exp_channel.name = "exponential";
	_exp_channel.type = animcurvetype_catmullrom;
	_exp_channel.iterations = 16;
	var _exp_points = array_create(5);
	_exp_points[0] = animcurve_point_new();
	_exp_points[0].posx = 0;
	_exp_points[0].value = 0;
	_exp_points[1] = animcurve_point_new();
	_exp_points[1].posx = 0.25;
	_exp_points[1].value = 0.0625;
	_exp_points[2] = animcurve_point_new();
	_exp_points[2].posx = 0.5;
	_exp_points[2].value = 0.25;
	_exp_points[3] = animcurve_point_new();
	_exp_points[3].posx = 0.75;
	_exp_points[3].value = 0.5625;
	_exp_points[4] = animcurve_point_new();
	_exp_points[4].posx = 1;
	_exp_points[4].value = 1;
	_exp_channel.points = _exp_points;
	_exponential.channels = [_exp_channel];
	mall_add_asset("exponential", _exponential);
	
	// --- EASE_OUT CURVE ---
	var _ease_out = animcurve_create();
	_ease_out.name = "ease_out";
	var _ease_channel = animcurve_channel_new();
	_ease_channel.name = "ease_out";
	_ease_channel.type = animcurvetype_catmullrom;
	_ease_channel.iterations = 16;
	var _ease_points = array_create(4);
	_ease_points[0] = animcurve_point_new();
	_ease_points[0].posx = 0;
	_ease_points[0].value = 0;
	_ease_points[1] = animcurve_point_new();
	_ease_points[1].posx = 0.33;
	_ease_points[1].value = 0.8;
	_ease_points[2] = animcurve_point_new();
	_ease_points[2].posx = 0.66;
	_ease_points[2].value = 0.95;
	_ease_points[3] = animcurve_point_new();
	_ease_points[3].posx = 1;
	_ease_points[3].value = 1;
	_ease_channel.points = _ease_points;
	_ease_out.channels = [_ease_channel];
	mall_add_asset("ease_out", _ease_out);
	
	// --- SQUARE CURVE (x^1.5) ---
	var _square = animcurve_create();
	_square.name = "square";
	var _square_channel = animcurve_channel_new();
	_square_channel.name = "square";
	_square_channel.type = animcurvetype_catmullrom;
	_square_channel.iterations = 16;
	var _square_points = array_create(5);
	_square_points[0] = animcurve_point_new();
	_square_points[0].posx = 0;
	_square_points[0].value = 0;
	_square_points[1] = animcurve_point_new();
	_square_points[1].posx = 0.25;
	_square_points[1].value = 0.125;
	_square_points[2] = animcurve_point_new();
	_square_points[2].posx = 0.5;
	_square_points[2].value = 0.35;
	_square_points[3] = animcurve_point_new();
	_square_points[3].posx = 0.75;
	_square_points[3].value = 0.65;
	_square_points[4] = animcurve_point_new();
	_square_points[4].posx = 1;
	_square_points[4].value = 1;
	_square_channel.points = _square_points;
	_square.channels = [_square_channel];
	mall_add_asset("square", _square);
}

#endregion