/// @desc Crea una plantilla de tabla de botín desde data y la añade a la base de datos.
function mall_loottable_create_from_data(_key, _data)
{
    if (struct_exists(Systemall.__loot_tables, _key) ) return;
	
    Systemall.__loot_tables[$ _key] = _data;
    array_push(Systemall.__loot_tables_keys, _key);
}

/// @desc Devuelve la plantilla de una tabla de botín.
function mall_get_loottable(_key)
{
    return Systemall.__loot_tables[$ _key];
}