/// Añade una entidad al grupo indicando el indice en donde colocarlo
/// @param {String}              partyGroupKey   Llave del grupo
/// @param {Struct.PartyEntity}  partyEntity     Entidad a agregar
/// @param {Real}                [index=0]       Indice para insertar
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