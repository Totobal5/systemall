/// @param {String} _group_key
/// @param {Bool} _actual
/// @return {Struct.MallGroup}
function mall_add_group(_group_key, _actual=false) {
	var _group = new MallGroup(_group_key); 
	global.__mall_groups_master.set(_group_key, _group);
	if (_actual) global.__mall_actual_group = _group;
	return (_group);
}