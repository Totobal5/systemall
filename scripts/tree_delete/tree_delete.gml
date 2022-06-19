/// @param {Struct.Tree}	tree
/// @param {String}			id
/// @desc Elimina una rama del arbol seleccionado buscando localmente
/// @return {Struct.Tree} Rama eliminada
function tree_delete(_tree, _id)
{
	if (!is_tree(_tree) ) TREE_NOTEXIST;
	
	return (_tree.remove(_id) );		
}