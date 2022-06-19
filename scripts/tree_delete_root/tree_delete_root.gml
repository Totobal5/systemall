/// @param {Struct.Tree}	tree
/// @param {String}			id
/// @desc Elimina una rama del arbol seleccionado buscando desde el root
/// @return {Struct.Tree} Rama eliminada
function tree_delete_root(_tree, _id) 
{
	if (!is_tree(_tree) ) TREE_NOTEXIST;
	
	return (_tree.removeGlobal(_id) );
}