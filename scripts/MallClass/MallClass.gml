global._MALL_GLOBAL = {
    stats: [], statsnames:  {}, 
    state: [], statenames:  {}, 
    elmn:  [], elmnnames:   {}, 
    part:  [], partnames:   {},
    
    dark:     [], darknames:     {},   
    itemtype: [], itemtypenames: {}, itemsubnames: {},
    pocket:   [], pocketnames:   {}
}

global._MALL_MASTER   = -1;

#macro MALL_MASTER mall_group_init()

#macro MALL_CONT_STATS MALL_MASTER.ControlStat    ()
#macro MALL_CONT_STATE MALL_MASTER.ControlState   ()
#macro MALL_CONT_ELEMN MALL_MASTER.ControlElements()
#macro MALL_CONT_PARTS MALL_MASTER.ControlPart    ()


#macro MALL_ITEMTYPE		global._MALL_GLOBAL.itemtypenames
#macro MALL_ITEMTYPE_SUB	global._MALL_GLOBAL.itemsubnames
#macro MALL_ITEMTYPE_ORDER	global._MALL_GLOBAL.itemtype

#macro MALL_DARK_TYPE  global._MALL_GLOBAL.darknames
#macro MALL_DARK_ORDER global._MALL_GLOBAL.dark

#macro MALL_POCKET_TYPE  global._MALL_GLOBAL.pocketnames
#macro MALL_POCKET_ORDER global._MALL_GLOBAL.pocket

/// @param is
function __mall_class_parent(_is) constructor {
    #region Interno
    __mall = "MALL";
    __is = _is;
    // __context = weak_ref_create(self);   // Referencia así mismo.
    
    #endregion
	
	key = "";
	index = -1;
	
	// Para trabajar con una gui
    name = "";
    des  = "";
    ext  = [];

    txt    = name;
    symbol = "";
    
    is_porcent = false; // Si es basado en porcentaje     
    
    #region Metodos
    static SetBasic  = function(_name, _index) {
        name  = _name;
        index = _index;
        
        txt = name;
        
        return self;
    }
    
    static SetString = function(_txt, _symbol, _porcent = false) {
        var _scr = MALL_LOCAL.GetTranslate();
        
        var _new = (!is_undefined(_scr) ) ? _scr(_txt) : _txt;

        txt     = _new;
        symbol  = _symbol;
        
        is_porcent = _porcent;
        
        return self;
    }
    
    static TogglePorcent = function() {
        is_porcent = !is_porcent;
        return self;
    }
    
    /// @param name
    /// @param class
    /// @desc Permite vincular una clase de mall a alguna estructura de otro sistema
    static Vinculate = function(_name, _value) {
        if (is_struct(_value) ) {
            if (!variable_struct_exists(self, _name) ) {
                variable_struct_set(self, _name, _value);
            }    
        }
        
        return self;
    }
    
    /// @param struct_name
    static GetStruct = function(_name) {
    	return (variable_struct_get(self, _name) );
    }
    
    /// @param struct
    /// @param override
    /// @desc Permite sobrescribir todos los valores de una estructura
    static Override = function(_struct_name, _value) {
    	var _struct = GetStruct(_struct_name);
  
    	if (!is_struct(_struct) ) return false;
    	
    	var _names = variable_struct_get_names(_struct), i = 0;
    	
    	repeat(array_length(_names) ) {variable_struct_set(_struct, _names[i], _value); ++i; }
    	
    	return self;
    }
    
    /// @param struct
    /// @param multiply
    static Multiply = function(_struct_name, _mult) {
    	var _struct = GetStruct(_struct_name);
  
    	if (!is_struct(_struct) ) return false;
    	
    	var _names = variable_struct_get_names(_struct), i = 0;
    	
    	repeat(array_length(_names) ) {
    		var _name = _names[i], in = variable_struct_get(_struct, _name);

			if (is_numeric(in) ) variable_struct_set(_struct, _name, round(in * _mult) );
			
    		++i; 
    	}
    	
		return self;    	
    }
    
    /// @desc Pasa los valores de un struct al contrario (1 -> -1)
    static Turn = function(_struct) {
    	if (is_string(_struct) ) _struct = self[$ _struct];
    	
    	if (!is_struct(_struct) ) return false;
    	
    	var _names = variable_struct_get_names(_struct);
    	
    	var i = 0; repeat(array_length(_names) ) {
    		var _name = _names[i], in = _struct[$ _name];
    		
    		if (is_numeric(in) ) in *= -1;
    		
    		variable_struct_set(_struct, _name, in);
    		
    		++i;
    	}
    	
    	return self;
    }
    
    static GetName  = function() {
    	return name;
    }
        
    static GetBasic = function() {
        return [name, index];
    }
    
    static GetString = function() {
        return [txt, symbol];
    }
    
    static IsPorcent = function() {
        return is_porcent;
    }
    
    static GetType   = function() {
        return __is;
    }
    
    	#region Misq
    static Copy = function() {}
    
    #endregion
    
    #endregion
}

