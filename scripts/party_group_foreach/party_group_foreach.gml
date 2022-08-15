function party_group_foreach(_KEY, _METHOD)
{
	var _group = party_group_get(_KEY);
	var _order = _group.order;
	var i=0; repeat(array_length(_order) )
	{
		var _key	= _order[i];
		var _entity	= _group[$ _key];
		
		_METHOD(_key, _entity, i);
		i = i + 1;
	}
}