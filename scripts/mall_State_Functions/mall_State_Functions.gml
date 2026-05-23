/// @desc Creates a state at runtime.
/// @param {String} key State key (for example "STATE_POISON").
/// @param {Struct.MallState} template MallState template.
function mall_create_state(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_state expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_state expected a struct template.");
		return false;
	}

	if (mall_exists_state(_key) ) 
	{ 
		__mall_error($"State '{_key}' already exists."); 
		return false;
	}
	
	__Systemall.__states[$ _key] = _template;
	array_push(__Systemall.__states_keys, _key);
	
	// Register the state under its type category.
	mall_create_type(_template.type, _key);

	return true;
}

/// @desc Creates a state template from data and adds it to the database.
/// @param {String} key State key (for example "STATE_POISON").
/// @param {Struct} data Data struct read from JSON.
function mall_create_state_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_state_from_data expected a struct data.");
		return false;
	}

	var _state = (new MallState(_key) ).Import(_data);
	return (mall_create_state(_key, _state) );
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