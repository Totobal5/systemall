/// @desc Busca una entidad de party en un grupo utilizando un filtro (lento) y devuelve el indice
/// @param	{String}	party_group_key
/// @param	{Function}	filter
function party_filter_index(_KEY, _METHOD)
{
	var _group = party_group_get(_KEY);
	var _ents  = _group.entitys;
	var i=0; repeat(array_length(_ents) )
	{
		var _t = _ents[i];
		if (_METHOD(_t, i) ) return (i);
		i = i + 1;
	}
	
	return -1;
}
