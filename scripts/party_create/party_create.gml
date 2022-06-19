/// @param	{String}	template_key	LLave de la template
/// @param  {Array}		template_array	Argumentos para pasar al metodo del template
/// @param  {String}	party_group_key	Llave de un grupo de party
/// @desc	Devuelve un entidad de party a partir de un party template, permite agregarlo rapidamente a un grupo party
/// @return {Struct.PartyEntity}
function party_create(_key, _arg=[], _group) 
{
	var _entity = global.__mall_party_templates[$ _key] (_arg);
	if (is_string(_group) )	party_group_add(_group, _execute)	
	
	return (_entity );
}