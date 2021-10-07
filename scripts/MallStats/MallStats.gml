/// @param stat_name
/// @param stat_index
function __mall_class_stat(_name = "", _start = 0) : __mall_class_parent("MALL_STAT_INTERN") constructor {
    // Lo basico
    SetBasic(_name);

    // Father : Otra estadistica, no puede ser mayor que esta y solo master puede aumentar sus atributos mediante lvlup
    //	Así mismo no son tomados en cuenta para ser dibujados directamente.
    father = undefined;
    father_name = "";
    
    children = [];
	
	watched = [];	// Que state observa
	
    //////////////////////////////////////////////////
    start = _start;	// Valor inicial
    
    limit_max = 0;
    limit_min = 0;
    
    lvlup  = function(old, base, lvl) {return old; };
    lvlmax = 100; 
    
    tomin = false;		// Si al subir de nivel se devuelve al valor minimo
	tomin_max    = 0;
	tomin_repeat = false;
	
    tomax = false;		// Si al subir de nivel se devuelve al valor del maestro
	tomax_max    = 0;
	tomax_repeat = false;

    #region Metodos
    	#region Heritage
    /// @param {__mall_class_stat} stat_class
    /// @desc Hereda la formula y rangos de otro estado, pero no es su maestro
    static Inherit = function(_stat) {
        limit_min = _stat.limit_min;
        limit_max = _stat.limit_max;

        // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
        SetLevelUp(_stat.GetLvlUp(), lvlmax);
        
        start = _stat.start;
    	
        return self;
    }
    
    /// @param {__mall_class_stat} stat_class
    static SetFather = function(_stat) {
        if (is_struct(_stat) ) {
        	array_push(_stat.children, name); // Agregar hijos
        	
            father      = _stat;
            father_name = _stat.name;

            limit_min = _stat.limit_min;            
            limit_max = _stat.limit_max;

            // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
            SetLevelUp(undefined);
            
            return  true;        
        }

        return false;
    }
    
    /// @returns {array}
    static GetFather = function() {
        return (father);
    }
    
    /// @param index
    static GetChildren = function(_index) {
    	return (children[_index] );
    }
    
    /// @returns {number}
    static GetChildrenCount = function() {
    	return (array_length(children) );
    }

    #endregion
    
    /// @param range_min
    /// @param range_max
    static Limits = function(_min, _max) {
        range_min = _min;
        range_max = _max;
        
        return self;
    }
	
	/// @returns {array} [0:min 1:max]
	static GetLimits = function() {
		return [limit_min, limit_max];	
	}
	
	/// @param repeat?
	/// @param min
	static ToMin = function(_repeat = true, _min = 0) {
		tomin = !tomin;
		
		tomin_max	 = _min;
		tomin_repeat = _repeat;
		
		return self;
	}
	
	/// @param repeat?
	/// @param max
	static ToMax = function(_repeat = true, _max = 0) {
		tomax = !tomax;
		
		tomax_max	 = _max;
		tomax_repeat = _repeat; 
		
		return self;
	}
	
		#region Watch
	/// @param {string} state_name
	/// @param value
	static WatchState = function(_statename, _value) {
		array_push(watched, [_statename, _value] );
		return self;
	}
	
	
	#endregion
	
		#region Level Up
    /// @param lvlup
    /// @param {number} max_level?
    static SetLevelUp  = function(_lvlup, _max = 100) {
        lvlup  = _lvlup;
        lvlmax = _max;
        
        return self;
    }
	
	/// @returns {number}
	static SetLevelMax = function(_max) {
		lvlmax = _max;
		return self;
	}
	
	/// @returns {script}
    static GetLevelUp  = function() {
        return (lvlup);
    }
    
	#endregion
    
    #endregion
}

/// @desc Crea las estadisticas que todos poseen
function mall_create_stats() {
    var _order = mall_stats();
    var _stats = mall_stats_names();
    
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