/// @desc Registers an effect template.
/// @param {String} key Unique effect key.
/// @param {Struct.MallEffect} template Effect template.
function mall_create_effect(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_effect expected a non-empty string key.");
		return;
	}

	if (mall_exists_effect(_key) ) 
	{ 
		__mall_alert($"Effect '{_key}' already exists and will be overwritten."); 
	}
	
	__Systemall.__effects[$ _key] = _template;
	array_push(__Systemall.__effects_keys, _key);
}

/// @desc Creates an effect template from data and registers it in the effect database.
/// @param {String} key Unique effect key.
/// @param {Struct} data Raw effect data.
function mall_create_effect_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_effect_from_data", _key, _data, mall_exists_effect, "Effect")) return;
	
	var _effect = (new MallEffect(_key) ).Import(_data);
	mall_create_effect(_key, _effect);
} 

/// @desc Gets an effect template by key. Returns undefined if not found.
/// @param {String} key Effect key.
/// @returns {Struct.MallEffect|undefined}
function mall_get_effect(_key)
{
	return struct_get(__Systemall.__effects, _key);
}

/// @desc Returns an array with all registered effect keys.
/// @returns {Array<String>}
function mall_get_effect_keys()
{
	return (__Systemall.__effects_keys);
}

/// @desc Checks whether an effect template exists.
/// @param {String} key Effect template key.
/// @returns {Bool} True when the effect exists in the effect database.
function mall_exists_effect(_key)
{
	return (struct_exists(__Systemall.__effects, _key) );
}