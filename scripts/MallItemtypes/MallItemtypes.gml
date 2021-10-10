/// @typedef {struct<name:string, index:number, order:array>} Itemtype_mall

/// @returns {array}
function mall_itemtypes() {
    return (MALL_STORAGE.itemtype);
}

/// @returns {struct}
function mall_itemtypes_names() {
	return (MALL_STORAGE.itemtypenames);
}

/// @returns {struct}
function mall_itemsubtype_names() {
	return (MALL_STORAGE.itemsubnames);	
}

/// @param {string} itemtype
/// @param itemsubtypes...
/// @desc Crea los distintos tipos de objetos (armas, consumibles) tambien incluye los sub-tipos (arma:Espada, armadura:Vestido)
function mall_create_itemtypes(_itemtype) {
	var _types  = mall_itemtypes();
	var _inside = mall_itemtypes_names();
	
	var _sub    = mall_itemsubtype_names();
	
	var _count = array_length(_types);
	
    if (!variable_struct_exists(_inside, _itemtype) ) {
        var _type = {key: _itemtype, name: "", index: _count, order: [] };

		if (MALL_LOCALIZE) _type.name = lexicon_text(key);
		
		var _subkey, _subname;
		
		for (var i = 1, _order = _type.order; i < argument_count - 1; i++) {
			if (MALL_LOCALIZE) {
				_subkey  = key + "." + argument[i];
				_subname = lexicon_text(_subkey);
			} else {
				_subkey  = argument[i];
				_subname = "";
			}
			
			// Agregar sub-type
			variable_struct_set(_sub, _subkey, _type);
			array_push(_order, _sub);
		}
		
        // Agregar al orden
        array_push(_types, _itemtype);
        variable_struct_set(_inside, _itemtype, _type);
        
        return _type;
    }      
}

/// @param access
/// @returns {Itemtype_mall}
function mall_get_itemtype(_access) {
	if (is_numeric(_access) ) _access = MALL_STORAGE.itemtype[_access];

	return (MALL_STORAGE.itemtypenames[$ _access] );
}

/// @param {string} subtype
/// @returns {Itemtype_mall}
/// @desc Devuelve un tipo a partir de un sub-tipo
function mall_get_itemsubtype(_subtype) {
	return (MALL_STORAGE.itemsubnames[$ _subtype].itemtype );	
}

/// @param itemtype
/// @returns {bool}
function mall_itemtypes_exists(_itemtype) {
    return (variable_struct_exists(MALL_STORAGE.itemtypenames, _itemtype) );
}

/// @param subtype
/// @returns {bool}
function mall_itemsubtype_exists(_subtype) {
	return (variable_struct_exists(MALL_STORAGE.itemsubnames, _subtype) );
}

function mall_itemtypes_localize() {
		
}




