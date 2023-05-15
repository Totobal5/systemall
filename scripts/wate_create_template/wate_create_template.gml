/// @desc Function Description
/// @param {string}   templateKey  Description
/// @param {function} template     Description
/// @returns {struct} 
function wate_create_template(_wateKey, _function)
{
	static database = MallDatabase.wate.templates;
	if (!variable_struct_exists(database, _wateKey) ) {
		database[$ _wateKey] = _function;
		if (MALL_WATE_TRACE) show_debug_message("MallRPG Wate: template {0} creada", _wateKey);
	}
}

/// @return {Struct.PartyEntity}
function wate_default()
{
	static ent = (new PartyEntity("defaultWate") );
	return ent;
}