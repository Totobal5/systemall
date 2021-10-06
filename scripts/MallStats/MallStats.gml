/// @param stat_name
/// @param stat_index
function __mall_class_stat(_name = "", _index = -1) : __mall_class_parent("MALL_STAT_INTERN") constructor {
    // Lo basico
    SetBasic(_name, _index);

    // Master : Otra estadistica, no puede ser mayor que esta y solo master puede aumentar sus atributos mediante lvlup
    //	Así mismo no son tomados en cuenta para ser dibujados directamente.
    master = undefined;
    master_name = "";
    
    children = [];

    watched = {};   // Que estado es observado
    used    = {};   // Que partes lo usan
    
    absorb = [];    // Que elemento absorbe
    reduce = [];    // Que elemento reduce    
    
    //////////////////////////////////////////////////
    start = 0;	// Valor inicial
    
    range_max = 0;
    range_min = 0;
    
    lvlup  = function(old, base, lvl) {return old; };
    lvlmax = 100; 
    
    tomin = false;		// Si al subir de nivel se devuelve al valor minimo
	tomin_max    = 0;
	tomin_repeat = false;
	
    tomax = false;		// Si al subir de nivel se devuelve al valor del maestro
	tomax_max    = 0;
	tomax_repeat = false;

    #region Metodos
    	#region Family
    /// @param {__mall_class_stat} stat_class
    static SetMaster = function(_stat) {
        if (is_struct(_stat) ) {
        	array_push(_stat.children, name); // Agregar hijos
        	
            master      = _stat;
            master_name = _stat.name;
            
            range_max = _stat.range_max;
            range_min = _stat.range_min;
            
            // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
            SetLevelUp(undefined);
            
            return  true;        
        }

        return false;
    }
    
    static GetChildren = function(_index) {
    	return (children[_index] );
    }
    
    /// @returns {number}
    static GetChildrenCount = function() {
    	return (array_length(children) );
    }

    /// @param {__mall_class_stat} stat_class
    /// @desc Hereda la formula y rangos de otro estado, pero no es su maestro
    static Inherit = function(_stat) {
        range_max = _stat.range_max;
        range_min = _stat.range_min;
            
        // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
        SetLevelUp(_stat.GetLvlUp(), lvlmax);
        
        start = _stat.start;
    	
        return self;
    }
    
    #endregion
    
    /// @param range_min
    /// @param range_max
    static Limits = function(_min, _max) {
        range_min = _min;
        range_max = _max;
        
        return self;
    }
	
	/// @param repeat?
	/// @param min
	static ToggleToMin = function(_repeat = true, _min = 0) {
		tomin = !tomin;
		
		tomin_max	 = _min;
		tomin_repeat = _repeat;
		
		return self;
	}
	
	/// @param repeat?
	/// @param max
	static ToggleToMax = function(_repeat = true, _max = 0) {
		tomax = !tomax;
		
		tomax_max	 = _max;
		tomax_repeat = _repeat; 
		
		return self;
	}
	

    /// @param state_class
    /// @param values
    static AddWatched = function(_state, _values) {
        var _name = _state.name;
        
        if (!variable_struct_exists(watched, _name) ) {
            variable_struct_set(watched, _name, _values);
        }
        
        return self;
    }
    
    /// @param watch_array
    static AddWatchedArray = function(_array) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) AddWatched(_array[i], _array[i + 1] );

        return self;
    }
    
    static AddAbsorb = function(_elmn) {
        array_push(absorb, _elmn.name);
        return self;
    }
    
    static AddAbsorbArray = function(_array) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) AddAbsorb(_array[i]);
        return self;
    }

    static AddReduce = function(_elmn) {
        array_push(reduce, _elmn.name);
        return self;
    }
    
    static AddReduceArray = function(_array) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) AddReduce(_array[i]);
        return self;
    }
   
    /// @returns {struct}
    static GetWatch = function() {
        return watched;
    }
    
    /// @returns {array}
    static GetRange = function() {
        return [range_min, range_max];
    }
    
    /// @returns {array}
    static GetMaster = function(_option = true) {
        return (_option) ? master : [master, master_name];
    }
    
		#region Level Up
    /// @param lvlup
    static SetLevelUp  = function(_lvlup, _max = 100) {
        lvlup  = _lvlup;
        lvlmax = _max;
        
        return self;
    }
	
	static SetLevelMax = function(_max) {
		lvlmax = _max;
		return self;
	}
	
    static GetLevelUp  = function() {
        return lvlup;
    }
    
	#endregion
    
    #endregion
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


#region STAT

/// @returns {__mall_class_stat}
function mall_get_stat(_access) {
	if (is_numeric(_access) ) _access = global._MALL_GLOBAL.stats[_access];
	
    return (mall_group_init() ).GetStat(_access);
}

/// @returns {__mall_class_stat}
function mall_stat_customize(_name, _start, _master, _levelformula, _levelmax) {
	if (!mall_stat_exists(_name) ) return noone;
	
    return (mall_group_init() ).CustomizeStat(_name, _start, _master, _levelformula, _levelmax);
}

/// @param name
/// @returns {bool}
function mall_stat_exists(_name) {
	return (variable_struct_exists(global._MALL_GLOBAL.statsnames, _name) );
}

function mall_stat_get_master(_access, _option) {
    return (mall_get_stat(_access) ).GetMaster(_option);
}

/// @returns {array}
function mall_stat_get_watch(_access) {
    return (mall_get_stat(_access) ).GetWatch();  
}

/// @returns {array}
function mall_stat_get_range(_access) {
    return (mall_get_stat(_access) ).GetRange();    
}

#endregion