/// @desc Creates AI templates (rules and packages) from data.
/// @param {Struct} data Struct containing AI data, including reusable rules and packages.
function mall_create_ai_from_data(_data)
{
	/// @ignore
	static __rules = function(_key, _values) 
	{
		mall_create_ai_rule_from_data(_key, _values);
	};

	/// @ignore
	static __packages = function(_key, _values) 
	{
		mall_create_ai_package_from_data(_key, _values);
	};

	// Validation.
	if (!__mall_validate_registry_args("mall_create_ai_from_data", undefined, _data, undefined, "AI", false) ) return;

	// Load reusable rules.
	if (struct_exists(_data, "rules") )
	{
		var _rules = _data[$ "rules"];
		struct_foreach(_rules, __rules);
	}
	
	// Load AI packages.
	if (struct_exists(_data, "packages") )
	{
		var _packages = _data[$ "packages"];
		struct_foreach(_packages, __packages);
	}
}

/// @desc Creates and registers an AI rule template from data.
/// @param {String} key AI rule key.
/// @param {Struct} data Rule payload.
function mall_create_ai_rule_from_data(_key, _data)
{
	__mall_create_ai_template_from_data(_key, _data, false);
}

/// @desc Creates and registers an AI package template from data.
/// @param {String} key AI package key.
/// @param {Struct} data Package payload.
function mall_create_ai_package_from_data(_key, _data)
{
	__mall_create_ai_template_from_data(_key, _data, true);
}

/// @ignore
/// @desc Internal helper to build and store an AI template.
/// @param {String} key AI key.
/// @param {Struct} data Rule/package payload.
/// @param {Bool} is_package True for package templates.
function __mall_create_ai_template_from_data(_key, _data, _is_package)
{
	var _caller_name = _is_package ? "mall_create_ai_package_from_data" : "mall_create_ai_rule_from_data";
	var _exists_func = _is_package ? mall_ai_package_exists : mall_ai_rule_exists;
	var _label = _is_package ? "AI package" : "AI rule";

	if (!__mall_validate_registry_args(_caller_name, _key, _data, _exists_func, _label) ) return;

	var _template = (new MallAI(_key, _is_package) ).FromData(_data);
	if (_is_package)
	{
		__Systemall.__ai_packages[$ _key] = _template;

		if (!array_contains(__Systemall.__ai_keys, _key) )
		{
			array_push(__Systemall.__ai_keys, _key);
		}
	}
	else
	{
		__Systemall.__ai_rules[$ _key] = _template;
	}
}

/// @desc Returns an AI package template by key.
/// @param {String} key AI package key.
/// @return {Struct.MallAI|Undefined}
function mall_get_ai_package(_key)
{
	if (!mall_ai_package_exists(_key) )
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
	if (!mall_ai_rule_exists(_key) )
	{
		__mall_error($"AI rule '{_key}' does not exist.");
		return undefined;
	}

	return (__Systemall.__ai_rules[$ _key] );
}

/// @desc Checks whether an AI rule template exists.
/// @param {String} key AI rule key.
function mall_ai_rule_exists(_key)
{
	return struct_exists(__Systemall.__ai_rules, _key);
}

/// @desc Checks whether an AI package template exists.
/// @param {String} key AI package key.
function mall_ai_package_exists(_key)
{
	return struct_exists(__Systemall.__ai_packages, _key);
}