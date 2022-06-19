/// @param {String}		template_name
/// @param {Function}	create_method
function party_template_create(_key, _create_method)
{
	if (variable_struct_exists(global.__mall_party_templates, _key) )
	{
		global.__mall_party_templates[$ _key] = _create_method;
	}
}