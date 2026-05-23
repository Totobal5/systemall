/// @desc Creates a slot at runtime.
/// @param {String} key Slot key (for example "SLOT_WEAPON").
/// @param {Struct.MallSlot} _template MallSlot template.
function mall_create_slot(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_slot expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_slot expected a struct template.");
		return false;
	}	

	if (mall_exists_slot(_key) ) 
	{ 
		__mall_error($"Slot '{_key}' already exists."); 
		return false;
	}
	
	__Systemall.__slots[$ _key] = _template;
	array_push(__Systemall.__slots_keys, _key);

	// Register the slot under its type category.
	mall_create_type(_template.type, _key);

	return true;
}

/// @desc Creates a slot template from data and adds it to the database.
/// @param {String} key Slot key (for example "SLOT_WEAPON").
/// @param {Struct} data Data struct read from JSON.
function mall_create_slot_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_slot_from_data expected a struct data.");
		return false;
	}

	var _slot = (new MallSlot(_key) ).Import(_data);
	return (mall_create_slot(_key, _slot) );
}

/// @desc Returns a slot template by key.
/// @param {String} key Slot key.
/// @return {Struct.MallSlot}
function mall_get_slot(_key) 
{
	return __Systemall.__slots[$ _key]; 
}

/// @desc Checks whether a slot exists in the database.
/// @param {String} key Slot key.
/// @return {Bool}
function mall_exists_slot(_key) 
{
	return struct_exists(__Systemall.__slots, _key); 
}

/// @desc Returns an array with all registered slot keys.
/// @return {Array<String>}
function mall_get_slot_keys() 
{
	return __Systemall.__slots_keys; 
}