/// @desc Busca una entidad de party en un grupo utilizando un filtro (lento)
/// @param	{String}	partyGroupKey
/// @param	{Function}	filter
function party_filter(_groupKey, _function)
{
	var _group   = party_group_get(_groupKey);
	var _entitys = _group.entitys;
	
	var _index = array_find_index(_entitys, _function);
	return (_entitys[_index] );
}