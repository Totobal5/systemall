/// @param {String} party_group
function party_save(_groupKey)
{
	var _party = party_group_get(_groupKey);
	return (_party.save() );
}

/// @param {String} party_group
function party_load(_groupKey, _loadStruct)
{
	var _party = party_group_get(_groupKey);
	return (_party.load(_loadStruct) );
}

/// @desc Limpia la lista de entidades de este grupo
/// @param {String} party_group
function party_clean(_groupKey) 
{
	var _party = party_group_get(_groupKey);
	return (_party.clean() );
}