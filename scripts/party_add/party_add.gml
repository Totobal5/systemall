/// @desc Añade una entidad al final de un grupo party
/// @param {String}				party_group_key		Llave del grupo party
/// @param {Struct.PartyEntity}	party_entity		Entidad de party
function party_add(_KEY, entity)
{
	var group = party_group_get(_KEY);
	if (is_undefined(group) ) return undefined;
	var _ents = group.entitys
	var _size = array_length(_ents);
	// Se puede seguir agregando elementos
	if ( (_size < group.limit) || (group.limit == -1) )
	{
		array_push(_ents, entity);
			
		// Obtener indice en el grupo
		entity.index = _size;
		entity.group = _KEY;
	}
	
	return (group);
}