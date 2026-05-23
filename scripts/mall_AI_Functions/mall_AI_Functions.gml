/// @desc Registers a ai package template.
/// @param {String} key Unique package key.
/// @param {Struct.MallAIPackage} template Package template.
function mall_create_ai_package(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_ai_package expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_ai_package expected a struct template child of MallAIPackage.");
		return false;
	}

	// No duplicates allowed.
	if (mall_exists_ai_package(_key) ) 
	{ 
		__mall_error($"AI package '{_key}' already exists and will be overwritten.");
		return false;
	}
	
	__Systemall.__ai_packages[$ _key] = _template;
	array_push(__Systemall.__ai_packages_keys, _key);

	return true;
}

/// @desc Creates and registers an AI package template from data.
/// @param {String} key AI package key.
/// @param {Struct} data Package payload.
function mall_create_ai_package_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_ai_package_from_data expected a import struct data.");
		return false;
	}

	var _template = (new MallAIPackage(_key) ).Import(_data);
	return (mall_create_ai_package(_key, _template) );
}

/// @desc Registers an AI rule template.
/// @param {String} key Unique rule key.
/// @param {Struct.MallAI} template Rule template.
function mall_create_ai_rule(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_ai_rule expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_ai_rule expected a struct template child of MallAI.");
		return false;
	}

	if (mall_exists_ai_rule(_key) ) 
	{ 
		__mall_error($"AI rule '{_key}' already exists and will be overwritten.");
		return false;
	}
	
	__Systemall.__ai_rules[$ _key] = _template;
	array_push(__Systemall.__ai_rules_keys, _key);

	return true;
}

/// @desc Creates and registers an AI rule template from data.
/// @param {String} key AI rule key.
/// @param {Struct} data Rule payload.
function mall_create_ai_rule_from_data(_key, _data)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_ai_rule_from_data expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_data) )
	{
		__mall_error("mall_create_ai_rule_from_data expected a import struct data.");
		return false;
	}

	var _template = (new MallAI(_key) ).Import(_data);
	return (mall_create_ai_rule(_key, _template) );
}

/// @desc Returns an AI package template by key.
/// @param {String} key AI package key.
/// @return {Struct.MallAIPackage|Undefined}
function mall_get_ai_package(_key)
{
	if (!mall_exists_ai_package(_key) )
	{
		__mall_error($"AI package '{_key}' does not exist.");
		return undefined;
	}

	return (__Systemall.__ai_packages[$ _key] );
}

/// @desc Returns an AI rule template by key.
/// @param {String} key AI rule key.
/// @return {Struct.MallAI|Undefined}
function mall_get_ai_rule(_key)
{
	if (!mall_exists_ai_rule(_key) )
	{
		__mall_error($"AI rule '{_key}' does not exist.");
		return undefined;
	}

	return (__Systemall.__ai_rules[$ _key] );
}

/// @desc Checks whether an AI package template exists.
/// @param {String} key AI package key.
function mall_exists_ai_package(_key)
{
	return struct_exists(__Systemall.__ai_packages, _key);
}

/// @desc Checks whether an AI rule template exists.
/// @param {String} key AI rule key.
function mall_exists_ai_rule(_key)
{
	return struct_exists(__Systemall.__ai_rules, _key);
}

/// @desc Returns an array with all registered AI package keys.
/// @returns {Array<String>}
function mall_get_ai_package_keys()
{
	return (__Systemall.__ai_packages_keys);
}

/// @desc Returns an array with all registered AI rule keys.
/// @returns {Array<String>}
function mall_get_ai_rule_keys()
{
	return (__Systemall.__ai_rules_keys);
}