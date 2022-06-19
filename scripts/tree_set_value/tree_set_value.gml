/// @param {Struct.Tree}	tree
/// @param {Mixed}			value
/// @desc Establece el valor del tree
function tree_set_value(_tree, _value) 
{
	if (!is_tree(_tree) ) show_error("El arbol o rama no existen", true);
	_tree.value = _value;
}