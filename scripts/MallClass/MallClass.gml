global._MALL_GLOBAL = {
    stats: [], statsnames:  {}, 
    state: [], statenames:  {}, 
    elmn:  [], elmnnames:   {}, 
    part:  [], partnames:   {}
}
global._MALL_MASTER = -1;

#macro MALL_MASTER mall_group_init()

#macro MALL_CONT_STATS MALL_MASTER.ControlStat    ()
#macro MALL_CONT_STATE MALL_MASTER.ControlState   ()
#macro MALL_CONT_ELEMN MALL_MASTER.ControlElements()

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

/// @param is
function __mall_class_parent(_is) constructor {
    #region Interno
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
        
    
    #endregion
}

#region Group
/// @param name
/// @param index
function __mall_class_group(_name, _index) : __mall_class_parent("MALL_GROUP_INTERN") constructor { 
    SetBasic(_name, _index);
    
    stats = undefined;
    state = undefined;
    elemn = undefined;
    part  = undefined;
}

function mall_group_control () : __mall_class_parent("MALL_GROUP") constructor {
    group = [];
    index =  0; // Para cambiar de grupo hay que cambiar el indice

    #region Metodos
    static Create = function(_name) {
        static createcount = 0;
        
        array_push(group, (new __mall_class_group(_name, createcount) ) );
        createcount++;
    }

    static GetGroup = function(_ind) {
        if (!is_undefined(_ind) ) index = _ind;
  
        return races[index];    
    }
    
    static AddStat = function(_stats) {
        static stat_count = 0;
        
        foreach(_stats.order, function(in, i) {
            if (!variable_struct_exists(global._MALL_GLOBAL.stsnames, in) ) {
                array_push(global._MALL_GLOBAL.stats, in);
                variable_struct_set(global._MALL_GLOBAL.statsnames, in, stat_count);
                
                stat_count++;
            }
        });
        
        group[index].stats = _stats;
        /*
        var _order = _stats.order;
        var i = 0; repeat(array_length(_order) ) {
            var in = _order[i];
            
            if (!variable_struct_exists(__master_stat_names, in) ) {
                array_push(master_stat, in);
                
                variable_struct_set(__master_state_names, in, stat_count);
                stat_count++;
            }
        
            ++i;
        }
        
        races[index].stats = _stats;
        */
    }
    
    static AddState = function(_state) {
        static state_count = 0;
        
        var _order = _state.order;
        var i = 0; repeat(array_length(_order) ) {
            var in = _order[i];
            
            if (!variable_struct_exists(__master_state_names, in) ) {
                array_push(master_state, in);
                
                variable_struct_set(__master_state_names, in, state_count);
                state_count++;
            }
        
            ++i;
        }
        
        races[index].state = _state;  
    }
    
    static AddElement = function(_elemn) {
        static elemn_count = 0;
        
        var _order = _elemn.order;
        var i = 0; repeat(array_length(_order) ) {
            var in = _order[i];
            
            if (!variable_struct_exists(__master_elemn_names, in) ) {
                array_push(master_elemn, in);
                
                variable_struct_set(__master_elemn_names, in, elemn_count);
                elemn_count++;
            }
        
            ++i;
        }
       
        races[index].elemn = _elemn;
    }
    
    static AddPart    = function(_part)  {
        GetGroup().part = _part;
    }

        #region Obtener controladores
    static ControlStat = function() {
        return races[index].stats;
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
    
    return global._MALL_MASTER;
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

/// @param name
/// @param index
function __mall_stat_class(_name = "", _index = -1) : __mall_class_parent("MALL_STAT_INTERN") constructor {
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
    
    watch = {}; // Que estado afecta a esta estadistica.
    
    #region Metodos
    /// @param stat_name
    static SetMaster = function(_name) {
        var _cont = outside.stats;
        
        if (_name != "") {
            var in = _cont[$ _name];
            
            master      = in;
            master_name = _name;
            
            range_max = in.range_max;
            range_min = in.range_min;
            
            // Quitar la manera de subir de nivel, ya que ahora es esclavo de la otra estadistica
            SetLvlUp(undefined);
            
            return  true;
        }
        
        return false;
    }
    
    /// @param lvlup
    static SetLvlUp  = function(_lvlup) {
        lvlup = _lvlup;
        
        return self;
    }
    
    /// @param range_min
    /// @param range_max
    static SetRange = function(_min, _max) {
        range_max = _min;
        range_min = _max;
        
        return self;
    }

    /// @param state_name
    /// @param values
    static AddWatch = function(_state_name, _values) {
        if (!variable_struct_exists(watch, _state_name) ) {
            variable_struct_set(watch, _state_name, {state: _state_name, val: _values} );
        }
        
        return self;
    }
    
    /// @param watch_array
    static AddWatchArray = function(_array) {
        foreach(_array, function(in, i) {AddWatch(in[0], in[1] ); } );
    }
    
    /// @returns {struct}
    static GetWatch  = function() {
        return watch;
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
            var _stat = (new __mall_stat_class(_name, count) );
            _stat.outside = self;

            // Si no se establecio un master entonces agregar la formula
            if (!_stat.SetMaster(_master) ) _stat.SetLvlUp(_formula);
            
            variable_struct_set(stats_master, _name, _stat);
            array_push(order, _name);
            
            count++;
            
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
function __mall_state_class(_name = "", _index = -1, _init = false) : __mall_class_parent("MALL_STATE_INTERN") constructor {
    // Lo basico
    set_basic(_name, _index);
    
    val_init = _init;
    
    pross      = [];
    pross_form = [];
    
    affect = [];    // A que estadisticas afecta
    affected = [];  // Que elemento lo puede invocar
    
    #region Metodos
    static add_affected = function(_elemn_name) {
        array_push(affected, _elemn_name);
        return self;
    }
    
    static add_affect = function() {
        if (is_array(argument[0] ) ) {
            var i = 0; repeat(array_length(argument[0] ) ) {
                var in = argument[0][i];
                
                array_push(affect, in);
                
                var _stat = mall_get_stat(in);
                
                _stat.add_affected(name);

                ++i;
            }
        }
        
        return self;
    }
    
    static add_proccess = function() {
        if (is_array(argument[0]) ) {
            var i = 0; repeat(array_length(argument[0] ) ) {
                var in = argument[0][i];
                
                array_push(pross     , in[0] );
                array_push(pross_form, in[1] );
                
                ++i;
            }
        }
        
        return self;
    }
    
    static get_proccess = function(_ind) {
        return [pross[_ind], pross_form[_ind] ];
    }
    
    #endregion
}

function mall_state_control() : __mall_class_parent("MALL_STATE") constructor {
    order = [];
    state_master = {};
    
    #region Metodos
    static MasterAdd = function(_name, _init, _affects, _proccess) {
        static count = 0;
        
        if (!variable_struct_exists(state_master, _name) ) {
            var _state = (new __mall_state_class(_name, count, _init) ).add_affect(_affects).add_proccess(_proccess);

            variable_struct_set(state_master, _name, _state);
            
            array_push(order, _name);
            count++;
            
            return _state;
        }             
    }

    static MasterGetNames = function() {
        return order;
    }
    
    static MasterGetCount = function() {
        return array_length(order);
    }
    
    static MasterGetState = function(_name) {
        return (is_string(_name) ) ? state_master[$ _name] : MasterGetStateIndex(_name);
    }
    
    static MasterGetStateIndex = function(_ind) {
        return state_master[$ order[_ind] ];        
    }

    #endregion
}

function mall_get_state(_access) {
    return (MALL_CONT_STATE.MasterGetState(_access) );
}

#endregion

#region Elements
function __mall_element_class(_name = "", _index = -1) : __mall_class_parent("MALL_ELEMENT_INTERN") constructor {
    // Lo basico
    set_basic(_name, _index);
    
    produce      = [];   // Estados
    produce_prob = [];   // Probabilidad de producirlos
    
    #region Metodos
    static add_produce = function(_array) {
        var i = 0; repeat(array_length(_array) ) {
            var _name = _array[i][0], _val = _array[i][1];
            
            array_push(produce      , _name);
            array_push(produce_prob ,  _val);
            
            var _state = mall_get_state(_name);
            _state.add_affected(name);
            
            ++i;
        }
        
        return self;
    }
    
    
    #endregion
}

function mall_element_control() : __mall_class_parent("MALL_ELEMENT") constructor {
    order = [];
    elemn_control = {};
    
    #region Metodos
    static MasterAdd = function(_name, _produce) {
        static count = 0;
        
        if (!variable_struct_exists(elemn_control, _name) ) {
            var _elemn = (new __mall_element_class(_name, count) ).add_produce(_produce);

            variable_struct_set(elemn_control, _name, _elemn);
            
            array_push(order, _name);
            count++;
            
            return _elemn;
        }    
    }

    static MasterGetNames = function() {
        return order;
    }
    
    static MasterGetCount = function() {
        return array_length(order);
    }
    
    #endregion
}


#endregion

#region Slots
/// @param slot_name
/// @desc Crea las ranuras para equipar objetos (mano, armadura, etc)
function mall_create_slots(_slot_name, _item_type, _no_item = "------") {
    global._MALL_SLOTS.noname = _no_item;
    
    if (!variable_struct_exists(global._MALL_SLOTS, _slot_name) ) {
        if (!mall_itemtypes_exists(_item_type) ) show_error("MALL SLOTS && ITEMTYPE: NO EXISTE EL ITEM TYPE!", true);
        
        variable_struct_set(global._MALL_SLOTS, _slot_name, _item_type);
        
        // Agregar al orden
        array_push(global._MALL_SLOTS.order, _slot_name);
    }   
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