/// @desc Inicia el sistema de templates de Lima
function lima_template_initialize() {
	templates = {};
	var _lim = global.__lima_templates_index;
	
	var i=0; repeat(array_length(_lim) ) {
		var _name = _lim[i++];
		templates[$ _name] = method(undefined, global.__lima_templates_name[$ _name] );
	}
}