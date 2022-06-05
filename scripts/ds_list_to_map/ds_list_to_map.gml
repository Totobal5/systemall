/// @param {Id.DsList} _list
/// @returns {Id.DsMap}
/// @desc Medio hack
function ds_list_to_map(_list) {
	var _map  = ds_map_create();
	var _size = ds_list_size(_list);
	
	var i = 0; repeat(_size) _map[? i] = _list[| i++];
	return (_map);	
}