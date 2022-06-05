/// @param {Id.Instance} _child
/// @desc Agrega hijos a la instancia de lima. Permite arrays
function lima_child_add(_child) {
	if (!is_array(_child) ) {
		if (!is_lima(_child) && _child == id) exit;
		
		_child.parent = id;
		array_push(childrens, _child);
	}
	else {
		#region Array de hijos
		var i=0; repeat(array_length(_child) ) {
			lima_child_add(_child[i++] );
		}
		
		#endregion
	}
}