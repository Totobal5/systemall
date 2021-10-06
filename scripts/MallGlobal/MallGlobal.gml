global._MALL_GLOBAL = {
    stats: [], statsnames:  {},
    state: [], statenames:  {}, 
    elmn:  [], elmnnames:   {}, 
    part:  [], partnames:   {},
    
    dark:     [], darknames:     {},   
    itemtype: [], itemtypenames: {}, itemsubnames: {},
    pocket:   [], pocketnames:   {}
}

/// @desc Crea las estadisticas que todos poseen
function mall_create_stats() {
    var _order = mall_global_stats();
    var _stats = mall_global_stats_names();
    
    var _count = array_length(_order);
    
    repeat(argument_count) {
    	var in = argument[_count];
    	
    	if (!variable_struct_exists(_stats, in) ) {		
    		array_push(_order, in);
    		variable_struct_set(_stats, in, _count);
    	}
    	
        _count++;
    }
}

/// @desc Devuelve todas las estadisticas en el sistema
/// @returns {array} all_stats
function mall_stats() {
    return (global._MALL_GLOBAL.stats);   
}

/// @returns {struct} all_stats_names
function mall_stats_names() {
    return (global._MALL_GLOBAL.statsnames);
}

/// @desc Crea un struct con todas las estadisticas
/// @returns {struct}
function mall_stats_copy() {
    var _names = mall_stats(), _reference = {}, i = 0;

    repeat(array_length(_names) ) {
        variable_struct_set(_reference, _names[i], undefined);
        
        ++i;
    }
    
    return (_reference );
}

/// @returns {array} all_states
function mall_global_states () {
    return (global._MALL_GLOBAL.state);
}

/// @returns {array} all_parts
function mall_global_parts	() {
    return (global._MALL_GLOBAL.part);
}

/// @returns {array} all_elements
function mall_global_elements () {
    return (global._MALL_GLOBAL.elmn);
}
