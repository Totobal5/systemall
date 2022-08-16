/**
 * Ejecuta una funcion por cada elemento del grupo
 * @param {String}	 party_group_key	Description
 * @param {function} method				function(entitys, i) {}
 */
function party_foreach(_KEY, _METHOD, _FLAGS)
{
	var _group = party_group_get(_KEY);
	var _ents  = _group.entitys;
	var i=0; repeat(array_length(_ents) )
	{
		_METHOD(_ents[i], i, _FLAGS);
		i = i + 1;
	}
}