/// @param {Id.DsList} list_index
/// @returns {Array<Mixed>}
function ds_list_to_array(list_index) {
	var _size  = ds_list_size(list_index);
	var _array = array_create(_size);
	
	var i=0; repeat(_size) _array[i] = list_index[| i++];
	return (_array);
}
