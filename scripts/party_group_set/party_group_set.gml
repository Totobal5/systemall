/// @desc Agrega una entidad party en un grupo en la posicion indicada
/// @param	{String}	party_group_key
/// @param	{Struct.PartyEntity}	party_entity
/// @param	{Real}	[index]	defautl es 0
function party_group_set(_KEY, _ENTITY, _INDEX=0)
{
	var _group = party_group_get(_KEY);
	array_insert(_group.order, _INDEX, _ENTITY);
	_group[$ _KEY] = _ENTITY;
	
	return (_group );
}