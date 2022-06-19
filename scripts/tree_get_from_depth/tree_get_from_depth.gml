/// @param {Struct.Tree}	tree
/// @param {Real}			depth
/// @desc Obtiene todas las ramas que pertanezcan a esta profundidad.
/// @return {Array}
function tree_get_from_depth(_tree, _depth) 
{
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	
	var _root  = _tree.__getRoot();
	var _depth = string(_depth);
	var _return = [];
	
	if (variable_struct_exists(_root, _depth) )
	{
		var _map = _root[$ _depth];
		var i=0; repeat(array_length(_map.__order) )
		{
			var _oid = _map.__order[i++];
			var _otree = _map[$ _oid];
			
			array_push(_return, _otree);
		}
	}
	
	return (_return );
}