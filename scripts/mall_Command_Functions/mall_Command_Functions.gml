/// @desc Creates a command template from data and registers it in the command database.
/// @param {String} key Unique command key.
/// @param {Struct} data Raw command data.
/// @returns {undefined}
function mall_create_command_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_command_from_data", _key, _data, mall_exists_command, "Command") ) return;

    var _command = (new MallCommand(_key) ).Import(_data);
    mall_create_command(_key, _command);
}

/// @desc Registers a command template.
/// @param {String} key Unique command key.
/// @param {Struct.MallCommand} template Command template.
function mall_create_command(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_command expected a non-empty string key.");
		return;
	}

	if (mall_exists_command(_key) ) 
	{ 
		__mall_alert($"Command '{_key}' already exists and will be overwritten."); 
	}
	
	__Systemall.__commands[$ _key] = _template;
	array_push(__Systemall.__commands_keys, _key);
}

/// @desc Gets a command template by key. Returns undefined if not found.
/// @param {String} key Command key.
/// @returns {Struct.MallCommand|undefined}
function mall_get_command(_key)
{
	return struct_get(__Systemall.__commands, _key);
}

/// @desc Returns an array with all registered command keys.
/// @returns {Array<String>}
function mall_get_command_keys()
{
	return (__Systemall.__commands_keys);
}

/// @desc Checks whether a command template exists.
/// @param {String} key Command template key.
/// @returns {Bool} True when the command exists in the command database.
function mall_exists_command(_key) 
{
	return (struct_exists(__Systemall.__commands, _key) );
}