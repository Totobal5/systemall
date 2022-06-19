/// @param			party_group_key
/// @param			party_entity
/// @param {Real}	[index]
/// @desc Agrega una entidad party en un grupo en la posicion indicada
function party_group_set(_key, _entity, _index=0)
{
	var _group = party_group_get(_key);
	array_insert(_group, _index, _entity);
}