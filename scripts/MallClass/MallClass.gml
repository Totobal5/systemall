global._MALL_MASTER   = -1;

#macro MALL_MASTER mall_group_init()

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
	
	static Ignore = function() {
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
    
    /// @param {string} subtype
    /// @returns {bool}
    static ExistsSubtype = function(_subtype) {
    	return (variable_struct_exists(subtypes, _subtype) );
    }
    
    #endregion
}

/// @param {string} itemtype
/// @param itemsubtypes...
/// @desc Crea los distintos tipos de objetos (armas, consumibles) tambien incluye los sub-tipos (arma:Espada, armadura:Vestido)
function mall_create_itemtypes(_itemtype) {
    if (!variable_struct_exists(MALL_ITEMTYPE, _itemtype) ) {
        var _type = (new __mall_class_itemtype(_itemtype, typecount) );
		
		for (var i = 1; i < argument_count - 1; i++) _type.Add(argument[i] );
		
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