function __mall_class_data(_value, _proccess = "+") constructor {
	#region Metodos
	__isdata = "MALL_DATA";
	
	static IsPorcent = function(_value) {
		return ( (is_string(_value) ) && (string_char_at(_value, string_length(_value) + 1) == "%") );
	}
	
	static ConvertPorcent = function(_value) {
		if (IsPorcent(_value) ) {
			return real( (string_delete(_value, string_length(_value) + 1, 1) ) ) / 100;	
		}	
		
		return 0;
	}
	
	static Set = function(_value) {
		value = (IsPorcent(_value) ) ? ConvertPorcent(_value) : _value;
	}
	
	/// @param proceso
	static Change = function(_proccess) {
		proccess = _proccess;
	}
	
	// "200%"
	
	#endregion
	
	num = (IsPorcent (_value) ) ? ConvertPorcent(_value) : _value;	// Si es string lo pasa a numero
	str = (is_numeric(_value) ) ? string(_value) : _value;			// Si es numero lo pasa a string
	
	pro = _proccess;	// Que funcion realizar
	
	gc_collect();
}

/// @returns {__mall_class_data}
function Data(_value) {
	return (new __mall_class_data(_value) );
}

/// @param data_struct
function is_data(_data) {
	return (is_struct(_data) && variable_struct_exists(_data, "__isdata") );	
}

/// @returns {array} all_stats
function mall_global_stats  () {
    return (global._MALL_GLOBAL.stats);   
}

/// @returns {array} all_states
function mall_global_states () {
    return (global._MALL_GLOBAL.state);
}

/// @returns {array} all_elements
function mall_global_elements() {
    return (global._MALL_GLOBAL.elmn);
}

/// @returns {array} all_parts
function mall_global_parts() {
    return (global._MALL_GLOBAL.part);
}

#region Is
/// @param group_id
function is_mall_group(_class) {
    return (is_struct(_class) && _class.__is == "MALL_GROUP_INTERN");
}

/// @param mall_class
/// @returns {bool}
function is_mall_stat   (_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_STAT_INTERN") );
}

/// @param mall_class
/// @returns {bool}
function is_mall_state  (_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_STATE_INTERN") );
}

/// @param mall_class
/// @returns {bool}
function is_mall_element(_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_ELEMENT_INTERN") );   
}

/// @param mall_class
/// @returns {bool}
function is_mall_part   (_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_PART_INTERN") );     
}

#endregion

#region Group
/// @param name
/// @param index
function __mall_class_group(_name, _index) : __mall_class_parent("MALL_GROUP_INTERN") constructor { 
    SetBasic(_name, _index);
    
    stat  = undefined;
    state = undefined;
    elemn = undefined;
    part  = undefined;
    
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
    
    #endregion
}

function mall_group_control () : __mall_class_parent("MALL_GROUP") constructor {
    group = [];
    index =  0; // Para cambiar de grupo hay que cambiar el indice

    #region Metodos
    static Create = function(_name) {
        static createcount = 0;
        
        array_push(group, (new __mall_class_group(_name, createcount) ) );
        createcount++;
        
        return self;
    }
    
    /// @param index*
    /// @returns {__mall_class_group}
    static GetGroup = function(_ind) {
        if (index == undefined) index = _ind;

        return (group[index] );    
    }
    
    /// @param {__mall_class_stat} stat_class
    static AddStat = function(_stat) {
        static statcount = 0;
        
        var _gstats = global._MALL_GLOBAL.statsnames;
        var _gorder = global._MALL_GLOBAL.stats;
        
        var _order  = _stat.order; 
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gstats, in) ) {
                array_push(_gorder, in);
                variable_struct_set(_gstats, in, statcount);
            
                statcount++;
            }
        }
 
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
function mall_group_init(_group_name = "Default") {
    static racecontrol = (new mall_group_control() ).Create(_group_name);
    global._MALL_MASTER = racecontrol;
    
    return (global._MALL_MASTER );
}

/// @param group_name
function mall_group_create(_name) {
    MALL_MASTER.MasterCreate(_name);
}

function mall_group_change(_ind)  {
    MALL_MASTER.index = _ind;
}

#region Group Add
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

#endregion


#endregion

