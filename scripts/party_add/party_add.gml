/// @desc Añade una entidad al final de un grupo party
/// @param {String}				partyGroupKey   Llave del grupo party
/// @param {Struct.PartyEntity}	partyEntity     Entidad de party
function party_add(_key, _entity)
{
	var _group = party_group_get(_key);
	// Agregar al grupo dependiendo de como este grupo agrega elementos
	if (!is_undefined(_group) ) {
		return (_group.add(_entity) ); 
	}
	
	return false;
}