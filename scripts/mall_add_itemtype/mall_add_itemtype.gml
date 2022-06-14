/// @param itemtype_key
/// @param [prefix_keys]
/// @desc Añade itemtypes globalmente
function mall_add_itemtype(_key) {
    var _item = new MallItemtype(_key);    
    var i=1; repeat (argument_count - 1) {
		_item.set(argument[i++] ); 
	}
	
	global.__mall_itemstype_index[$ _key] = _item;
	array_push(global.__mall_itemstype_master, _key);
}