#region Stats
/// @param stat_name
/// @param stat_index
function __mall_class_stat(_name = "", _index = -1) : __mall_class_parent("MALL_STAT_INTERN") constructor {
    // Lo basico
    SetBasic(_name, _index);
    
    // Referencia al controlador
    outside = undefined;
    
    // Master : Otra estadistica, no puede ser mayor que esta y solo master puede aumentar sus atributos mediante lvlup
    master = undefined;
    master_name = "";
    
    range_max = 0;
    range_min = 0;
    
    lvlup  = function(old, base, lvl) {return old; };
    lvlmax = 100; 
    
    tomin = false;		// Si al subir de nivel se devuelve al valor minimo
	tomin_max    = 0;
	tomin_repeat = false;
	
    tomax = false;	// Si al subir de nivel se devuelve al valor del maestro
	tomax_max    = 0;
	tomax_repeat = false;
    
    watched = {};   // Que estado es observado
    used    = {};   // Que partes lo usan
    
    absorb = [];    // Que elemento absorbe
    reduce = [];    // Que elemento reduce
    
    #region Metodos
    
    /// @param {__mall_class_stat} stat_class
    /// @desc Hereda la formula y rangos de otro estado, pero no es su maestro
    static Inherit = function(_stat) {
        range_max = _stat.range_max;
        range_min = _stat.range_min;
            
        // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
        SetLvlUp(_stat.GetLvlUp() );
        
        return self;
    }
    
    /// @param {__mall_class_stat} stat_class
    static SetMaster = function(_stat) {
        if (is_struct(_stat) ) {
            master      = _stat;
            master_name = _stat.name;
            
            range_max = _stat.range_max;
            range_min = _stat.range_min;
            
            // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
            SetLvlUp(undefined);
            
            return  true;        
        }

        return false;
    }
    
    /// @param lvlup
    static SetLvlUp  = function(_lvlup, _max = 100) {
        lvlup  = _lvlup;
        lvlmax = _max;
        
        return self;
    }

	static SetLvlMax = function(_max) {
		lvlmax = _max;
		return self;
	}
	
    /// @param range_min
    /// @param range_max
    static SetRange = function(_min, _max) {
        range_min = _min;
        range_max = _max;
        
        return self;
    }

	static ToggleToMin = function(_max = 0, _repeat = true) {
		tomin = !tomin;
		
		tomin_max	 = _max;
		tomin_repeat = _repeat;
		
		return self;
	}
	
	static ToggleToMax = function(_max = 0, _repeat = true) {
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
            variable_struct_set(watched, _name, {state: _name, val: _values} );
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
    
    static GetLvlUp  = function() {
        return lvlup;
    }
    
    #endregion
}

function mall_stat_control () : __mall_class_parent("MALL_STAT") constructor {
    #region Variables
    order = []; // Estadisticas agregadas
    stats = {};
    
    #endregion
    
    #region Metodos
    static Add = function(_name, _master, _formula) {
        static statcount = 0;
        
        if (!variable_struct_exists(stats, _name) ) {
            var _stat = (new __mall_class_stat(_name, statcount) );
            _stat.outside = self;

            // Si no se establecio un master entonces agregar la formula
            if (!_stat.SetMaster(_master) ) _stat.SetLvlUp(_formula);
            
            variable_struct_set(stats, _name, _stat);
            array_push(order, _name);
            
            statcount++;
            
            return _stat;
        }
        
        return noone;
    }
    
    static GetNames = function() {
        return order;
    }
    
    static GetCount = function() {
        return array_length(order);
    }
    
    /// @param stat
    static Get = function(_name) {
        return (is_string(_name) ) ? stats[$ _name] : GetIndex(_name); 
    }
    
    /// @param index
    static GetIndex = function(_index) {
        return stats[$ order[_index] ];
    }
    
    #endregion
}

function mall_get_stat(_access) {
    return (MALL_CONT_STATS.Get(_access) );
}

/// @param name
/// @returns {bool}
function mall_stat_exists(_name) {
	return (variable_struct_exists(global._MALL_GLOBAL.statsnames, _name) );
}

/// @returns {array}
function mall_stat_get_names() {
    return (MALL_CONT_STATS.GetNames() );
}

/// @returns {number}
function mall_stat_get_count() {
    return (MALL_CONT_STATS.GetCount() );
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

#region States
/// @param state_name
/// @param state_index
/// @param state_init
function __mall_class_state(_name = "", _index = -1, _init = false) : __mall_class_parent("MALL_STATE_INTERN") constructor {
    SetBasic(_name, _index);
    
    init = _init;
    
    processes = {}; // Procesos que puede ejecutar.
    
    watch_stat = [];    // Que estadistica lo vigilan
    watch_part = [];    // Que partes lo vigilan    
    
    #region Metodos
    static Get = function() {
        return init;
    }
    
    /// @param init_value
    static SetInit = function(_init) {
        init = _init;
        
        return self;
    }
    
    static SetProcess = function(_name, _values) {
        if (!variable_struct_exists(processes, _name) ) {
            variable_struct_set(processes, _name, {value: _values, name: _name} );
        }
        
        return self;
    }
    
    /// @param process_array
    static SetProcessArray = function(_array = []) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) SetProcess(_array[i], _array[i + 1] );

        return self;
    }

    static GetProcesses = function() {
        return processes;
    }
    
    	#region Watch
    /// @param stat_class
    /// @param values
    /// Necesita que el anterior sea un stat
    static SetWatchStat = function(_stat, _values) {
        if (is_struct(_stat) ) {
            _stat.AddWatched(self, _values);
            array_push(watch_stat, _stat.name);
        }
    
        return self;
    }
    
    /// @param watch_array
    static SetWatchStatArray = function(_array = []) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) SetWatchStat(_array[i], _array[i + 1] );        

        return self;          
    }
    
    /// @returns {array}
    static GetWatchStat = function() {
        return watch_stat;
    }
    
    /// @returns {array}
    static GetWatchPart = function() {
        return watch_part;
    }
    
    #endregion
   
	static Copy = function() {}
   
    #endregion
}

