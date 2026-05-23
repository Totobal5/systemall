/// @desc Creates an item at runtime.
/// @param {String} key Item key (for example "ITEM_SWORD").
/// @param {Struct.MallItem} _template MallItem template.
function mall_create_item(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_item expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_item expected a struct template.");
		return false;
	}	

	if (mall_exists_item(_key) ) 
	{ 
		__mall_error($"Item '{_key}' already exists."); 
		return false;
	}

	__Systemall.__items[$ _key] = _template;
	array_push(__Systemall.__items_keys, _key);
	
	// Register item in runtime type index.
	mall_create_type(_template.type, _key);
	
	return true;
}

/// @desc Creates an item template from data and registers it in __Systemall.
/// @param {String} key Unique item key.
/// @param {Struct} data Raw item data.
function mall_create_item_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_item_from_data expected a struct data.");
		return false;
	}

	var _item = (new MallItem(_key) ).Import(_data);
	return (mall_create_item(_key, _item) );
}

/// @desc Returns an item template by key.
/// @param {String} key The unique item key.
/// @returns {Struct.MallItem|undefined}
function mall_get_item(_key)
{ 
	return (__Systemall.__items[$ _key] ); 
}

/// @desc Returns whether an item template exists.
/// @param {String} key The unique item key.
/// @returns {Bool}
function mall_exists_item(_key) 
{ 
	return (struct_exists(__Systemall.__items, _key) ); 
}

/// @desc Returns an array with all registered item keys.
/// @returns {Array<String>}
function mall_get_item_keys()
{
	return (__Systemall.__items_keys);
}