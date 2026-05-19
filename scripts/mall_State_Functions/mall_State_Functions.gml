/// @desc Creates a state template from data and adds it to the database.
/// @param {String} key State key (for example "STATE_POISON").
/// @param {Struct} data Data struct read from JSON.
function mall_create_state_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_state_from_data", _key, _data, mall_exists_state, "State")) return;
	
	var _state = (new MallState(_key) ).FromData(_data);
	
	__Systemall.__states[$ _key] = _state;
	array_push(__Systemall.__states_keys, _key);
	
	// Register the state under its type category.
	mall_create_type(_state.state_type, _key);
}

/// @desc Creates a state at runtime.
/// @param {String} key State key (for example "STATE_POISON").
/// @param {Struct.MallState} component MallState instance.
function mall_create_state(_key, _component)
{
	if (mall_exists_state(_key) )
	{
		__mall_alert($"State '{_key}' already exists. Duplicate creation was skipped.");
		return;
	}
	
	__Systemall.__states[$ _key] = _component;
	array_push(__Systemall.__states_keys, _key);
	
	// Register the state under its type category.
	mall_create_type(_component.state_type, _key);
}

/// @desc Returns a state template by key.
/// @param {String} key State key.
/// @return {Struct.MallState}
function mall_get_state(_key) 
{ 
	return (__Systemall.__states[$ _key]); 
}

/// @desc Checks whether a state exists in the database.
/// @param {String} key State key.
/// @return {Bool}
function mall_exists_state(_key) 
{
	return (struct_exists(__Systemall.__states, _key)); 
}

/// @desc Returns an array with all registered state keys.
/// @return {Array<String>}
function mall_get_state_keys() 
{
	return (__Systemall.__states_keys);
}