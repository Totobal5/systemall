/// @desc Adds a new runtime type entry.
/// @param {String} key Type key.
/// @param {Any} value Value to register for the type.
function mall_create_type(_key, _value)
{
	_key = __mall_type_normalize_key(_key);
	if (is_undefined(_key) )
	{
		__mall_error("mall_create_type expected a non-empty string key.");
		exit;
	}

	// If the type already exists, we add the value to the existing bucket if it's not a duplicate.
	if (mall_exists_type(_key) )
	{
		var _bucket = __Systemall.__types[$ _key];
		if (!array_contains(_bucket, _value) ) { array_push(_bucket, _value); }
	}
	// Create a new type bucket and index key cache.
	else
	{
		__Systemall.__types[$ _key] = [_value];
		array_push(__Systemall.__types_keys, _key);
	}
}

/// @desc Checks whether a type exists.
/// @param {String} key Type key.
/// @return {Bool}
function mall_exists_type(_key)
{
	_key = __mall_type_normalize_key(_key);
	if (is_undefined(_key)) return false;

	return struct_exists(__Systemall.__types, _key);
}

/// @desc Returns values for a specific type key, or undefined when missing.
/// @param {String} key Type key.
/// @return {Any}
function mall_get_type(_key)
{
	_key = __mall_type_normalize_key(_key);
	if (is_undefined(_key)) return undefined;

	return (__Systemall.__types[$ _key]);	
}

/// @ignore
/// @desc Normalizes type keys to a canonical uppercase string.
/// @param {Any} key Raw type key value.
/// @return {String|Undefined}
function __mall_type_normalize_key(_key)
{
	if (!is_string(_key)) return undefined;

	var _normalized = string_trim(_key);
	if (_normalized == "") return undefined;

	return string_upper(_normalized);
}