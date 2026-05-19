/// @desc Creates a stat template from data and adds it to the database.
/// @param {String} key Stat key (for example "EN").
/// @param {Struct} data Data struct read from JSON.
function mall_create_stat_from_data(_key, _data)
{
    if (!__mall_validate_registry_args("mall_create_stat_from_data", _key, _data, mall_exists_stat, "Stat")) return;
    
    // Create an empty instance and then configure it from incoming data.
    var _stat = new MallStat(_key).FromData(_data);
    
    __Systemall.__stats[$ _key] = _stat;
    array_push(__Systemall.__stats_keys, _key);
}

/// @desc Creates a stat at runtime.
/// @param {String} key Stat key.
/// @param {Struct.MallStat} component MallStat instance.
function mall_create_stat(_key, _component) 
{
    if (mall_exists_stat(_key) )
    {
        __mall_alert($"Stat '{_key}' already exists. Duplicate creation was skipped.");
		return;
    }
    
    __Systemall.__stats[$ _key] = _component;
    array_push(__Systemall.__stats_keys, _key);
}

/// @desc Returns a stat template by key.
/// @param {String} key Stat key.
/// @return {Struct.MallStat}
function mall_get_stat(_key) 
{
    return (__Systemall.__stats[$ _key] ); 
}

/// @desc Checks whether a stat exists in the database.
/// @param {String} key Stat key.
/// @return {Bool}
function mall_exists_stat(_key) 
{ 
    return (struct_exists(__Systemall.__stats, _key) ); 
}

/// @desc Returns an array with all registered stat keys.
/// @return {Array<String>}
function mall_get_stat_keys() 
{
    return (__Systemall.__stats_keys); 
}