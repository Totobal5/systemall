/// @desc Registers a callable under an event key.
/// @param {String|Real} key_or_hash Event key or hash.
/// @param {Function} function Callable to register.
function mall_create_event(_key_or_hash, _fn)
{
	if (!is_string(_key_or_hash) && !is_real(_key_or_hash) )
	{
		__mall_error("mall_create_event expected a string key or a hash.");
		return;
	}

	if (!is_callable(_fn) )
	{
		__mall_error($"mall_create_event expected a callable for key '{_key_or_hash}'.");
		return;
	}

	if (mall_exists_event(_key_or_hash) ) { __mall_alert($"Event '{_key_or_hash}' already exists and will be overwritten."); }

	if (is_string(_key_or_hash) )
	{
		struct_set(__Systemall.__events, _key_or_hash, _fn);
	}
	else
	{
		struct_set_from_hash(__Systemall.__events, _key_or_hash, _fn);
	}
}

/// @desc Gets an event callback by key. Returns no-op function if not found.
/// @param {String|Real} key_or_hash Event key or hash.
/// @return {Function}
function mall_get_event(_key_or_hash)
{
	static __default = function() {};
	if (!is_string(_key_or_hash) && !is_real(_key_or_hash) )
	{
		__mall_error("mall_get_event expected a string key or a hash.");
		return __default;
	}
	
	if (is_string(_key_or_hash) )
	{
		return struct_get(__Systemall.__events, _key_or_hash) ?? __default;
	}
	else
	{
		return struct_get_from_hash(__Systemall.__events, _key_or_hash) ?? __default;	
	}
}

/// @desc Helper that returns an event callback or a default callable that returns true.
/// @param {String|Real} key_or_hash Event key or hash.
/// @return {Function}
function mall_get_event_check_true(_key_or_hash)
{
	static __default = function() {};
	if (!is_string(_key_or_hash) && !is_real(_key_or_hash) )
	{
		__mall_error("mall_get_event expected a string key or a hash.");
		return __default;
	}
	
	if (is_string(_key_or_hash) )
	{
		return struct_get(__Systemall.__events, _key_or_hash) ?? __default;
	}
	else
	{
		return struct_get_from_hash(__Systemall.__events, _key_or_hash) ?? __default;	
	}
}

/// @desc Helper that returns an event callback or a default callable that returns false.
/// @param {String|Real} key_or_hash Event key or hash.
/// @return {Function}
function mall_get_event_check_false(_key_or_hash)
{
	static __default = function() {};
	if (!is_string(_key_or_hash) && !is_real(_key_or_hash) )
	{
		__mall_error("mall_get_event expected a string key or a hash.");
		return __default;
	}
	
	if (is_string(_key_or_hash) )
	{
		return struct_get(__Systemall.__events, _key_or_hash) ?? __default;
	}
	else
	{
		return struct_get_from_hash(__Systemall.__events, _key_or_hash) ?? __default;	
	}
}

/// @desc Checks whether an event key exists.
/// @param {String|Real} key_or_hash Event key or hash.
/// @return {Bool}
function mall_exists_event(_key_or_hash)
{
	if (!is_string(_key_or_hash) && !is_real(_key_or_hash) )
	{
		__mall_error("mall_exists_event expected a string key or a hash.");
		return false;
	}

	if (is_string(_key_or_hash) )
	{
		return (struct_exists(__Systemall.__events, _key_or_hash) );
	}
	else
	{
		return (struct_exists_from_hash(__Systemall.__events, _key_or_hash) );
	}
}

#region PRIVATE

/// @ignore
/// @desc Helper that returns a level-up event or a default stat growth callable.
function __mall_get_event_stat_level_up(_key)
{
	static __default = function(_stat) { return _stat.base_value + (_stat.level * 2); };
	return struct_get(__Systemall.__events, _key) ?? __default;
}

#endregion