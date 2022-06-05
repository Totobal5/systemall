/// @param {String} key
/// @desc Devuelve el tipo a partir del subtipo
/// @return {String}
function mall_get_itemtype_sub(_sub_key) {
	var i=0; repeat(array_length(global.__mall_itemstype_master) ) {
		var _key = global.__mall_itemstype_master[i++];
		var _itemtype = global.__mall_itemstype_index[$ _key];
		
		if (_itemtype.exists(_sub_key) ) return (_key);
	}
	
	return "";
}