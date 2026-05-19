/// @desc Creates a slot template from data and adds it to the database.
/// @param {String} key Slot key (for example "SLOT_WEAPON").
/// @param {Struct} data Data struct read from JSON.
function mall_create_slot_from_data(_key, _data)
{
    if (!__mall_validate_registry_args("mall_create_slot_from_data", _key, _data, mall_exists_slot, "Slot")) return;

    var _slot = (new MallSlot(_key) ).FromData(_data);
	
    __Systemall.__slots[$ _key] = _slot;
    array_push(__Systemall.__slots_keys, _key);
}

/// @desc Creates a slot at runtime.
/// @param {String} key Slot key (for example "SLOT_WEAPON").
/// @param {Struct.MallSlot} _component MallSlot instance.
function mall_create_slot(_key, _component)
{
    if (mall_exists_slot(_key) )
    {
		__mall_alert($"Slot '{_key}' already exists. Duplicate creation was skipped.");
		return;
	}
	
    __Systemall.__slots[$ _key] = _component;
    array_push(__Systemall.__slots_keys, _key);
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