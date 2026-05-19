/// @desc Registers a callable under an event key.
/// @param {String} key Event key.
/// @param {Function} function Callable to register.
function mall_create_event(_key, _fn)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_event expected a non-empty string key.");
		return;
	}

	if (!is_callable(_fn) )
	{
		__mall_error($"mall_create_event expected a callable for key '{_key}'.");
		return;
	}

	if (mall_exists_event(_key) ) { __mall_alert($"Event '{_key}' already exists and will be overwritten."); }
	__Systemall.__events[$ _key] = _fn;
}

/// @desc Gets an event callback by key. Returns no-op function if not found.
/// @param {String} key Event key.
/// @return {Function}
function mall_get_event(_key)
{
	static __default = function() {};
	return (struct_get(__Systemall.__events, _key) ?? __default);
}

/// @desc Checks whether an event key exists.
/// @param {String} key Event key.
/// @return {Bool}
function mall_exists_event(_key)
{
	return (struct_exists(__Systemall.__events, _key) );
}

#region PRIVATE

/// @ignore
/// @desc Helper that returns an event callback or a default callable that returns true.
function __mall_get_event_check_true(_key)
{
	static __default = function() {return true; };
	return struct_get(__Systemall.__events, _key) ?? __default;
}

/// @ignore
/// @desc Helper that returns an event callback or a default callable that returns false.
function __mall_get_event_check_false(_key)
{
	static __default = function() {return false; }
	return struct_get(__Systemall.__events, _key) ?? __default;
}

/// @ignore
/// @desc Helper that returns a level-up event or a default stat growth callable.
function __mall_get_event_stat_level_up(_key)
{
	static __default = function(_stat) { return _stat.base_value + (_stat.level * 2); };
	return struct_get(__Systemall.__events, _key) ?? __default;
}

#endregion