/// @param {Struct.Tree}	tree
/// @desc devuelve todas las hojas que existen en el arbol
/// @return {Array<Struct.Tree>}
function tree_get_all(_tree) 
{
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	return (_tree.__mapToArray() );
}