function mall_state_control() : __mall_class_parent("MALL_STATE") constructor {
    order = [];
    state = {};
    
    #region Metodos
    static Add = function(_name, _init, _watch) {
        static statecount = 0;
        
        if (!variable_struct_exists(state, _name) ) {
            var _state = (new __mall_class_state(_name, statecount, _init) ).SetWatchStatArray(_watch);

            variable_struct_set(state, _name, _state);
            
            array_push(order, _name);
            statecount++;
            
            return _state;
        }             
    }

    static GetNames = function() {
        return order;
    }
    
    static GetCount = function() {
        return array_length(order);
    }
    
    static Get = function(_name) {
        return (is_string(_name) ) ? state[$ _name] : GetIndex(_name);
    }
    
    static GetIndex = function(_ind) {
        return state[$ order[_ind] ];        
    }

    #endregion
}

/// @param name
/// @returns {bool}
function mall_state_exists(_name) {
	return (variable_struct_exists(global._MALL_GLOBAL.statenames, _name) );	
}

/// @returns {__mall_class_state}
function mall_get_state(_access) {
    return (MALL_CONT_STATE.Get(_access) );
}

/// @returns {array}
function mall_state_get_names() {
    return (MALL_CONT_STATE.GetNames() );
}

/// @returns {number}
function mall_state_get_count() {
    return (MALL_CONT_STATE.GetCount() );
}

function mall_state_get_watch_stat(_access) {
    return (mall_get_state(_access) ).GetWatchStat();
}

function mall_state_get_watch_part(_access) {
    return (mall_get_state(_access) ).GetWatchPart();   
}

function mall_state_get_processes (_access)  {
    return (mall_get_state(_access) ).GetProcesses();
}

#endregion

#region Elements
/// @param element_name
/// @param element_index
function __mall_class_element(_name = "", _index = -1) : __mall_class_parent("MALL_ELEMENT_INTERN") constructor {
    // Lo basico
    SetBasic(_name, _index);
    
    absorb = []; // Una estadistica se puede beneficiar del elemento
    reduce = []; // Una estadistica se puede perjudiciar del elemento
    
    produce = {}; // Probabilidad de producirlos estados
    
    #region Metodos
    
    /// @param state_name
    /// @param value
    static AddProduce = function(_state, _values) {
        var _name = _state.name;
        
        if (!variable_struct_exists(produce, _name) ) {
            variable_struct_set(produce, _name, {name: _name, values: _values} ); 
        }
    
        return self;
    }
    
    /// @param produce_array
    static AddProduceArray = function(_array) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) AddProduce(_array[i], _array[i + 1] );        
        return self;
    }
    
    static AddAbsorb = function(_stat) {
        array_push(absorb, _stat.name);
        _stat.AddAbsorb(self);
        
        return self;   
    }

    static AddAbsorbArray = function(_array) {
        for (var i = 0, _len = array_length(_array) - 1; i < _len; ++i) AddAbsorb(_array[i]);  

        return self;   
    }
    
    static AddReduce = function(_stat) {
        array_push(reduce, _stat.name);
        _stat.AddReduce(self);
        
        return self;          
    }
    
    static AddReduceArray = function(_stat) {
        for (var i = 0, _len = array_length(_array); i < _len; ++i) AddReduce(_array[i] ); 

        return self;          
    }
    
    static GetProduce = function(_state_name) {
        return (is_undefined(_state_name) ) ? produce : produce[$ _state_name];
    }
    
    static GetProduceAll = function() {
        return produce;
    }
    
    #endregion
}

