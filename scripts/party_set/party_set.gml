/// Añade una entidad al grupo indicando el indice en donde colocarlo
/// @param {String}				party_group		llave del grupo
/// @param {Struct.PartyEntity}	party_entity	entidad a agregar
/// @param {Real}				[index=0]		indice para insertar
/// @returns {Struct.PartyGroup}
function party_set(_key, _entity, _index=0)
{
	// Feather ignore all
	var _group = party_group_get(_key);
	if (!is_undefined(_group) ) {
		return _group.set(_entity, _index); 
	}
	return false;
}