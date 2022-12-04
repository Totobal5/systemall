/// @param {String}		template_key
/// @param {Function}	create_method	function(groupKey, level, [args]) {}
function party_create_template(_key, _method)
{
	static templates = MallDatabase().party.templates;
	templates[$ _key] ??= _method;
}