function mall_element_control() : __mall_class_parent("MALL_ELEMENT") constructor {
    order = [];
    elemn = {};
    
    #region Metodos
    static Add = function(_name, _produce) {
        static elmncount = 0;
        
        if (!variable_struct_exists(elemn, _name) ) {
            var _elemn = (new __mall_class_element(_name, elmncount) ).AddProduceArray(_produce);

            variable_struct_set(elemn, _name, _elemn);
            
            array_push(order, _name);
            elmncount++;
            
            return _elemn;
        }    
    }

    /// @returns {array}
    static GetNames = function() {
        return order;
    }
    
    /// @returns {number}
    static GetCount = function() {
        return array_length(order);
    }
    
    /// @returns {__mall_class_element}
    static Get = function(_name) {
        return (is_string(_name) ) ? elemn[$ _name] : GetIndex(_name);
    }
    
    /// @returns {__mall_class_element}
    static GetIndex = function(_ind) {
        return elemn[$ order[_ind] ];        
    }

    #endregion
}

/// @param name
function mall_element_exists(_name) {
	return (variable_struct_exists(global._MALL_GLOBAL.elmnnames, _name) );
}

/// @returns {__mall_class_element}
function mall_get_element(_access) {
    return (MALL_CONT_ELEMN.Get(_access) );
}

/// @returns {array}
function mall_element_get_names() {
    return (MALL_CONT_ELEMN.GetNames() );
}

/// @returns {number}
function mall_element_get_count() {
    return (MALL_CONT_ELEMN.GetCount() );
}

/// @returns {struct}
function mall_element_get_produce(_access, _state_name) {
    return (mall_get_element(_access) ).GetProduce(_state_name);  
}

/// @returns {array}
function mall_element_get_absorb(_access) {
    return (mall_get_element(_access) ).absorb;
}

/// @returns {array}
function mall_element_get_reduce(_access) {
    return (mall_get_element(_access) ).reduce;    
}

#endregion

#region Parts

