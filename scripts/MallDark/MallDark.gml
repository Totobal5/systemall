#macro MALL_DARK_NAMES      global._MALL_GLOBAL.darknames
#macro MALL_DARK_SUBNAMES   global._MALL_GLOBAL.darksubnames
#macro MALL_DARK            global._MALL_GLOBAL.dark

/// @typedef {struct<name:string, index:number, order:array>} Dark_mall

/// @returns {array}
function mall_dark() {
	return (MALL_DARK );
}

/// @returns {struct}
function mall_dark_names() {
	return (MALL_DARK_NAMES);
}

/// @returns {struct}
function mall_darksub_names() {
	return (MALL_DARK_SUBNAMES);
}

/// @param {string} dark_type
/// @param dark_subtypes...
/// @returns {Dark_mall}
function mall_create_dark(_type) {
	var _dark		= mall_dark();
	var _darknames	= mall_dark_names();
	
	var _darksub = mall_darksub_names();
	
	var _count = array_length(_dark);

    if (!variable_struct_exists(_names, _type) ) {
    	var _new = {name: _type, index: _count, order: [] }; 

		for (var i = 1, _order = _new.order; i < argument_count - 1; i++) {
			var _subname = argument[i];
			
			// Agregar sub-type
			variable_struct_set(_darksub, _subname, _new);
			array_push(_order, _subname);
		}
		
        // Agregar al orden
        array_push(_dark, _new);
        variable_struct_set(_darknames, _type, _new);
        
        return _new;
    }
}

/// @param access
/// @returns {Dark_mall}
function mall_get_dark(_access) {
	if (is_numeric(_access) ) _access = MALL_DARK[_access];
	
	return (MALL_DARK_NAMES[$ _access] );
}

/// @param dark_subtype
/// @returns {Dark_mall}
/// @desc Devuelve el tipo al que pertenece este subtipo.
function mall_get_darksub(_subtype) {
	return (MALL_DARK_SUBNAMES[$ _subtype] );	
}

/// @param {string} dark_type
/// @returns {bool}
function mall_dark_exists(_type) {
    return (variable_struct_exists(MALL_DARK_NAMES, _type) );
}

/// @param {string} dark_subtype
/// @returns {bool}
function mall_darksub_exists(_subtype) {
	return (variable_struct_exists(MALL_DARK_SUBNAMES, _subtype) );	
}






