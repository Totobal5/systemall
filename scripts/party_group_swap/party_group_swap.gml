/// @desc Intercambia las entidades de un grupo al otrog
/// @param {String} groupKeyA Description
/// @param {String} groupKeyB Description
function party_group_swap(_groupKey1, _groupKey2)
{
	// Obtener grupos
	var _gA = party_group_get(_groupKey1);
	var _gB = party_group_get(_groupKey2);
	
	// Obtener lista de entidades de cada grupo
	var _entitysA = _gA.getEntitys();
	var _entitysB = _gB.getEntitys();
	
	// Intercambiar
	_gA.entitys = _entitysB;
	_gB.entitys = _entitysA;
	
	// Actualizar llave
	with (_gA) array_foreach(entitys, function(v) {v.key = key});
	with (_gB) array_foreach(entitys, function(v) {v.key = key});
}