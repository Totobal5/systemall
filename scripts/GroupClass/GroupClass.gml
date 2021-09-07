function __group_class_stats(_lvl) : __mall_class_parent("GROUP_STATS") constructor {
    // Copiar estadisticas del diccionario    
    var _order = mall_stats_get_names();
    
    ImportFromArray(_order);
    
    lvl  = _lvl;
    base =   {};
    
    // Condiciones para subir de nivel
    lvl_init = undefined;   // function(self)
    lvl_end  = undefined;   // function(self)
    
    #region Metodos
            
        #region Base
    /// @param stat_name
    /// @param base_value
    static SetBase  = function(_sts_name, _base) {
        if (mall_stats_exists(_sts_name) && (!variable_struct_get(base, _sts_name) ) ) variable_struct_set(base, _sts_name, _base);
        
        return self;
    }
    
    /// @param stat_array
    static SetBases = function(_sts_array) {
        var i = 0; repeat(array_length(_sts_array) ) {
            var in = _sts_array[i];
            
            SetBase(in[0], in[1] );
            ++i;
        }
        
        return self;        
    }    
    
    static GetBase  = function(_name) {return variable_struct_get(base, _name); }
    
    #endregion
                
        #region Stats
    /// @param stat_name
    /// @param base_value
    static SetStat  = function(_sts_name, _val) {
        // Si existe la estadistica y no posee un valor base.
        if (mall_stats_exists(_sts_name) ) { 
            // Comprobar que no sea un substat
            var _sub = mall_stats_is_substat(_sts_name);

            if (_sub != noone) { // Si es un substat entonces esta limitado a su estadistica jefe
                var _mstat = mall_stats_get(_sub);
                
                var _max = is_string(_mstat.submax) ? GetStat(_mstat.submax) : _mstat.submax;
                var _min = is_string(_mstat.submin) ? GetStat(_mstat.submin) : _mstat.submin;
                
                if (_val > _max) {_val = _max; }
                if (_val < _min) {_val = _min; }
                
                variable_struct_set(self, _sts_name, _val);    
            
            } else {
                var _mstat = mall_stats_get(_sts_name);
 
                var _max = is_string(_mstat.memax) ? GetStat(_mstat.memax) : _mstat.memax;
                var _min = is_string(_mstat.memin) ? GetStat(_mstat.memin) : _mstat.memin;
                
                if (_val > _max) {_val = _max; }
                if (_val < _min) {_val = _min; } 
                
                variable_struct_set(self, _sts_name, _val);
                
            }
        }
        
        return self;
    }

    /// @param stat_array
    static SetStats = function(_sts_array) {
        var i = 0; repeat(array_length(_sts_array) ) {
            var in = _sts_array[i];
            
            SetStat(in[0], in[1] );
            ++i;
        }
        
        return self;
    }
    
    static GetStat = function(_name) {return variable_struct_get(self, _name); }
    
    #endregion
   
    /// @param level_init
    /// @param level_end
    static SetLevelFunctions = function(_init, _end) {
        SetLevelInit(_init);
        SetLevelEnd (_end);
        
        return self;
    }
        
    /// @param {function} level_init
    static SetLevelInit = function(_fun) {
        lvl_init = _fun;
        
        return self;
    }
    
    /// @param {function} level_end
    static SetLevelEnd  = function(_end) {
        lvl_end = _end;
        
        return self;
    }
    
    /// @param new_level
    /// @param force*
    static LevelUp = function(_lvl, _force = false) {
        if (!is_undefined(_lvl) ) lvl = _lvl;
        
        // Si no posee condiciones entonces
        if (is_undefined(lvl_init) || is_undefined(lvl_end) ) return self;
        
        var _sts = mall_stats_get_names();
        
        // Si es forzado o cumple las condiciones que indica "lvl_init"
        if (_force || lvl_init(self) ) {
            var i = 0; repeat(array_length(_sts) ) {
                var _name = _sts[i];
                var _form = mall_stats_get_formula(_name);
                
                var _base = GetBase(_name); // Obtener el valor base
                var _oval = GetStat(_name); // Obtener el valor actual
                
                SetStat(_name, _form(_oval, _base, lvl) );
                
                
                ++i;
            }    
        }
        
        // Ejecutar funcion para finalizar evento de subir de nivel
        lvl_end(self);
        
        return self;
    }
    
    #endregion
}

