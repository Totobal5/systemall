global._MALL_STORAGE = {
    stats : [], statsnames  : {},
    states: [], statesnames : {}, 
    
    elemns:  [], elemnsnames: {}, 
    parts :  [], partsnames: {},
    
    dark:     [], darknames:     {}, darksubnames: {},
    itemtype: [], itemtypenames: {}, itemsubnames: {},
    
    pocket:   [], pocketnames:   {}, pocketitemtype: {}
}

#macro MALL_CONTROL mall_group_init()
#macro MALL_STORAGE global._MALL_STORAGE

#macro MALL_LOCALIZE true // Si utiliza las funciones de localizacion

#macro MALL_KEYSTART_STAT		"MALL_STAT."
#macro MALL_KEYSTART_STATE		"MALL_STATE."
#macro MALL_KEYSTART_ELEMENT	"MALL_ELEMENT."
#macro MALL_KEYSTART_PART		"MALL_POCKET."

#macro MALL_NAME ".NAME"
#macro MALL_DES  ".DESC"
#macro MALL_TXT  ".TXT"




/// @param name
/// @param index
function __mall_class_group(_name, _index = -1, _notinit = false) constructor { 
    #region Inside
    __mall = "MALL";
    __is   = "MALL_GROUP_INTERN";   
    
    #endregion
    
    name  = _name ;
    index = _index;
    
	stats  = undefined;
	states = undefined;
	elemns = undefined;
	parts  = undefined;
    
    if (!_notinit) {
	    stats  = mall_stats_copy ();
	    states = mall_states_copy();
	    elemns = mall_elements_copy();
	    parts  = mall_parts_copy();
    }
}

function __mall_group_control() constructor {
    group = [];
    index =  0; // Para cambiar de grupo hay que cambiar el indice

    #region Metodos
    static Create = function(_name)  {
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
    mall_group_init().Create(_name);
}

function mall_group_change(_ind)  {
    mall_group_init().index = _ind;
}

