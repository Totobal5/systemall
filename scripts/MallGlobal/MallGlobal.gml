global._MALL_GLOBAL = {
    stats: [], statsnames:  {},
    state: [], statenames:  {}, 
    elmn:  [], elmnnames:   {}, 
    part:  [], partnames:   {},
    
    dark:     [], darknames:     {},   
    itemtype: [], itemtypenames: {}, itemsubnames: {},
    pocket:   [], pocketnames:   {}
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
