function mall_create_battle_encounter()
{
    
}

/// @desc Creates encounter and group templates from a Battle data struct.
/// @param {Struct} data Full Battle file payload.
function mall_create_battle_encounter_from_data(_data)
{
	/// @ignore
	static __groups = function(_key, _value) { __Systemall.__battle[$ "groups"][$ _key] = _value; }

	/// @ignore
	static __encounters = function(_key, _value) 
	{ 
		__Systemall.__battle.encounters[$ _key] = _value;
		array_push(__Systemall.__battle_keys, _key); 
	}

	if (!__mall_validate_registry_args("mall_create_battle_from_data", undefined, _data, undefined, "Battle", false)) return;
	
	if (!struct_exists(__Systemall.__battle, "groups") ) { __Systemall.__battle[$ "groups"] = {}; }

	// Load reusable enemy groups.
	if (struct_exists(_data, "groups") ) { struct_foreach(_data[$ "groups"], __groups); }
	// Load battle encounters.
	if (struct_exists(_data, "encounters") ) { struct_foreach(_data[$ "encounters"], __encounters); }
}

/// @desc Return a reusable encounter template.
/// @param {String} key Encounter template key.
/// @return {Struct.MallBattleEncounter}
function mall_get_battle_encounter(_key) 
{
	return __Systemall.__battle.encounters[$ _key]; 
}

/// @desc Checks if a battle encounter template exists for a given key.
/// @param {String} key Encounter template key.
/// @return {Bool}
function mall_exists_battle_encounter(_key)
{
	return (struct_exists(__Systemall.__battle.encounters, _key) );
}

/// @desc Return a reusable enemy group template.
/// @param {String} key Group template key.
/// @return {Struct.MallEntityGroup}
function mall_get_battle_group(_key)
{
	var _groups = __Systemall.__battle[$ "groups"] ?? {};
	return _groups[$ _key]; 
}