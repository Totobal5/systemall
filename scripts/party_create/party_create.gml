/// @desc	Devuelve un entidad de party a partir de un party template, permite agregarlo rapidamente a un grupo party
/// @param	{String}	template_key	Llave de la template
/// @param  {String}	group_key		Argumentos para pasar al metodo del template
/// @param  {String}	level			Nivel en que se crea la entidad
/// @param	{Array}		[arguments]		Más argumentos para pasar
/// @return {Struct.PartyEntity}
function party_create(_KEY, _GROUP, _LEVEL, _ARGS) 
{
	var _template = global.__mallPartyTemplate[$ _KEY];
	
	if (_LEVEL <= 0) _LEVEL = 1;
	var _entity   = _template(_GROUP, _LEVEL, _ARGS).setKey(_KEY);

	return (_entity);
}