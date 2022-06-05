/// @param {String} _template
/// @return {Bool}
function lima_template_exists(_template) {
	return (variable_struct_exists(global.__lima_templates_name, _template) )
}