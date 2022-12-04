/// @desc Ejecuta una funcion por cada entidad en el grupo, si la funcion pasada entrega true entonces devuelve
/// un struct {entity, index}
/// @param	{String}	partyGroup
/// @param	{Function}	method function(v,i) {}
function party_foreach(_key, _method)
{
	var _group = party_group_get(_key);
	if (!is_undefined(_group) ) {
		var i = array_find_index(_group.entitys, _method);
		if (i != -1) {
			return {
				entity: _group.entitys[i],
				index : i
			}
		}
	} 
}