function __group_class_elements() : __mall_class_parent("GROUP_ELEMENTS") constructor {
    var _order = mall_elements_get_names();
    
    ImportFromArray(_order);
}

function __group_class_resistances() : __mall_class_parent("GROUP_RESISTANCES") constructor {
    var _order = mall_states_get_names();
    
    ImportFromArray(_order);
}

function __group_class_equip(_defaults = true) : __mall_class_parent("GROUP_EQUIP") constructor {
    #region Interno
    __copyslot    = [];
    __copycapable = [];
    #endregion

    // Copiar slots del diccionario
    // Slots: Tienes un tipo asignado y se puede seleccionar que sub_type quiere

    capable = {};
    
    if (_defaults) {
        var _slots  = mall_slots_get_names();
        var _noname = mall_slot_get_noname();
        
        ImportFromArray(mall_slots_get_names, _noname);
    }
    
    #region Metodos
        #region Slots
    /// @param {string} slot_name
    static AddSlot  = function(_slot) {
        var _noname = mall_slot_get_noname();
        
        if (mall_slot_exists(_slot) && !variable_struct_exists(self, _slot) ) {   
            variable_struct_set(self, _slot, _noname);
            
            array_push(__copyslot, _slot);
        }
        
        return self;
    }
    
    /// @param {array} slot_array
    static AddSlots = function(_slot_array) {
        var i = 0; repeat(array_length(_slot_array) ) {    
            var in = _slot_array[i];
            
            AddSlot(in);
            
            ++i;
        }
        
        return self;
    }
    
    /// @param {string} slot_name    
    /// @desc Elimina un slot del equipo.
    static DeleteSlot = function(_slot) {
        if (variable_struct_exists(self, _slot) ) {
            variable_struct_remove(self, _slot);
            variable_struct_remove(self, capable);
        }
        
        return self;
    }
    
    /// @param {string} slot_name
    static ExistsSlot = function(_slot) {
        return (variable_struct_exists(self, _slot) );
    }
    
    #endregion
    
        #region Capable
    /// @param slot_name
    /// @param subtype
    static AddCapable  = function(_slot, _subtype) {
        if (ExistsSlot(_slot) ) {
            var _type = mall_slot_get_type(_slot);
            
            if (mall_itemtypes_exists_subtype(_type, _subtype) ) {
                variable_struct_set(capable, _slot, [] );
                
                array_push(capable[$ _slot], _subtype);
                array_push(__copycapable, [_slot, _subtype] );
            }
        }  
        
        return self;
    }
    
    /// @param {array} capable_array
    static AddCapables = function(_slot_array) {
        var i = 0; repeat(array_length(_slot_array) ) {
            var in = _slot_array[i];
            
            AddCapable(in[0], in[1] );
            
            ++i;
        }
        
        return self;
    }
    
    /// @param slot_name
    /// @param subtype
    static ExistsCapable = function(_slot, _subtype) {
        var _cap = capable[$ _slot];
        
        var i = 0; repeat(array_length(_cap) ) {
            var in = capable[$ _slot][i];
            
            if (in == _subtype) return true;
            ++i;    
        }
        
        return false; 
    } 
    
    #endregion
    
    /// @param {string} slot_name
    /// @param {string} subtype
    /// @returns {bool}
    static IsCapable  = function(_slot, _subtype) {
        return (ExistsSlot(_slot) && (ExistsCapable(_slot, _subtype) ) );
    }
    
    /// @param {string} slot_name
    /// @returns {bool} 
    static IsOcuppied = function(_slot) {
        return (self[$ _slot] == mall_slot_get_noname);
    }
    
    /// @param slot_name
    /// @param value
    static SetSlot = function(_slot, _val) {
        if (is_undefined(_val) ) _val = mall_slot_get_noname();
        
        variable_struct_set(self, _slot, _val);
        
        return self;
    }    
    
    /// @param slot_name
    static GetSlot = function(_slot, _other) {
        return (is_undefined(_other) ) ? (variable_struct_get(self, _slot) ) : _other;
    }
    
    static Copy = function() {
        return (new __group_class_equip() ).AddSlots(__copyslot).AddCapable(__copycapable);
    }
    
    #endregion
}

