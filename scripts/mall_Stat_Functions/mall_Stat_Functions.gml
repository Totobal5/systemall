/// @desc Creates a stat at runtime.
/// @param {String} key Stat key.
/// @param {Struct.MallStat} template MallStat template.
function mall_create_stat(_key, _template) 
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_stat expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_stat expected a struct template.");
		return false;
	}

	if (mall_exists_stat(_key) ) 
	{ 
		__mall_error($"Stat '{_key}' already exists."); 
		return false;
	}
	
	__Systemall.__stats[$ _key] = _template;
	array_push(__Systemall.__stats_keys, _key);

	// Register the stat under its type category.
	mall_create_type(_template.type, _key);

	return true;
}

/// @desc Creates a stat template from data and adds it to the database.
/// @param {String} key Stat key (for example "EN").
/// @param {Struct} data Data struct read from JSON.
function mall_create_stat_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_stat_from_data expected a struct data.");
		return false;
	}

	// Create an empty instance and then configure it from incoming data.
	var _stat = new MallStat(_key).Import(_data);	
	return mall_create_stat(_key, _stat);
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