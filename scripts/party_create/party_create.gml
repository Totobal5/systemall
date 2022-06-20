/// @param	{String}	template_key	Llave de la template
/// @param  {String}	group_key		Argumentos para pasar al metodo del template
/// @param  {String}	level			Nivel en que se crea la entidad
/// @param	{Array}		[arguments]		Más argumentos para pasar
/// @desc	Devuelve un entidad de party a partir de un party template, permite agregarlo rapidamente a un grupo party
/// @return {Struct.PartyEntity}
function party_create(_key, _group, _level, _args) 
{
	var _template = global.__mall_party_templates[$ _key];
	var _entity   = _template(_group, _level, _args); 
	
	if (is_string(_group) ) 
	{
		party_group_add(_group, _entity);	
	}
	
	return (_entity );
}