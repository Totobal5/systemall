/**
 * Function Description
 * @param {String}				party_group_key		Description
 * @param {Struct.PartyEntity}	party_entity		Description
 * @param {Real}				[index=0]			Description
 * @returns {Struct.PartyGroup} Description
 */
function party_set(_KEY, _ENTITY, _INDEX=0)
{

	// Feather ignore all
	var group = party_group_get(_KEY);
	if (is_undefined(group) ) return undefined;
	
	var _ents = group.entitys;
	var _size = array_length(_ents);
	
	if (_size < group.limit) || (group.limit == -1)
	{
		array_insert(_ents, _INDEX, _ENTITY);
		var i=0; repeat(_size + 1)
		{
			var _in = _ents[i];
			_in.index = i;
			i = i+1;
		}
	}

	return (group);
}