/// @param name
/// @param index
function __mall_class_part(_name = "", _index = -1) : __mall_class_parent("MALL_PART_INTERN") constructor {
    SetBasic(_name, _index);
    
    noitem = "noitem";	// Si no hay objeto equipado
    
    // Deterioro
    use_damage = false;	// Si utiliza la caracteriztica del damage
    
    damage_start = 0;	
    damage_min = noone;	// Si es noone entonces no posee un valor minimo del daño
    damage_max = 0;		// Si es noone entonces no posee un valor maximo del daño
    
    damage_txt = "dañado!";
    
    // Diccionarios
    possible = {};  // Que tipo de objetos puede llevar esta parte.
    prop = {};
    
    // Componentes que lo afectan
    link = (new __mall_class_group("", -1) ).AllSetArray();   /// @is {__mall_class_group}

    #region Metodos
	
	/// @param {string} no_item
	static SetNoItem = function(_noitem) {
		noitem = _noitem;
		return self;
	}
	
	/// @returns {string}
	static GetNoItem = function() {
		return noitem;
	}
	
    /// @param damage
    /// @param damage_min
    /// @param damage_max
    /// @param damage_txt
    static SetDamage = function(_start, _min, _max, _txt) {
        damage_start = _start;
        
        damage_min = _min;
        damage_max = _max;
        
        damage_txt = _txt;
        
        return self;
    }
    
    /// @param {__mall_class_part} part_class
    static SetDamageOther = function(_partclass) {
        damage_start = _partclass.damage_start;
        
        damage_min = _partclass.damage_min;
        damage_max = _partclass.damage_max;
        
        damage_txt = _partclass.damage_txt;
        
        return self;    		
    }
    
    /// @param {__mall_class_part} mall_class
    /// @desc Crea un link a otra clase de mall
    static AddLink = function(_class) {
        if (!is_struct(_class) ) return self;
        
        // No poder crear link a el mismo
        if (_class == self) return self;
        
        switch (_class.GetType() ) {
            case "MALL_STAT_INTERN"   : array_push(link.stat , _class); break;
            case "MALL_STATE_INTERN"  : array_push(link.state, _class); break;
            case "MALL_ELEMENT_INTERN": array_push(link.elemn, _class); break;
            case "MALL_PART_INTERN"   :
            	// Vincular entre ambos
            	var _link = GetLinkPartAll();
            	var _name = _class.GetName();
            	
            	if (!ExistsLinkPart(_name) ) {
            		array_push(_link, _class);
            		
            		UpdateComplement ();
            	}
            	/*
            	var _link = _class.GetLinkPartAll();
            	var _name = GetName();
            	
            	if (!_class.ExistsLinkPart(_name) ) {
            		array_push(_link, self);
            		
            		_class.UpdateComplement();
            	}
            	*/
            	break;
        }
        
        return self;
    }
    
    /// @param mall_class_array
    static AddLinkArray = function(_array) {
        if (!is_array(_array) ) return self;
        
        repeat(each(_array) ) AddLink(this.value);
        
        return self;
    }
	
	static ExistsLinkPart = function(_name) {
		var _array = link.part;
		var i = 0; repeat(array_length(_array) ) {
			var in = _array[i].GetName();
			
			if (in == _name) return true;
			
			++i;
		}
		
		return false;
	}
	
	static GetLinkPartNames = function() {
		return (variable_struct_get_names(link.part) );
	}
	
	static ResetLink = function() {
		link.AllSetArray();
		link.part = {};
		
		complement = min(1, variable_struct_names_count(link.part) );
	}
	
    #region Possible
    /// @param item_type
    /// @param item_subtypes
    /// @desc Se debe de asegurar que los objetos hayan sido creado antes!!
    static AddPossible = function(_itemtype) {
        if (mall_itemtypes_exists(_itemtype) ) variable_struct_set(possible, _itemtype, true);
        
        return self;
    }

    /// @param itemtype_array
    /// @desc Se debe de asegurar que los objetos hayan sido creado antes!!
    static AddPossibleArray = function(_array) {
    	if (!is_array(_array) ) return self;
    	
		repeat(each(_array) ) AddPossible(this.value);
		
        return self;
    }
    
    static AddPossibleOther = function(_possible) {
    	var _names = variable_struct_get_names(_possible);
		
		return (AddPossibleArray(_names) );
    }
    
    /// @param name
    /// @returns {bool} Si el itemtype es compatible
    static IsPossible = function(_name) {
    	return (variable_struct_exists(possible, _name) );
    }
    
    /// @param name
    /// @returns {bool} Si el subtype es compatible
    static IsPossibleSubtype = function(_name) {
    	var _type = mall_get_itemtype_by_subtype(_name);
    	
    	return (IsPossible(_type.name) );
    }
    
    #endregion
    
    #region Propiedades
	
    /// @param property_name
    /// @param property_value
    static AddProperty = function(_propname, _value) {
    	if (!ExistsProperty(_propname) ) variable_struct_set(prop, _propname, _value);	
    	
    	return self;
    }
    
    /// @param property_array
    static AddPropertyArray = function(_array) {
    	var i = 0; repeat(array_length(_array) - 1) {
    		AddProperty(_array[i], _array[i + 1] );
    		
    		++i;
    	}
    	
    	return self;
    }
    
    static AddPropertyOther = function(_prop) {
		var _names = variable_struct_get_names(_prop);

		var i = 0; repeat(array_length(_names) ) {
			var _name = _names[i], in = _part.GetProperty(_name);
			
			AddProperty(_name, in);
	
			++i;
		}
		
		return self;
    }
    
    /// @param property_name
    /// @param property_value
    static SetProperty = function(_propname, _value) {
    	if (ExistsProperty(_propname) ) variable_struct_set(prop, _propname, _value);
    	return self;
    }
    
    /// @param property_name
    static GetProperty = function(_propname) {
    	return (variable_struct_get(prop, _propname) );	
    }
    
    /// @param property_name
    /// @returns {bool}
    static ExistsProperty = function(_propname) {
    	return (variable_struct_exists(prop, _propname) );
    }
    
    #endregion
    
    /// @param {__mall_class_part} part_class
    /// @param link?
    /// @desc Hereda las propiedades de otra parte
    static Inherit = function(_part, _linked = false) {
        var _link = _part.link;
        
        ResetLink();
        
        #region Links
        AddLinkArray(_link.stat ); 
		AddLinkArray(_link.state); 
		AddLinkArray(_link.elemn);
		AddLinkArray(_link.part );
		
		#endregion
		
		SetDamageOther(_part);
		SetNoItem(_part.noitem);
		
		AddPossibleOther(_part.possible);
		AddPropertyOther(_part.prop);
		
        if (_linked) AddLink(_part);
        
        return self;
    }
	
	#region Getter´s
    /// @returns {array}
    static GetLinkStat    = function() {
        return link.stat;
    }
    
    /// @returns {array}
    static GetLinkState   = function() {
        return link.state;
    }
    
    /// @returns {array}
    static GetLinkElement = function() {
        return link.elemn;
    }

    /// @returns {array}
    static GetLinkPartAll = function() {
        return link.part;
    }
    
    #endregion
    
    #endregion
}

