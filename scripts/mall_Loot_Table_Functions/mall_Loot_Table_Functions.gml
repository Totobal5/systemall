/// @desc Creates a loot table template from data and adds it to the database.
/// @param {String} key Loot table key.
/// @param {Struct} data Loot table payload.
function mall_create_loot_table_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_loot_table_from_data", _key, _data, mall_loot_table_exists, "Loot table")) return;

	var _loot_table = new MallLootTable(_key).FromData(_data);
	__Systemall.__loot_tables[$ _key] = _loot_table;
	array_push(__Systemall.__loot_tables_keys, _key);
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
function mall_loot_table_exists(_key)
{
	return (struct_exists(__Systemall.__loot_tables, _key));
}