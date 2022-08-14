/// @desc Añade una entidad al principio de un grupo party
/// @param {String}				grup_key		Llave del grupo party
/// @param {Struct.PartyEntity}	party_entity	Entidad de party
function party_group_add(_KEY, _ENTITY)
{
	var _group = party_group_get(_KEY);
	_group[$ _KEY] = _ENTITY;
	array_push(_group.__order, _ENTITY);
	
	return (_group );
}