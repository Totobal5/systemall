/// @param {instance} id/// @param {object} object
/// @param {bool} [descendant?]
/// @desc Comprueba si una instancia es un objeto o descendiente
function instance_object(_id, _obj, _check = false) {
	with (_id) {
		return (is_object(_obj, _check) );
	}
}