/// @desc Crea las ranuras para equipar objetos (mano, armadura, etc)
function mall_part_control() : __mall_class_parent("MALL_PART") constructor {
    order = [];
    part  = {};
    
    #region Metodos
    /// @param part_name
    /// @param item_types
    /// @param bonus_array
    /// @param link_array    
    static Add = function(_name, _itemtype, _propertyarray, _link_array) {
        static partcount = 0;
        
        if (!variable_struct_exists(part, _name) ) {
            var _part = (new __mall_class_part(_name, partcount) ).AddPossibleArray(_itemtype);

			_part.AddLinkArray(_link_array);
			_part.AddPropertyArray(_propertyarray);
			           
            variable_struct_set(part, _name, _part);
            
            array_push(order, _name);
            partcount++;
            
            return _part;
        }              
    }
    
    static Get = function(_access) {
    	return (is_string(_access) ) ? part[$ _access] : GetIndex(_access);
    }
    
    static GetIndex = function(_index) {
    	var _name = order[_index];
    	return part[$ _name];
    }
    
    static Exists = function(_name) {
    	return (variable_struct_exists(part, _name) );
    }
    
    #endregion
}

/// @returns {__mall_class_part}
function mall_get_part(_access) {
	return (MALL_CONT_PARTS).Get(_access);	
}

/// @returns {array}
/// @desc Obtiene las "part" del grupo seleccionado
function mall_part_get_names() {
	return (MALL_CONT_PARTS.order);
}

/// @returns {number}
function mall_part_get_count() {
	return (array_length(mall_part_get_names() ) );
}

function mall_part_exists(_name) {
	return (MALL_CONT_PARTS.Exists(_name) );
}

#endregion

#region Item_types

/// @param name
/// @param index
function __mall_class_itemtype(_name = "", _index = -1) : __mall_class_parent("MALL_ITEMTYPE_INTERN") constructor {
    SetBasic(_name, _index);

	// Nombres
	order = []; 
    
    #region Metodos
    
    /// @param subtype
    static Add = function(_subtype) {
		if (!variable_struct_exists(MALL_ITEMTYPE_SUB, _subtype) ) {
    		variable_struct_set(MALL_ITEMTYPE_SUB, _subtype, self);		 
        	array_push(order, _subtype);		
		}
        
        return self;
    }
    
    /// @param subtype_array
    static AddArray = function(_array) {
        repeat (each(_array) ) Add(this.value);
    
        return self;
    }
    
    /// @param {string} subtype
    /// @returns {bool}
    static ExistsSubtype = function(_subtype) {
    	return (variable_struct_exists(subtypes, _subtype) );
    }
    
    #endregion
}

/// @param {string} itemtype
/// @param {array} itemsubtypes
/// @desc Crea los distintos tipos de objetos (armas, consumibles) tambien incluye los sub-tipos (arma:Espada, armadura:Vestido)
function mall_create_itemtypes(_itemtype, _itemsubtypes = [""]) {
    static typecount = 0;
    
    if (!variable_struct_exists(MALL_ITEMTYPE, _itemtype) ) {
        var _type = (new __mall_class_itemtype(_itemtype, typecount) ).AddArray(_itemsubtypes);

        // Agregar al orden
        variable_struct_set(MALL_ITEMTYPE, _itemtype, _type);
        array_push(MALL_ITEMTYPE_ORDER, _itemtype);
        
        typecount++;
        
        return _type;
    }      
}

/// @returns {__mall_class_itemtype}
function mall_get_itemtype(_access) {
	if (!is_string(_access) ) {_access = MALL_ITEMTYPE_ORDER[_access]; }
	
	return (MALL_ITEMTYPE[$ _access] );
}

/// @param {string} subtype
function mall_get_itemtype_by_subtype(_subtype) {
	return (MALL_ITEMTYPE_SUB[$ _subtype] );	
}

/// @returns {array}
function mall_itemtypes_get_types() {
    return MALL_ITEMTYPE_ORDER;
}

/// @returns {number}
function mall_itemtypes_get_count() {
	return (array_length(mall_itemtypes_get_types() ) );
}

/// @param itemtype
/// @returns {bool}
function mall_itemtypes_exists(_itemtype) {
    return (variable_struct_exists(MALL_ITEMTYPE, _itemtype) );
}

/// @param subtype
/// @returns {bool}
function mall_itemtypes_exists_subtype(_subtype) {
	return (variable_struct_exists(MALL_ITEMTYPE_SUB, _subtype) );
}

#endregion

#region Dark (Comandos)

/// @param name
/// @param index
function __mall_class_dark(_name, _index) : __mall_class_parent("MALL_DARK_INTERN") constructor {
    subtypes = {};
    order    = [];
    
    #region Metodos
    /// @param {string} subtype
    static Add = function(_subtype) {
        static darksubtypecount = 0;
        
        if (!variable_struct_exists(subtypes, _subtype) ) {
            variable_struct_set(subtypes, _subtype, darksubtypecount);
            
            array_push(order, _subtype);
            darksubtypecount++;
        }
        
        return self;
    }
    
    /// @param {Array} subtype_array
    static AddArray = function(_array) {
        repeat (each(_array) ) Add(this.value);
        
        return self;
    }
    
    static GetSubtype = function(_name) {
    	return subtypes[$ _name];
    }
    
    static ExistsSubtype = function(_name) {
    	return (variable_struct_exists(subtypes, _name) );
    }
    
    #endregion
}

