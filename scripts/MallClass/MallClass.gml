

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
    
    ignore_gbl = false;	// Si se ignora globalmente en la mayoria de funciones (por si acaso lol)
    ignore_txt = false;	// Si se ignora en alguna funcion para textos
    
    #region Metodos
    static SetBasic  = function(_name, _index) {
        name  = _name;
        index = _index;
        
        txt = name;
        
        return self;
    }
    
    static SetString = function(_txt, _symbol) {
        var _scr = MALL_LOCAL.GetTranslate();
        
        var _new = (!is_undefined(_scr) ) ? _scr(_txt) : _txt;

        txt     = _new;
        symbol  = _symbol;

        return self;
    }
	
	static ToggleIgnore = function() {
		ignore_txt = !ignore_txt;
		return self;
	}
	
		#region Basico
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
    		
    		if (is_data(in) )	 {in.Turn(); } else 
    		if (is_numeric(in) ) {in *= -1 ; } 
    		
    		variable_struct_set(_struct, _name, in);
    		
    		++i;
    	}
    	
    	return self;
    }
    
    	#endregion
    
    	#region Getter´s
    static GetName  = function() {
    	return name;
    }
        
    static GetBasic = function() {
        return [name, index];
    }
    
    static GetTxt	= function() {
    	return (txt );
    }
    
    static GetString = function() {
        return [txt, symbol];
    }

    static GetType   = function() {
        return __is;
    }
    
    #endregion
    
    	#region Misq
    static Copy = function() {}
    
    #endregion
    
    #endregion
}

#endregion

#region States
/// @param state_name
/// @param state_index
/// @param state_init
function __mall_class_state(_name = "", _index = -1, _init = false) : __mall_class_parent("MALL_STATE_INTERN") constructor {
    #region Interno
    static __ClassProcess = function(_start = 0, _end = 0, _aument = 0, _turnactive = 8, _turniter = 0, _turnaument = 1, _propupdate = "", _propstart = "", _propend = "") constructor {
    	start  = _start;
    	ending = _end;
    	aument = _aument;
    	
		turnactive  = _turnactive;
    	turnaument	= _turnaument;
    	turniter	= _turniter;
    	
		update		= _propupdate;
    	updatestart	= _propstart;
    	updateend   = _propend;
    }

    #endregion
    
    
    SetBasic(_name, _index);
    
    init = _init;
    
    process = {};	// Procesos que puede ejecutar.
    
    watch_stat = [];    // Que estadistica lo vigilan
    watch_part = [];    // Que partes lo vigilan    
		
	link = (new __mall_class_group("", -1) ).AllSetArray();	/// @is {__mall_class_group}
	
    #region Metodos
    static Get = function() {
        return init;
    }
    
    /// @param init_value
    static SetInit = function(_init) {
        init = _init;
        
        return self;
    }
    
    	#region Processes
    	
	static SetProcess = function(_start, _end, _aument, _turnmin, _turnmax, _turniter, _turnaument, _propupdate, _propstart, _propend) {
		process = (new __ClassProcess(_start, _end, _aument, _turnmin, _turnmax, _turniter, _turnaument, _propupdate, _propstart, _propend) );
		
		return self;
	}
    
    static GetProcess = function() {
    	return (process);
    }
    
    #endregion
    
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
        for (var i = 0, _len = array_length(_array) - 1; i < _len; i+=2) SetWatchStat(_array[i], _array[i + 1] );        

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

		#region Links
    /// @param {__mall_class_part} mall_class
    /// @desc Crea un link a otra clase de mall
    static AddLink = function(_class) {
        if (!is_struct(_class) ) return self;
        
        // No poder crear link a el mismo
        if (_class == self) return self;
        
        switch (_class.GetType() ) {
            case "MALL_STAT_INTERN"   : link.AddStat (_class); break;
            case "MALL_STATE_INTERN"  : link.AddState(_class); break;
            case "MALL_PART_INTERN"   :	link.AddPart (_class); break;
            
            case "MALL_ELEMENT_INTERN": link.AddElement(_class); break;
        }
        
        return self;
    }	
	
	static AddLinkArray = function(_array) {
		var i = 0; repeat(array_length(_array) - 1) {
			AddLink(_array[i]);
			
			++i;
		}	
		return self;
	}
	
	static AddLinkArgument = function() {
		var i = 0; repeat(argument_count) {
			AddLink(argument[i]);
			
			++i;
		}
		
		return self;
	}
	
	static GetLinkStat = function(_index) {
		return (link.stat[_index] );
	}
	
	#endregion
	
	/// @param state_class
	static Inherit = function(_other) {
		return self;
	}
	 
	static Copy = function() {}
   
    #endregion
}

