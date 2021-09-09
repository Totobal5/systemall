global._MALL_GLOBAL = {
    stats: [], statsnames:  {}, 
    state: [], statenames:  {}, 
    elmn:  [], elmnnames:   {}, 
    part:  [], partnames:   {}
}

global._MALL_MASTER   = -1;

#macro MALL_MASTER mall_group_init()

#macro MALL_CONT_STATS MALL_MASTER.ControlStat    ()
#macro MALL_CONT_STATE MALL_MASTER.ControlState   ()
#macro MALL_CONT_ELEMN MALL_MASTER.ControlElements()

/// @param is
function __mall_class_parent(_is) constructor {
    #region Interno
    __mall = "MALL";
    __is = _is;
    // __context = weak_ref_create(self);   // Referencia así mismo.
    
    #endregion

    name  = "";
    index = -1;
    
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
    
        #region Import
    /// @param array
    /// @param set_value
    static ImportFromArray = function(_array, _setval = 0) {
        var i = 0; repeat(array_length(_array ) ) {        
            var in    = _array[i];

            if (!variable_struct_exists(self, in) ) variable_struct_set(self, in, _setval);  
            
            ++i;
        }        
    }

    static ImportFromArrayTo = function(_var_name, _array, _setval = 0) {
        var i = 0; repeat(array_length(_array ) ) {        
            var in    = _array[i];

            if (!variable_struct_exists(_var_name, in) ) variable_struct_set(_var_name, in, _setval);  
            
            ++i;
        }        
    }
    
    #endregion
        
    static GetBasic  = function() {
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
    
    #endregion
}

/// @returns {array} all_stats
function mall_global_stats  () {
    return (global._MALL_GLOBAL.sts);   
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
    
    /// @param {__mall_stat_class} stat_class
    static AddStat = function(_stat) {
        static statcount = 0;
        
        var _gstats = global._MALL_GLOBAL.statsnames;
        var _order  = _stat.order; 
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gstats, in) ) {
                array_push(_order, in);
                variable_struct_set(_gstats, in, statcount);
            
                statcount++;
            }
        }
 
        GetGroup().stat = _stat;
        return self;
    }

    /// @param {__mall_state_class} state_class    
    static AddState = function(_state) {
        static statecount = 0;
        
        var _gstates = global.__MALL_GLOBAL.statenames;
        var _order   = _state.order;
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gstates, in) ) {
                array_push(_order, in);
                variable_struct_set(_gstates, in, statecount);
            
                statecount++;
            }
        }        

        GetGroup().state = _state;
        return self;        
    }
    
    /// @param {__mall_element_class} element_class
    static AddElement = function(_elemn) {
        static elemncount = 0;
        
        var _gelemn = global._MALL_GLOBAL.elmnnames;
        var _order  = _elemn.order;
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gelemn, in) ) {
                array_push(_order, in);
                variable_struct_set(_gelemn, in, elemncount);
            
                elemncount++;
            }
        }
        
        GetGroup().elemn = _elemn;
        return self;        
    }
    
    /// @param {} part_class
    static AddPart    = function(_part)  {
        static partcount = 0;
        
        var _gpart = global._MALL_GLOBAL.partnames;
        var _order = _part.order;
        
        repeat(each(_order) ) {
            var in = this.value;
            
            if (!variable_struct_exists(_gpart, in) ) {
                array_push(_order, in);
                variable_struct_set(_gpart, in, partcount);
            
                partcount++;
            }
        }
        
        GetGroup().part = _part;
        return self;
    }

        #region Obtener controladores
    static ControlStat = function() {
        return races[index].stat;
    }

    static ControlState = function() {
        return races[index].state;
    }
    
    static ControlElements = function() {
        return races[index].elemn;
    }
    
    static ControlPart = function() {
        return GetGroup().part;   
    }
    
    #endregion
 
    #endregion
}

/// @param default_group
function mall_group_init(_group_name) {
    static racecontrol = (new mall_group_control() ).Create(_group_name);
    global._MALL_MASTER = racecontrol;
    
    return (global._MALL_MASTER );
}

/// @param group_name
function mall_group_create(_name)       {
    MALL_MASTER.MasterCreate(_name);
}

