/// @param {Resource.GMObject} object
/// @param {Bool} [descendant?]
/// @returns {Bool}
/// @desc Comprueba si esta instancia es un objeto o descendiente
function is_object(_obj, _check = false) {
	return (object_index == _obj) || (_check && object_is_ancestor(object_index, _obj) );
}