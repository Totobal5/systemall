/// @param {Struct.Tree} tree
/// @desc Elimina la referencia del tree limpiandola
function tree_destroy(_tree) 
{
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	delete _tree;
}