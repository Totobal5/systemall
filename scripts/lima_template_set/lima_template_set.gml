/// @param {String, Real}	template	Nombre o indice del template
/// @param {Function}		method		Function a ejecutar
function lima_template_set(_template, _function) {
	if (is_real(_template) ) {
		_template = global.__lima_templates_index[_template];	
	}
	// Si existe el template en el sistema
	if (variable_struct_exists(global.__lima_templates_name, _template) ) {
		/// @context {lima_parent}
		templates[$ _template] = method(undefined, _function);			
	}
}