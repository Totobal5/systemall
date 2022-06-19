/// @param {String}				party_grup_key	Llave del grupo party
/// @param {Struct.PartyEntity} party_entity	Entidad de party
/// @desc Añade una entidad al principio de un grupo party
function party_group_add(_key, _entity) 
{
	var _group = party_group_get(_key);
	array_push(_group, _entity)
	// Indicar grupo y posicion en éste
	_entity.setGroup(_key, array_length(_group) - 1);
}