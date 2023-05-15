/// @desc	Devuelve un entidad de party a partir de un party template, permite agregarlo rapidamente a un grupo party
/// @param	{String} templateKey    Llave de la template
/// @param  {String} [groupKey]     Si se quiere agregar esta entidad a un grupo de party
/// @param  {Real}   [level]        Nivel en que se crea la entidad
/// @param	{Any}    [arguments]    Más argumentos para pasar
/// @return {Struct.PartyEntity}
function party_create(_key, _group=undefined, _level=1, _args={}) 
{
	static templates = MallDatabase.party.templates;
	var _template = templates[$ _key];
	
	// Nivel global maximo 
	var _maxLevel = clamp(_level, MALL_PARTY_MIN_LEVEL, MALL_PARTY_MAX_LEVEL);
	
	// Crear entidad a partir de un template
	var _entity = _template(_maxLevel, _args);
	
	// Añadir a un grupo si se requiere
	if (is_string(_group) ) party_add(_group, _entity);
	return (_entity);
}