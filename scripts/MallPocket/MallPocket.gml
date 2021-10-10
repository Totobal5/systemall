#macro MALL_POCKET_NAMES	global._MALL_GLOBAL.pocketnames
#macro MALL_POCKET			global._MALL_GLOBAL.pocket
#macro MALL_POCKET_ITEMTYPE global._MALL_GLOBAL.pocketitemtype

/// @typedef {struct<name:string, index:number, order:array, limit:number>} Pocket_mall

/// @returns {array}
function mall_pocket() {
	return (MALL_POCKET);
}

/// @returns {struct}
function mall_pocket_names() {
	return (MALL_POCKET_NAMES);
}

/// @returns {struct}
function mall_pocket_itemtype() {
	return (MALL_POCKET_ITEMTYPE);
}

/// @param {string} pocket_name
/// @param {number}  limit
/// @param itemtypes...
/// @returns {Pocket_mall}
function mall_create_pocket(_name, _limit = noone) {   
    var _pocket = mall_pocket();
    var _names  = mall_pocket_names();
	
	var _pocketitemtype = mall_pocket_itemtype();
	
    var _count = array_length(_pocket);
    
    if (!variable_struct_exists(_names, _name) ) {
    	var _new = {name: _name, index: _count, order: [], limit: _limit};

		for (var i = 2, _order = _new.order; i < argument_count - 2; i++) {
			var _itemtype = argument[i];
			
			// Agregar sub-type
			variable_struct_set(_pocketitemtype, _itemtype, _new);
			array_push(_order, _itemtype);
		}

        variable_struct_set(_names, _name, _new);
        array_push(_pocket, _name); // Agregar a la lista de bolsillos

        return _new;
    }    
}

/// @param pocket_name
/// @returns {bool}
function mall_pocket_exists(_name) {
	return (variable_struct_exists(MALL_POCKET_NAMES, _name) );
}

/// @param access
function mall_get_pocket(_access) {
	if (is_numeric(_access) ) _access = MALL_POCKET[_access];
	
	return (MALL_POCKET_NAMES[$ _access] );
}

/// @desc Devuelve el bolsillo al que pertenece este tipo de objeto
function mall_pocket_permitted(_itemtype) {
	return (MALL_POCKET_ITEMTYPE[$ _itemtype] );	
}

