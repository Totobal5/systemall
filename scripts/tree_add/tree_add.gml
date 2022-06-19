/// @param {Struct.Tree}	tree
/// @param {String}			id
/// @param {Mixed}			[value]
/// @param {Bool}			[is_node]
/// @desc Agrega una rama nueva a un arbol y la devuelve
/// @return {Struct.Tree}
function tree_add(_tree, _value=0, _id, _is_node=true) 
{
	// Agrega una nueva hoja a la rama seleccionada
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true)

	// Agrega una rama al arbol
	return (_tree.add(_id, _value, _is_node) );
}