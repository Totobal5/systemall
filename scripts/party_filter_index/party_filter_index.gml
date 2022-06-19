/// @param	{String}	party_group_key
/// @param	{Function}	filter
/// @desc Busca una entidad de party en un grupo utilizando un filtro (lento) y devuelve el indice
function party_filter_index(_key, _filter)
{
	var _group = party_group_get(_key);
	var i=0; repeat(array_length(_group) )
	{
		var _entity = _group[i];
		if (_filter(_entity, i) ) return (i);
	}
	
	return (-1);	
}