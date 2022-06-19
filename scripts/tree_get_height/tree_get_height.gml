/// @param {Struct.Tree}	tree
/// @desc Recupera la altura del tree (global)
/// @return {Real}
function tree_get_height(_tree) 
{
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	return (_tree.__getRoot().__h);
}