/// @param {String}		_name
/// @param {Function}	_function
/// @param {Real}		[_index]	Remplazar
/// @desc Crea las templates que se utilizaran en todos los elementos lima
function lima_template_create(_name, _function, _index=-1) {
	_function ??= global.__lima_dummy_function;
	
	if (_index == -1) {
		array_push(global.__lima_templates_index, _name);
		global.__lima_templates_name[$ _name] = _function;					
	}
	else {
		global.__lima_templates_name[$ _name] = _function;
		global.__lima_templates_index[_index] = _name;
	}
}