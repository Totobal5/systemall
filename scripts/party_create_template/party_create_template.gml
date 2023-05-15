/// @param {String}   templateKey  Llave del template
/// @param {Function} template     function(groupKey, level, [args]) {}
function party_create_template(_key, _template)
{
	static templates = MallDatabase.party.templates;
	templates[$ _key] ??= _template;
}