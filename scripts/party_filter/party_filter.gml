/// @desc Busca una entidad de party en un grupo utilizando un filtro (lento)
/// @param	{String}	party_group_key
/// @param	{Function}	filter
function party_filter(_KEY, _METHOD)
{
	var _group = party_group_get(_KEY);
	var _ents  = _group.entitys;
	var i=0; repeat(array_length(_ents) )
	{
		var _t = _ents[i];
		if (_METHOD(_t, i) ) return (_t);
		i = i + 1;
	}
}