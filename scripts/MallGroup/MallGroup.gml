/// @param name
/// @param index
function __mall_class_group(_name, _index = -1) : __mall_class_parent("MALL_GROUP_INTERN") constructor { 
    #region Interno
    __mall = "MALL";
    __is   = "MALL_GROUP_INTERN";

    #endregion    
    
    name  = _name ;
    index = _index;
    
    stats  = mall_stats_copy();
    states = undefined;
    elemns = undefined;
    parts  = undefined;
    
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
        var _stat  = (new __mall_class_stat(_name) );
        
        // Si no se establecio un master entonces agregar la formula
        if (!_stat.SetMaster(_master) ) {
        	_stat.SetLevelUp(_levelformula, _levelmax);
        }
        
        _stats[$ _name] = _stat;

        return _stat;        
    }
    
    /// @param stat_name
    static GetStat = function(_name) {
        return (GetGroup().stats[$ _name] );
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

/// @param mall_stat
function mall_group_add_stat(_stat)     {
    MALL_MASTER.AddStat(_stat);
}

/// @param mall_state
function mall_group_add_state(_state)   {
    MALL_MASTER.AddState(_state);
}

/// @param mall_element
function mall_group_add_element(_elmn)  {
    MALL_MASTER.AddElement(_elmn);
}

/// @param mall_part
function mall_group_add_part(_part)     {
    MALL_MASTER.AddPart(_part);
}