/// @param {string} dark_type
/// @param {array} dark_subtypes
function mall_create_dark(_type, _subtypes) {
    static darkcount = 0;
    
    if (!variable_struct_exists(MALL_DARK_TYPE, _type) ) {
        var _dark = (new __mall_class_dark(_type, darkcount) ).AddArray(_subtypes);
        
        variable_struct_set(MALL_DARK_TYPE, _type, _dark);
        array_push(MALL_DARK_ORDER, _type);
        
        darkcount++;
    }
}

/// @returns {__mall_class_dark}
function mall_dark_get(_access) {
	if (!is_string(_access) ) {_access = MALL_DARK_ORDER[_access]; }
	
	return (MALL_DARK_TYPE[$ _access] );
}

/// @returns {__mall_class_dark}
/// @desc Devuelve el tipo al que pertenece este subtipo.
function mall_dark_get_by_subtype(_subtype) {
	repeat (each(MALL_DARK_ORDER) ) {
		var in = this.value, _dark = mall_dark_get(in);
		
		// Obtengo los subtipos
		if (_dark.ExistsSubtype(_subtype) ) return (_dark );
	}	
	
	return noone;
}

/// @returns {array}
function mall_dark_get_types() {
    return MALL_DARK_ORDER;
}

/// @param {string} dark_type
function mall_dark_get_subtypes(_type) {
    return (variable_struct_get(MALL_DARK_TYPE, _type) ).subtypes;
}

/// @param {string} dark_type
/// @returns {bool}
function mall_dark_exists(_type) {
    return (variable_struct_exists(MALL_DARK_TYPE, _type) );
}

/// @param {string} dark_type
/// @param {string} dark_subtype
/// @returns {bool}
function mall_dark_exists_subtype(_type, _subtype) {
    var in = mall_dark_get_subtypes(_type);
    
    return (variable_struct_exists(in, _subtype) );
}

#endregion

#region Pockets

/// @param name
/// @param index
function __mall_class_pocket(_name, _index) : __mall_class_parent("MALL_POCKET_INTERN") constructor {
    SetBasic(_name, _index);
    
    subtypes = {};	// Se almacenan los tipos de objetos que almacena.
    
    order = [];
    limit = noone;
    
    #region Metodos
    /// @param {string} subtype
    static Add = function(_subtype) {
        static pocketincount = 0;
        
        if (mall_itemtypes_exists(_subtype) ) {
            variable_struct_set(subtypes, _subtype, pocketincount);
            
            array_push(order, _subtype);
            pocketincount++;
        }
        
        return self;
    }
    
    /// @param {Array} subtype_array
    static AddArray = function(_array) {
        repeat (each(_array) ) Add(this.value);
        
        return self;
    }
    
    /// @param {number} limite
    static SetLimit = function(_lim) {
    	limit = _lim;
    	
    	return self;
    }
    
    static Exists = function(_name) {
    	return (variable_struct_exists(subtypes, _name) );
    }
    
    #endregion	
}

/// @param {string} pocket_name
/// @param {array}  items_types
/// @param {number} limit
function mall_create_pocket(_pocket_name, _itemtypes, _limit = noone) {   
    static pocketcount = 0;
    
    if (!mall_pocket_exists(_pocket_name) ) {
		var _pocket = (new __mall_class_pocket(_pocket_name, pocketcount) ).SetLimit(_limit);
		
		_pocket.AddArray(_itemtypes);
		
        variable_struct_set(MALL_POCKET_TYPE, _pocket_name, _pocket);
        array_push(MALL_POCKET_ORDER, _pocket_name); // Agregar a la lista de bolsillos
    	
        pocketcount++;
        
        return _pocket;
    }    
}

/// @param pocket_name
/// @returns {bool}
function mall_pocket_exists(_name) {
	return (variable_struct_exists(MALL_POCKET_TYPE, _name) );
}

function mall_get_pocket(_access) {
	if (!is_string(_access) ) {_access = MALL_POCKET_TYPE[_access]; }
	
	return (MALL_POCKET_TYPE[$ _access] );
}

/// @desc Devuelve el bolsillo al que pertenece este tipo de objeto
function mall_pocket_get_itemtype(_itemtype) {
	repeat (each(MALL_POCKET_ORDER) ) {
		var in = this.value, _pocket = mall_get_pocket(in);
		
		if (_pocket.Exists(_itemtype) ) return _pocket;
	}
	
	return noone;
}


#endregion

