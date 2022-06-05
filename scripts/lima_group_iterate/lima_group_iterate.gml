/// @param {Id.Instance} lima
/// @param {Function} execute
/// @desc Ejecuta una funcion anonima por cada elemento del grupo
function lima_group_iterate(lima, execute) {
	var _index = lima.group;
	var _group = global.__lima_groups[_index];
	for (var i=0,len=array_length(_group); i<len; i++) {
		var _ins = _group[i];
		if (instance_exists(_ins) ) {
			execute(_ins, i++);
		}
		else {
			array_delete(_group, i, 1);
			i--;
		}
	}
}


