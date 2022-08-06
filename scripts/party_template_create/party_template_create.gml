/// @param {String}		template_key
/// @param {Function}	create_method	function(GROUP, LEVEL, ARGS) {}
function party_template_create(_KEY, _METHOD)
{
	if (!variable_struct_exists(global.__mallPartyTemplate, _KEY) )
	{
		global.__mallPartyTemplate[$ _KEY] = _METHOD;
	}
}