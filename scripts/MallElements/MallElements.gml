/// @param element_name
/// @param element_index
function __mall_class_element(_name = "") : __mall_class_parent("MALL_ELEMENT_INTERN") constructor {
    // Lo basico
    SetBasic(_name, -1);
    
    absorb = []; // Una estadistica qe puede beneficiar del elemento
    absorb_threshold = 0;

    reduce = []; // Una estadistica qe puede perjudiciar del elemento
    reduce_threshold = 0;
    
    produce = []; // Probabilidad de producirlos estados

    attack = [];    // Que estadistica ataca con este elemento
    defend = [];    // Que estadistica defiende este elemento
    
    #region Metodos
   
    	#region Produce
    /// @param state_name
    /// @param value
    static Produce = function(_state, _values) {
        array_push(produce, [_state, _values] );
        
        return self;
    }
    
    /// @param index
    static GetProduce = function(_index) {
        return (produce[_index] );
    }

    #endregion
    
    /// @param attack_stat
    /// @param defend_stat
    static Interaction = function(_attack, _defend) {
        array_push(attack, _attack);
        array_push(defend, _defend);
        
        return self;
    }
    
    /// @param index
    static GetInteraction = function(_index) {
        return ([attack[_index], defend[_index] ] );
    }
    
	static Inherit = function(_other) {
	
	}
    
  
    #endregion
}

function mall_create_elements() {
    var _order  = mall_elements();
    var _elemns = mall_elements_names();
    
    var _count = array_length(_order);
    
    repeat(argument_count) {
    	var in = argument[_count];
    	
    	if (!variable_struct_exists(_elemns, in) ) {		
    		array_push(_order, in);
    		variable_struct_set(_elemns, in, _count);
    	}
    	
        _count++;
    }    
}

/// @returns {array}
function mall_elements() {
    return (global._MALL_GLOBAL.elemns);
}

/// @returns {struct}
function mall_elements_names() {
    return (global._MALL_GLOBAL.elemnsnames);
}

/// @param element_name
/// @returns {bool}
function mall_element_exists(_name) {
    return (variable_struct_exists(global._MALL_GLOBAL.elemnsnames, _name) );
}

/// @param access
function mall_get_element(_access) {
    if (is_numeric(_access) ) _access = global._MALL_GLOBAL.elemn[_access];
    
    return (mall_group_init() ).GetElement(_access);    
}

/// @param element_name
/// @param attack_stat
/// @param defend_stat
/// @param produce_state
/// @param produce_value...
function mall_element_customize(_name, _attack, _defend, _produce, _chance) {
    return (mall_group_init() ).CustomizeElement(_name, _attack, _defend, _produce, _chance);
}