function mall_group_change(_ind) {
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
    
    lvlup = function(old, base, lvl) {return old; };
    
    watched = {};   // Que estado es observado
    used    = {};   // Que partes lo usan
    
    absorb = [];    // Que elemento absorbe
    reduce = [];    // Que elemento reduce
    
    #region Metodos
    
    /// @param {__mall_stat_class} stat_class
    /// @desc Hereda la formula y rangos de otro estado, pero no es su maestro
    static Inherit = function(_stat) {
        range_max = _stat.range_max;
        range_min = _stat.range_min;
            
        // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
        SetLvlUp(_stat.GetLvlUp() );
    }
    
    /// @param {__mall_stat_class} stat_class
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
    static SetLvlUp = function(_lvlup) {
        lvlup = _lvlup;
        
        return self;
    }
    
    /// @param range_min
    /// @param range_max
    static SetRange = function(_min, _max) {
        range_min = _min;
        range_max = _max;
        
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
    static GetWatch  = function() {
        return watched;
    }
    
    /// @returns {array}
    static GetRange  = function() {
        return [range_min, range_min];
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
    
    static GetProcesses = function() {
        return processes;
    }
    
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

/// @returns {__mall_state_class}
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

/// @returns {__mall_element_class}
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

function __mall_class_part(_name = "", _index = -1) : __mall_class_parent("MALL_PART_INTERN") constructor {
    // Deterioro
    deter = 0;
    deter_min = noone;
    deter_max = noone;
    
    deter_txt = "n";
    noitem = "noitem";    // Si no hay objeto equipado
    
    
    // Componentes que lo afectan
    link = (new __mall_class_group("", -1) ).AllSetArray();   /// @is {__mall_class_group}
    
    #region Metodos
    
    /// @param deterior
    /// @param range_min
    /// @param range_max
    static SetDeter = function(_val, _min, _max) {
        deter = _val;
        
        deter_min = _min;
        deter_max = _max;
        
        return self;
    }
    
    /// @param mall_class
    /// @desc Crea un link a otra clase de mall
    static AddLink = function(_class) {
        switch (_class.GetType() ) {
            case "MALL_STAT_INTERN"   : link.stat  = _class;    break;
            case "MALL_STATE_INTERN"  : link.state = _class;    break;
            case "MALL_ELEMENT_INTERN": link.elemn = _class;    break;
            case "MALL_ELEMENT_INTERN": link.part  = _class;    break;
        }
        
        return self;
    }
    
    /// @param mall_class_array
    static AddLinkArray = function(_class_array) {
        repeat(each(_class_array) ) AddLink(this.value);
        
        return self;
    }
    
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
    static GetLinkPart    = function() {
        return link.part;
    }
    
    #endregion
}

/// @param part_name
/// @param stat_array
/// @desc Crea las ranuras para equipar objetos (mano, armadura, etc)
function mall_part_control() : __mall_class_parent("MALL_PART") constructor {
    order = [];
    part  = {};
    
    #region Metodos
    static Add = function(_name, _item_type, ) {
        
    }
    
    
    #endregion
}

/// @returns {array}
function mall_slots_get_names() {
    return global._MALL_STATES.order;
}

/// @param slot_name
function mall_slot_get_type(_slot) {
    return (variable_struct_get(global._MALL_SLOTS, _slot) );
}

/// @param slot_name
/// @returns {bool}
function mall_slot_exists(_slot_name) {
    return (variable_struct_exists(global._MALL_SLOTS, _slot_name) );
}

/// @returns {string}
function mall_slot_get_noname() {
    return global._MALL_SLOTS.noname;
}

/// @param {string} no_name
function mall_slot_set_noname(_noname) {
    variable_struct_set(global._MALL_SLOTS, "noname", _noname);
}

#endregion

#region Item_types

/// @param {string} item_type
/// @param {array} item_subtypes
/// @desc Crea los distintos tipos de objetos (armas, consumibles) tambien incluye los sub-tipos (arma:Espada, armadura:Vestido)
function mall_create_itemtypes(_item_type, _item_subtypes = [""]) {
    if (!variable_struct_exists(global._MALL_ITEMS_TYPE, _item_type) ) {
        variable_struct_set(global._MALL_ITEMS_TYPE, _item_type, {order: []});
        
        // Una vez agregado se agregan los sub-tipos
        var _sub = global._MALL_ITEMS_TYPE[$ _item_type];
        
        var i = 0; repeat(array_length(_item_subtypes) ) {
            var in = _item_subtypes[i];
            
            variable_struct_set(_sub, in, i);
            
            array_push(_sub.order, in);
            
            ++i;    
        }
        
        // Agregar al orden
        array_push(global._MALL_ITEMS_TYPE.order, _item_type);
    }      
}

/// @returns {array}
function mall_itemtypes_get_types() {
    return global._MALL_ITEMS_TYPE.order;
}

/// @param item_type
/// @returns {struct}
function mall_itemtypes_get_subtype(_item_type) {
    return (variable_struct_get(global._MALL_ITEMS_TYPE, _item_type) );
}

/// @param item_type
/// @returns {bool}
function mall_itemtypes_exists(_item_type) {
    return variable_struct_exists(global._MALL_ITEMS_TYPE, _item_type);
}

function mall_itemtypes_exists_subtype(_item_type, _sub_type) {
    return (mall_itemtypes_exists(_item_type) && variable_struct_exists(mall_itemtypes_get_subtype(_item_type), _sub_type) );
}

#endregion

#region Dark (Comandos)

// Types defaults
#macro DARK_TYPE_BATTLE "Battle"

#macro DARK_TYPE_SPELL "Spells"
#macro DARK_SUBTYPE_WSPELL "White Spell"


function mall_create_dark(_type, _sub_types) {
    if (!variable_struct_exists(global._MALL_DARK, _type) ) {
        variable_struct_set(global._MALL_DARK, _type, {order: []});
        
        // Una vez agregado se agregan los sub-tipos
        var _sub = global._MALL_DARK[$ _type];
        
        var i = 0; repeat(array_length(_sub_types) ) {
            var in = _sub_types[i];
            
            variable_struct_set(_sub, in, i);
            
            array_push(_sub.orden, in);
            
            ++i;    
        }
        
        // Agregar al orden
        array_push(global._MALL_DARK.order, _item_type);
    }
}

/// @returns {array}
function mall_dark_get_types() {
    return global._MALL_DARK.order;
}

/// @param {string} sub_type
function mall_dark_get_subtype(_subtype) {
    return (variable_struct_get(global._MALL_DARK, _subtype) );
}

/// @param {string} dark_type
function mall_dark_exists(_type) {
    return (variable_struct_exists(global._MALL_DARK, _type) );
}

function mall_dark_exists_subtype(_type, _subtype) {
    return (mall_dark_exists(_type) && variable_struct_exists(mall_dark_get_subtype(_type), _subtype) );
}

#endregion

#region Pockets

/// @param {string} pocket_name
/// @param {array}  items_types
/// @param {number} limit
function mall_create_pocket(_pocket_name, _itemtypes, _limit = noone) {   
    if (!mall_pocket_exists(_pocket_name) ) {
        static Count = 0;
        
        variable_struct_set(global._MALL_POCKETS, _pocket_name, {order: [], lim: _limit, index: Count});
        
        var _sub = global._MALL_POCKETS[$ _pocket_name];

        var i = 0; repeat(array_length(_itemtypes) ) {
            var in = _itemtypes[i];
            
            variable_struct_set(_sub, in, i);
            array_push(_sub.order, in);
            
            ++i;
        }
        
        // Agregar a la lista de bolsillos
        array_push(global._MALL_POCKETS.order, _pocket_name);
        Count++;
    }    
}


/// @returns {array}
/// @desc Obtiene el nombre de todos los bolsillos
function mall_pocket_get_names() {
    return (global._MALL_POCKETS.order);   
}

/// @desc Devuelve la cantidad de bolsillos
function mall_pocket_count() {
    return (array_length(mall_pocket_get_names() ) );    
}
 
/// @param {string} pocket_name
/// @returns {bool}
/// @desc Devuelve true si un bolsillo existe
function mall_pocket_exists(_pocket_name) {
    return (variable_struct_exists(global._MALL_POCKETS, _pocket_name) );
}

/// @param pocket_index|name
/// @desc Devuelve un pocket mediante su nombre o indice
/// @returns {struct}
function mall_pocket_get() {
    var _access = (is_string(argument[0] ) ) ? argument[0] : global._MALL_POCKETS.order[argument[0] ];

    return (global._MALL_POCKETS[$ _access] );
}

/// Devuelve un bolsillo que permite este tipo de objeto
function mall_pocket_get_by_type(_item_type) {
    var i = 0; repeat(mall_pocket_count() ) {
        var _pocket = mall_pocket_get(i);
        
        if (variable_struct_exists(_pocket, _item_type) ) return _pocket;
        
        ++i;
    }
    
    return noone;
}

/// @param pocket_name
/// @returns {number}
function mall_pocket_get_index(_pocket) {
    return (mall_pocket_get(_pocket).index );
}

/// @param {number} pocket_index|name
function mall_pocket_get_limit(_access) {
    return (mall_pocket_get(_access).lim ); 
}

/// @param pocket_id
/// @param {string} item_type
function mall_pocket_permited(_pocket, _itemtype) {
    return (variable_struct_exists(_pocket, _itemtype) );
}

#endregion

#region Is
/// @param group_id
function is_group(_group_id) {
    return (is_struct(_group_id) && _group_id.__is == "GROUP_ID");
}

#endregion