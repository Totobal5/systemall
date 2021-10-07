/// @param state_name
/// @param state_start
/// @param stat_resistance
/// @param stat_hudname
function __mall_class_state(_name = "", _start = false, _rest, _hudname = _name) : __mall_class_parent("MALL_STATE_INTERN") constructor {
    SetBasic(_name, -1);
    
    start = _start;
    
    resist = [];
    //affect = [];
    
    process = { // Procesos que puede ejecutar
	    start : 1,     
	    ending: 1,
	    aument: 0,
	    
	    turnactive: 1,
	    turnaument: 1,
	    turniter: 0,    // Cada cuantas iteraciones realiza su efecto
	    ////////////////////// DARK
	    update: "",
	    
	    updatestart: "",
	    updateend  : ""
	}
    
	//link = (new __mall_class_group("", -1) ).AllSetArray();	/// @is {__mall_class_group}
	
    #region Metodos
    	#region Processes
    
    /// @param start_value
    /// @param end_value
    /// @param aument_value
    /// @param turn_active
    /// @param turn_iteration  
    /// @param dark_update
    /// @param turn_aument
    /// @param dark_start_update
    /// @param dark_end_update
	static Process = function(_start, _end, _aument, _turnactive, _turniter = 1, _propupdate, _turnaument = 1, _propstart, _propend) {
		process.start  = _start;
		process.ending = _end;
	    process.aument = _aument;
		
		process.turnactive = _turnactive;
		process.turnaument = _turnaument;
		process.turniter = _turniter;
		
		////////////////////////////// DARK
		process.update = _propupdate;
		process.updatestart = _propstart;
		process.updateend   = _propend;
		
		return self;
	}
    
    /// @returns {struct}
    static GetProcess = function() {
    	return (process);
    }
    
    #endregion
    
		#region Links
	/// @param stat
    static AddResistance = function(_rest) {
        if (!is_mall_stat(_rest) ) exit;
        
        array_push(resist, _rest.name);
        return self;
    }
    
    /// @param stat
    /// @param value
    static AddAffect = function(_stat, _value) {
        if (argument_count < 2) {
            //array_push(affect, [_stat, _value] );
            _stat.WatchState(name, _value);
        } else {
            for (var i = 0; i < argument_count; i += 2) {
                AddAffect(argument[i], argument[i + 1] );
            }
        }

        return self;
    }
    
	#endregion
	
	/// @param state_class
	static Inherit = function(_other) {
		return self;
	}
	 
	static Copy = function() {}
   
    #endregion
    
    AddResistance(_rest);
    SetString    (_hudname);
}

function mall_create_states() {
    var _order = mall_states();
    var _stats = mall_states_names();
    
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

/// @returns {array} all_states
function mall_states() {
    return (global._MALL_GLOBAL.states);
}

/// @returns {struct} all_states_names
function mall_states_names() {
    return (global._MALL_GLOBAL.statesnames);
}

/// @returns {struct}
function mall_states_copy() {
    var _names = mall_states(), _reference = {}, i = 0;

    repeat(array_length(_names) ) {
        variable_struct_set(_reference, _names[i], undefined);
        
        ++i;
    }
    
    return (_reference );
}

/// @param {string} name
/// @returns {bool}
function mall_state_exists(_name) {
	return (variable_struct_exists(global._MALL_GLOBAL.statenames, _name) );	
}

/// @returns {__mall_class_state}
function mall_get_state(_access) {
    if (is_numeric(_access) ) _access = global._MALL_GLOBAL.states[_access];
    
    return (mall_group_init() ).GetState(_access);
}

/// @param name
/// @param start
/// @param resistance
/// @param hud_name*
function mall_state_customize(_name, _start, _rest, _hudname) {
	if (!mall_state_exists(_name) ) return noone;
	
    return (mall_group_init() ).CustomizeState(_name, _start, _rest, _hudname);    
}






