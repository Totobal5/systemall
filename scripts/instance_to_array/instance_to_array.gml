/// @param {Resource.GMObject} object
/// @desc Devuelve un array de todas las instancias del objeto en el cuarto
function instance_to_array(_obj) {
	var _array = [];	
	with (_obj) array_push(_array, id);
	
	return (_array);
}