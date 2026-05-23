/// @desc Functions for managing loot tables.
/// @param {String} key Loot table key.
/// @param {Struct.MallLootTable} template Loot table template struct.
function mall_create_loot_table(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_loot_table expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_loot_table expected a struct template.");
		return false;
	}	

	if (mall_exists_loot_table(_key) ) 
	{ 
		__mall_error($"Loot table '{_key}' already exists."); 
		return false;
	}
	
	__Systemall.__loot_tables[$ _key] = _template;
	array_push(__Systemall.__loot_tables_keys, _key);

	// Register the loot table under its type category.
	mall_create_type(_template.type, _key);

	return true;
}

/// @desc Creates a loot table template from data and adds it to the database.
/// @param {String} key Loot table key.
/// @param {Struct} data Loot table payload.
function mall_create_loot_table_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_loot_table_from_data expected a struct data.");
		return false;
	}

	var _template = (new MallLootTable(_key) ).Import(_data);
	return (mall_create_loot_table(_key, _template) );
}

/// @desc Returns a loot table template by key.
/// @param {String} key Loot table key.
/// @return {Struct|Undefined}
function mall_get_loot_table(_key)
{
	return __Systemall.__loot_tables[$ _key];
}

/// @desc Returns whether a loot table template exists.
/// @param {String} key Loot table key.
/// @return {Bool}
function mall_exists_loot_table(_key)
{
	return (struct_exists(__Systemall.__loot_tables, _key) );
}

/// @desc Returns an array with all registered loot table keys.
/// @return {Array<String>}
function mall_get_loot_table_keys()
{
	return (__Systemall.__loot_tables_keys);
}