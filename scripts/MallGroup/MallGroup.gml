global._MALL_GLOBAL = {
    stats : [], statsnames  : {},
    states: [], statesnames : {}, 
    
    elemns:  [], elemnsnames: {}, 
    parts :  [], partsnames: {},
    
    dark:     [], darknames:     {},   
    itemtype: [], itemtypenames: {}, itemsubnames: {},
    pocket:   [], pocketnames:   {}
}

/// @param name
/// @param index
function __mall_class_group(_name, _index = -1, _notinit = false) : __mall_class_parent("MALL_GROUP_INTERN") constructor { 
    name  = _name ;
    index = _index;
    
    if (!_notinit) {
	    stats  = mall_stats_copy ();
	    states = mall_states_copy();
	    elemns = undefined;
	    parts  = undefined;
    } else {
    	stats  = 0;
    	states = 0;
    	elemns = 0;
    	parts  = 0;
    }
    
    #region Metodos
    /// @param stat
    /// @param state
    /// @param element
    /// @param part
    static SetComponents = function(_stat, _state, _elemn, _part) {
        stat  = _stat ;
        state = _state;
        elemn = _elemn;
        part  = _part ;
        
        return self;
    }
    
    /// @desc Todas las variables son puestas como un array
    static AllSetArray = function() {
        stat  = [];
        state = [];
        elemn = [];
        part  = [];
        
        return self;
    }
    
    	#region Array
    static AddStat  = function(_value) {
    	if (is_array(stat) ) array_push(stat, _value);
    }
    
    static AddState = function(_value) {
    	if (is_array(state) ) array_push(state, _value);	
    }
    
    static AddPart  = function(_value) {
    	if (is_array(part) )  array_push(part, _value);	
    } 
    
    static AddElement = function(_value) {
    	if (is_array(elemn) ) array_push(elemn, _value);	
    }

    
    #endregion
    
    #endregion
}

function __mall_group_control() constructor {
    group = [];
    index =  0; // Para cambiar de grupo hay que cambiar el indice

    #region Metodos
    static Create = function(_name) {
        var _count = array_length(group);
        index = _count; // Poner el puntero donde corresponde
        
        array_push(group, (new __mall_class_group(_name, _count) ) );

        return self;
    }
    
    /// @param index*
    /// @returns {__mall_class_group}
    static GetGroup = function(_ind) {	
		if (_ind == undefined) _ind = index;
		
		if (_ind != index) index = _ind;
		
        return (group[index] );    
    }
    
    	#region Stats
    static CustomizeStat = function(_name, _start = 0, _master, _levelformula, _levelmax) {
        var _stats = GetGroup().stats; // Obtener grupo
        var _stat  = (new __mall_class_stat(_name, _start) );
        
        // Si no se establecio un master entonces agregar la formula
        if (!_stat.SetFather(_master) ) {
        	_stat.SetLevelUp(_levelformula, _levelmax);
        }
        
        // Establecer finalmente estadistica
        variable_struct_set(_stats, _name, _stat);

        return _stat;        
    }
    
    /// @param stat_name
    static GetStat = function(_name) {
        return (GetGroup().stats[$ _name] );
    }

    #endregion
    
    	#region States
    /// @param name
    /// @param start
    /// @param resistance
    /// @param hud_name*
    static CustomizeState = function(_name, _start, _rest, _hudname) {
    	var _states = GetGroup().states;
        var _state  = (new __mall_class_state(_name, _start, _rest, _hudname) );
        
		
	    variable_struct_set(_states, _name, _state);

        return _state;
    }
    
    /// @param name
    static GetState = function(_name) {
    	return (GetGroup().states[$ _name] );
    }

    #endregion
    
    	#region Elements
    
    /// @param element_name
    /// @param attack_stat
    /// @param defend_stat
    /// @param produce_state
    /// @param produce_value...
    static CustomizeElement = function(_name, _ataq, _rest, _produce, _chance) {
    	var _elemns = GetGroup().elemns;
	    var _elemn  = (new __mall_class_element(_name) );
	    
		// Establecer
		_elemn.Interaction(_ataq, _rest).Produce(_produce, _chance);
		
	    variable_struct_set(_elemns, _name, _elemn);

	    return (_elemn);    	
    }
    
    /// @param element_name
    static GetElement = function(_name) {
    	return (GetGroup() ).elemns[$ _name];	
    }
    
    #endregion
    
    	#region Parts
    static CustomizePart = function(_name, _itemtype) {
    	var _parts = GetGroup().parts;
	    var _part  = (new __mall_class_part(_name, _itemtype) );
		
	    variable_struct_set(_parts, _name, _part);

	    return (_part);    	
    }	
    	
    /// @param part_name
    static GetPart = function(_name) {
    	return (GetGroup() ).parts[$ _name];
    }	
    	
    #endregion
    
    /// @param {__mall_class_stat} stat_class
    static AddStat = function(_stat) {
    	GetGroup().stat = _stat;
        
        return self;
    }

    /// @param {__mall_class_state} state_class    
    static AddState = function(_state) {
        static statecount = 0;
        
        var _gstates = global._MALL_GLOBAL.statenames;
        var _gorder  = global._MALL_GLOBAL.state;
        
        var _names = _state.order;
        
        repeat(each(_names) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gstates, in) ) {
            	variable_struct_set(_gstates, in, statecount);
                array_push(_gorder, in);
            
                statecount++;
            }
        }        

        GetGroup().state = _state;
        return self;        
    }
    
    /// @param {__mall_class_element} element_class
    static AddElement = function(_elemn) {
        static elemncount = 0;
        
        var _gelemn = global._MALL_GLOBAL.elmnnames;
        var _gorder = global._MALL_GLOBAL.elmn;
        
        var _order  = _elemn.order;
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gelemn, in) ) {
                array_push(_gorder, in);
                variable_struct_set(_gelemn, in, elemncount);
            
                elemncount++;
            }
        }
        
        GetGroup().elemn = _elemn;
        return self;        
    }
    
    /// @param {__mall_class_part} part_class
    static AddPart    = function(_part)  {
        static partcount = 0;
        
        var _gpart  = global._MALL_GLOBAL.partnames;
        var _gorder = global._MALL_GLOBAL.part;
        
        var _order = _part.order;
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gpart, in) ) {
                array_push(_gorder, in);
                variable_struct_set(_gpart, in, partcount);
            
                partcount++;
            }
        }
        
        GetGroup().part = _part;
        return self;
    }

        #region Obtener controladores
    static ControlStat  = function() {
        return GetGroup().stat;
    }

    static ControlState = function() {
        return GetGroup().state;
    }
    
    static ControlElements = function() {
        return GetGroup().elemn;
    }
    
    static ControlPart = function() {
        return GetGroup().part;   
    }
    
    #endregion
 
    #endregion
}

/// @param default_group
/// @returns {__mall_group_control}
function mall_group_init(_default = "Default") {
    static groupControl = (new __mall_group_control() ).Create(_default);
  
    return (groupControl);
}

/// @param group_name
function mall_group_create(_name) {
    MALL_MASTER.MasterCreate(_name);
}

function mall_group_change(_ind)  {
    MALL_MASTER.index = _ind;
}








