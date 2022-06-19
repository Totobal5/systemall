/// @param {Struct.Tree}	tree
/// @desc Comprueba que "tree" sea el nodo inicial
/// @return {Bool}
function tree_is_root(_tree) 
{
	return (is_tree(_tree) && _tree.__id == "root");
}