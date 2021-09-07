#macro TREE_NOTEXIST show_error("El arbol o rama no existen", true)

/// @param [root_value]
/// @returns {__tree_class}
function tree_create(_root_val = 0) {
	return (new __tree_class(_root_val) ).__set_trunk__();
}

/// @param {struct} tree
/// @desc Comprueba que "_tree" sea una clase Tree
/// @return {bool} True o False
function tree_exists(_tree) {
    return (is_struct(_tree) && _tree.__is = "Tree class");
}

/// @param {struct} trunk
/// @desc Comprueba que "_tree" sea un tronco
/// @return {bool} True o False
function tree_is_trunk(_trunk) {
	return (tree_exists(_trunk) && _trunk.id == "root");
}

/// @param {struct} tree
/// @param {string} id
/// @param {number} [value]
/// @desc Agrega una rama nueva a un arbol
/// @returns {struct} Rama recien agregada
function tree_add(_tree, _id, _val = 0) {
	// Agrega una nueva hoja a la rama seleccionada
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	// Agrega una rama al arbol
	return _tree.add(_tree, _id, _val);
}
	
/// @param {struct} tree
/// @param {string} id
/// @desc Elimina una rama del arbol seleccionado
/// @return {array} Rama eliminada
function tree_delete(_tree, _id) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	var _obtain = _tree.filter(function(l, i, _ext = _id) {return  (l.id == _ext); }, true);
	
	_tree.leaves = _obtain[0];
	
	return _obtain[1];
}

/// @param {struct} tree
/// @param {string} id
/// @desc Convierte una rama en un tronco sacandola del tronco principal
/// @return {array} Rama eliminada
function tree_cut(_tree, _id) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	var _obtain = _tree.filter(function(l, i, _ext = _id) {return  (l.id == _ext); }, true);
	
	_tree.leaves = _obtain[0];
	
	_obtain.__set_trunk__();
	
	return _obtain[1];	
}

/// @param node
function tree_destroy(_tree) {
	delete _tree;
}

/// @param {struct} tree
/// @param {number} depth
/// @desc Obtiene todas las ramas que pertanezcan a esta profundidad. Esta funcion es lenta usar con precaucion.
/// @return {array} Rama eliminada
function tree_depth(_tree, _depth) {
	var _iterate = _tree.trunk;
	
	_iterate.search(_depth);
}

/// @param {struct} tree
/// @param {string} id
/// @desc Comprueba si una rama posee un hijo con la id buscada
/// @return {bool} True o False
function tree_leave_exists(_tree, _id) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;
	
	var _leave = _tree.get(_id);
	
	return tree_exists(_leave);
}

/// @description tree_get(tree, name, both)
/// @param {struct} tree
/// @param {string} id
/// @param {bool} both true -> entrega la posicion (i)
/// @return {array} or {struct}
function tree_get(_tree, _id, _both = false) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	return (_both) ? _tree.get(_id) : _tree.get(_id, true);
}

/// @param {struct} tree
/// @desc devuelve todas las hojas que existen en el arbol
/// @return {array} lleno de las id de las ramas (string´s)
function tree_get_leaves(_tree) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	return _tree.get_names();
}

/// @param {struct} tree
/// @desc Devuelve el valor de una rama
function tree_get_value(_tree)  {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	return _tree.value;
}

/// @param {struct} tree
/// @param value
/// @desc Establece el valor de una rama
function tree_set_value(_tree, _val) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	_tree.value = _val;
}

/// @param {struct} tree
/// @desc Recupera el tamaño del arbol
function tree_size(_tree) {
	if (!tree_exists(_tree) ) TREE_NOTEXIST;

	return _tree.get_size();
}





