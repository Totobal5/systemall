/// @param {String} _name
/// @param {Id.Instance} _elements
/// @desc Crea un grupo de lima
function lima_group_create(_name) {
	var _elements = array_create(argument_count);  
	array_push(global.__lima_groups, _elements);
	// Obtener indice
	var _index = array_length(global.__lima_groups);
	
	var i = 0; repeat(array_length(_elements) ) {
		argument[i].group = _index;
		argument[i].groupName = _name;
		
		_elements[i] = argument[i++];
	}
}