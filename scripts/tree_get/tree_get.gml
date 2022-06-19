/// @param {Struct.Tree}	tree
/// @param {String}			id
/// @desc Devuelve una tree que se encuentra en el tree pasado (local)
/// @return {Struct.Tree}
function tree_get(_tree, _id) {
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	return (_tree.__getMap() [$ _id] );
}