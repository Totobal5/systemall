/// @param {Struct.Tree}	tree
/// @desc Devuelve el valor del tree
function tree_get_value(_tree)  
{
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	return _tree.value;
}