function __group_class_control(_stateForm = {}, _stsForm = [], _eleForm = [], _resForm = [] ) : __mall_class_parent("GROUP_CONTROL") constructor {
    // Crea control de estados
    state = mall_states_copy();
    
    // Copiar elementos
    ele = mall_elements_copy(1);    
    
    // Copiar resistencias    
    res = mall_states_copy(1);
    
    // Copiar estadisticas
    sts = mall_stats_copy (1);
    
    // Control
    control = {
        state: mall_states_copy  (_stateForm),
        
        ele: mall_elements_copy(_stateForm),
        sts: mall_stats_copy (_stsForm),
        res: mall_states_copy(_resForm)        
    }
    
    __control = [];
    __control_count = 0;
    
    
    #region Metodos
    
    static SetState = function(_ste_name) {
        return self;
    }
    
    static GetState = function(_ste_name) {
        return state[$ _ste_name];
    }
    
    /// @param control_name
    static GetControl = function(_cont_name) {    
        return (control[$ _cont_name] );
    }
    
    /// @param dark_id
    static AddController = function(_dark_id) {
        var _afects = _dark_id;
        
        return self;
    }
    
    static Update = function() {
        
    }
    
    #endregion
}

/// @param {string} name
/// @param {__group_class_stats} stats
/// @param {__group_class_control} state_control
/// @param {__group_class_equip} equip
function group_create(_name, _stats, _control, _equip) : __mall_class_parent("GROUP_ID") constructor {
    #region Metodos
        #region Setter´s
    static SetName = function(_name, _desc) {
        name = _name;
        desc = _desc;
        
        return self;
    }
    
    static SetPortrait = function(_spr, _spr_index) {
        if (sprite_exists(_spr) ) {
            portrait = _spr;
            portrait_index = _spr_index;
        }
        
        return self;
    }
    
    #endregion
    
        #region Getter´s
    /// @returns {array}
    static GetName = function() {
        return [name, desc];
    }
    
    /// @returns {sprite}
    static GetPortrait = function() {
        return portrait;
    }
    
    static GetState = function() {
        return state_text;
    }
    
    /// @returns {__group_class_stats}
    static GetStats = function() {
        return stats;
    }
    
    /// @returns {__group_class_control}
    static GetState = function() {
        return state;
    }
    
    /// @returns {__group_class_equip}
    static GetEquip = function() {
        return equip;
    }
    
    /// @returns {__tree_class}
    static GetCommands = function() {
        return comands;
    }
    
    #endregion
    
        #region Comandos
    static AddCommand = function(_command_name, _dark_key) {
        comands.add(_command_name, _dark_key);
        
        return self;
    }
    
    #endregion
        
        #region Equipamiento
    /// @param slot_name
    /// @param item_key
    static EquipPut = function(_slot, _key) {
        var _item = bag_item_get(_key);
        
        if (equip.IsCapable(_slot, _item.subtype) ) {
            // Si esta ocupado sacar el objeto
            if (equip.IsOcuppied(_slot) )  EquipTake(_slot);
            
            equip.SetSlot(_slot, _key);
            bag_storage_add(_key, -1);
            
            EquipGetUpgrades();
            
            return true;
        }
        
        return false;
    }    
    
    /// @param slot_name
    static EquipTake = function(_slot) {
		var _key = equip.GetSlot(_slot);
		
		if (_key == mall_slot_get_noname() ) return false;

		// Recuperar el objeto
		bag_storage_add(_key, 1);

		// Poner nada en la posicion.
		equip.SetSlot(_slot);

		EquipGetUpgrades(); // Obtener los buffos
		
		return true;    
    }
    
    /// @param slot_name
    /// @desc Obtiene las mejoras de un slot en especifico
    static EquipGetUpgrade  = function(_slot) {
        var _key  = equip.GetSlot(_slot);    

        if (_key == mall_slot_get_noname() ) return self;

        var _item = bag_item_get(_key); /// @is {__bag_class_item}
        
        var _stats = _item.GetStats();
        var _res   = _item.GetResistances();
        var _elem  = _item.GetElements();
        
        var _names = mall_states_get_names();
        var _res_names   = mall_states_get_names();
        var _elem_names  = mall_elements_get_names();
        
        #region Estadisticas
        var i = 0; repeat(array_length(_names) ) {
            var _name = _names[i];
            
            var _o1 = stats [$ _name];
            var _o2 = _stats[$ _name];
            
            stats_final[$ _name] +=  (_o2 > 0 && _o2 <= 1) ? (_o1 * _o2) : _o2;
            
            ++i;
        }
        
        #endregion
        
        #region Resistencias
        var _mres = state.res;
        
        var i = 0; repeat(array_length(_res_names) ) {
            var _name = _names[i];
            var _o1   = _res[$ _name];
            
            _mres[$ _name] +=  (_o1 > 0 && _o1 <= 1) ? (_o1 * _mres) : _o1;
            
            ++i;
        }  
        
        #endregion
        
        #region Elementos
        var _melem = state.ele;
        
        var i = 0; repeat(array_length(_res_names) ) {
            var _name = _names[i];
            var _o1   = _elem[$ _name];
            
            _melem[$ _name] +=  (_o1 > 0 && _o1 <= 1) ? (_o1 * _melem) : _o1;
            
            ++i;
        }          
        
        #endregion
    
        return self;
    }
    
    /// @desc Obtiene las mejoras del equipamiento
    static EquipGetUpgrades = function() {
        var _slots = equip.__copyslot;  // Por si no usa los defaults
        
        var i = 0; repeat (array_length(_slots) ) {EquipGetUpgrade(_slot[i] ); ++i; }
        
        return self;
    }
    
    /// @desc Obtiene las estadisticas que posee sin el objeto equipado
    static EquipGetDifference  = function(_slot) {
        var _sts   = (new __group_class_stats() ); /// @is {__group_class_stats}
        var _names = mall_states_get_names(); 
        
        var i = 0; repeat(array_length(_names) ) {
            var _name = _names[i];
            
            var _o1 = stats      .GetStat(_name);
            var _o2 = stats_final.GetStat(_name);
            
            _sts.SetStat(_name, _o2 - _o1);
            
            ++i;
        }
        
        return _sts;
    }
    
    /// @desc Comprueba si un objeto mantiene, aumenta o baja las caracteristicas
    static EquipGetComparacion = function(_slot, _key, _stsreturn, _resreturn, _elmreturn) {
        #region Comparacion default
        
        if (_stsreturn == undefined) _stsreturn = function(v1, v2) {
            var _inter = (!is_undefined(v2) ) ? string(v2 - v1) : v1;   
            
            if (_inter == 0) {return [""  + _inter, c_white]; } else
            if (_inter <  0) {return ["-" + _inter, c_red  ]; } else 
            if (_inter >  0) {return ["+" + _inter, c_green]; }
        }
        
        if (_resreturn == undefined) _resreturn = function(v1, v2) {
            var _inter = (!is_undefined(v2) ) ? string(v2 - v1) : v1;   
            
            if (_inter == 0) {return [""  + _inter, c_white]; } else
            if (_inter <  0) {return ["-" + _inter, c_red  ]; } else 
            if (_inter >  0) {return ["+" + _inter, c_green]; }                
        }
        
        if (_elmreturn == undefined) _elmreturn = function(v1, v2) {
            var _inter = (!is_undefined(v2) ) ? string(v2 - v1) : v1;   
            
            if (_inter == 0) {return [""  + _inter, c_white]; } else
            if (_inter <  0) {return ["-" + _inter, c_red  ]; } else 
            if (_inter >  0) {return ["+" + _inter, c_green]; }                
        }
        
        #endregion
        
        var i = 0;
        
        var _sts = (new __group_class_stats() );
        var _res = (new __group_class_resistances() );
        var _elm = (new __group_class_elements() );
        
        var _sts_names = mall_slots_get_names (), _res_names = mall_states_get_names(), _elm_names = mall_elements_get_names();
        
        var _item = bag_item_get(_key); /// @is {__bag_class_item}
        var _ists = _item.GetStats(), _ielm = _item.GetElements(), _ires = _item.GetResistances();
        
        if (equip.IsOcuppied(_slot) ) {
            #region Si esta ocupado
            var _oitem = bag_item_get(equip.GetSlot(_slot) );
            
            var _osts  = _oitem.GetStats();
            i = 0; repeat(array_length(_sts_names) ) {
                var _name = _sts_names[i];
                var in = _ists.GetStat(_name), out = _osts.GetStat(_name);
                
                _sts.SetStat(_name, _stsreturn(in, out) );
                
                ++i;
            }
            
            var _oelm = _oitem.GetElements();
            i = 0; repeat(array_length(_res_names) ) {
                var _name = _res_names[i];
                var in = _ists.GetRes(_name), out = _osts.GetRes(_name);
                
                _res.SetRes(_name, _resreturn(in, out) );
                
                ++i;
            }
            
            var _ores = _oitem.GetResistances();
            i = 0; repeat(array_length(_elm_names) ) {
                var _name = _elm_names[i];
                var in = _ists.GetElement(_name), out = _osts.GetElement(_name);
                
                _elm.SetElement(_name, _elmreturn(in, out) );
                
                ++i;
            }

            #endregion
        } else {
            #region Si no esta ocupado
            i = 0; repeat(array_length(_sts_names) ) {
                var _name = _sts_names[i], in = _ists.GetStat(_name);
                
                _sts.SetStat(_name, _stsreturn(in) );
                
                ++i;
            }
            
            i = 0; repeat(array_length(_res_names) ) {
                var _name = _res_names[i], in = _ists.GetRes(_name);

                _res.SetRes(_name, _resreturn(in) );
                
                ++i;
            }
            
            i = 0; repeat(array_length(_elm_names) ) {
                var _name = _elm_names[i], in = _ists.GetElement(_name);
                
                _elm.SetElement(_name, _elmreturn(in) );
                
                ++i;
            }
            
            #endregion
        }
        
        return [_sts, _res, _elm];
    }
    
    #endregion
    
        #region Stats
    
    /// @desc Recupera una estadistica sin pasarse de un limite. funciona para quienes tengan un sub_stat (hpmax / hp)
    static StatsRestore = function(_statname, _restore, _mode = true) {
        if (!_condition(__context) ) return false;

        _restore = StatAffect(_statname, _restore);
        
        var o = (_mode) ? _restore : (stats_final.GetStat(_statname) * _restore / 100);        
        var f = stats_final.GetStat(_statname) + o;
        
        stats_final.SetStat(_statname, f);
        
		return f;        
    }
    
    /// @desc Utiliza una estadistica
    static StatsUse = function(_statname, _use, _condition, _mode = true, _all = false) {
        
        if (!_condition(__context) ) return false;
        
        // Buscar si posee un estado que aumente el consumo
        _use  = StatAffect(_statname, _use);
        
        var o = (_mode) ? _use : (_use * stats_final.GetStat(_statname) / 100);
        var f = stats_final.GetStat(_statname) - o;
        
        if (!_all) f = max(1, f);
        
		stats_final.SetStat(_statname, f);

		return f;       
    }
    
    /// @desc Pasa un valor de un estado y revisa que estados activos lo afectan. Dando el resultado nuevo al final
    static StatAffect = function(_statname, _value) {
        var _deb = mall_states_get_affect_stat(_statname);
        
        var i = 0; repeat(array_length(_deb) ) {
            var _ste_name = _deb[i];
            
            // Solo si es afectado por este estado
            if (state.GetState(_ste_name) ) {
                var _mall = mall_states_get(_ste_name);
                
                    
                _value = _mall.form(_value, _mall.val);    
            }
            
            i++;
        } 
        
        return _value;
    }
        
    #endregion

    name = _name;
    desc = "";
    
    portrait = -1;
    portrait_index = 0;
    
    state_text = "";
    
    stats = _stats; /// @is {__group_class_stats}
    stats_final = (new __group_class_stats(_stats.lvl) ); /// @is {__group_class_stats}
    
    state = _control;
    
    equip = _equip; /// @is {__group_class_equip}
    
    comands = tree_create();    /// @is {__tree_class}
}