function mall_state_control() : __mall_class_parent("MALL_STATE") constructor {
    order = [];
    state = {};
    
    #region Metodos
    /// @returns {__mall_class_state}
    static Add = function(_name, _init, _watch) {
        static statecount = 0;
        
        if (!variable_struct_exists(state, _name) ) {
            var _state = (new __mall_class_state(_name, statecount, _init) );
			_state.SetWatchStatArray(_watch);
			
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
    absorb_threshold = 0;

    reduce = []; // Una estadistica se puede perjudiciar del elemento
    reduce_threshold = 0;
    
    produce = {}; // Probabilidad de producirlos estados
	
	link = (new __mall_class_group("", -1) ).AllSetArray();	/// @is {__mall_class_group}
	
    #region Metodos
   
    	#region Produce
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
    
    static GetProduce = function(_state_name) {
        return (is_undefined(_state_name) ) ? produce : produce[$ _state_name];
    }
    
    static GetProduceAll = function() {
        return produce;
    }
	
    #endregion
    
    	#region Absorb && Reduce
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
    
    #endregion
    
		#region Links
    /// @param {__mall_class_part} mall_class
    /// @desc Crea un link a otra clase de mall
    static AddLink = function(_class) {
        if (!is_struct(_class) ) return self;
        
        // No poder crear link a el mismo
        if (_class == self) return self;
        
        switch (_class.GetType() ) {
            case "MALL_STAT_INTERN"   : link.AddStat (_class); break;
            case "MALL_STATE_INTERN"  : link.AddState(_class); break;
            case "MALL_PART_INTERN"   :	link.AddPart (_class); break;
            
            case "MALL_ELEMENT_INTERN": link.AddElement(_class); break;
        }
        
        return self;
    }	
	
	static AddLinkArray = function(_array) {
		var i = 0; repeat(array_length(_array) - 1) {
			AddLink(_array[i]);
			
			++i;
		}	
		return self;
	}
	
	static AddLinkArgument = function() {
		var i = 0; repeat(argument_count - 1) {
			AddLink(argument[i]);
			
			++i;
		}
		
		return self;
	}
	
	static GetLinkStat = function(_index) {
		return (link.stat[_index] );
	}
	
	#endregion    
    
	static Inherit = function(_other) {
	
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
            var _elemn = (new __mall_class_element(_name, elmncount) );
            _elemn.AddProduceArray(_produce);

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

function mall_element_get_sub(_access) {
	return (mall_get_element(_access).GetSub() );
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
            	
            	if (!ExistsLinkPart(_name) ) array_push(_link, _class);

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
    	if (!is_array(_array) ) return self;
    	
    	var i = 0; repeat(array_length(_array) - 1) {
    		AddProperty(_array[i], _array[i + 1] );
    		
    		++i;
    	}
    	
    	return self;
    }
    
    static AddPropertyOther = function(_prop) {
		var _names = variable_struct_get_names(_prop);

		var i = 0; repeat(array_length(_names) ) {
			var _name = _names[i], in = _prop[$ _name];
			
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

