/// @desc Intercambia las entidades de un grupo a otro
/// @param {String} groupKeyA Description
/// @param {String} groupKeyB Description
function party_group_swap(_groupKey1, _groupKey2)
{
	// Obtener grupos
	var _gA = party_group_get(_groupKey1);
	var _gB = party_group_get(_groupKey2);
	
	// Obtener lista de entidades de cada grupo
	var _entitiesA = _gA.getEntities();
	var _entitiesB = _gB.getEntities();
	
	// Intercambiar
	_gA.entities = _entitiesB;
	_gB.entities = _entitiesA;
	
	// Actualizar llave
	with (_gA) array_foreach(entities, function(v) /*=>*/ {v.group = key; });
	with (_gB) array_foreach(entities, function(v) /*=>*/ {v.group = key; });
}