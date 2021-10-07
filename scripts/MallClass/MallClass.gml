global._MALL_MASTER   = -1;

#macro MALL_MASTER mall_group_init()

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

/// @returns {array}
function mall_itemtypes() {
    return (global._MALL_GLOBAL.itemtype);
}

/// @returns {struct}
function mall_itemtypes_names() {
	return (global._MALL_GLOBAL.itemtypenames);
}

/// @returns {struct}
function mall_itemsubtype_names() {
	return (global._MALL_GLOBAL.itemsubnames);	
}

/// @param {string} itemtype
/// @param itemsubtypes...
/// @desc Crea los distintos tipos de objetos (armas, consumibles) tambien incluye los sub-tipos (arma:Espada, armadura:Vestido)
function mall_create_itemtypes(_itemtype) {
	var _types  = mall_itemtypes();
	var _inside = mall_itemtypes_names();
	
	var _sub    = mall_itemsubtype_names();
	
	var _count = array_length(_types);
	
    if (!variable_struct_exists(_inside, _itemtype) ) {
        var _type = {name: _itemtype, index: _count, order: [] };

		for (var i = 1, _order = _type.order; i < argument_count - 1; i++) {
			var _subname = argument[i];
			
			// Agregar sub-type
			variable_struct_set(_sub, _subname, _type);
			array_push(_order, _sub);
		}
		
        // Agregar al orden
        array_push(_types, _itemtype);
        variable_struct_set(_inside, _itemtype, _type);
        
        return _type;
    }      
}

/// @param access
/// @returns {__mall_class_itemtype}
function mall_get_itemtype(_access) {
	if (is_numeric(_access) ) _access = global._MALL_GLOBAL.itemtype[_access];

	return (global._MALL_GLOBAL.itemtypenames[$ _access] );
}

/// @param {string} subtype
/// @desc Devuelve un tipo a partir de un sub-tipo
function mall_get_itemsubtype(_subtype) {
	return (global._MALL_GLOBAL.itemsubnames[$ _subtype] );	
}

/// @param itemtype
/// @returns {bool}
function mall_itemtypes_exists(_itemtype) {
    return (variable_struct_exists(global._MALL_GLOBAL.itemtypenames, _itemtype) );
}

/// @param subtype
/// @returns {bool}
function mall_itemsubtype_exists(_subtype) {
	return (variable_struct_exists(global._MALL_GLOBAL.itemsubnames, _subtype) );
}

#endregion

#region Dark (Comandos)

/// @returns {array}
function mall_dark() {
	return (global._MALL_GLOBAL.dark);
}

/// @returns {struct}
function mall_dark_names() {
	return (global._MALL_GLOBAL.darknames);
}

/// @returns {struct}
function mall_darksub_names() {
	return (global._MALL_GLOBAL.darksubnames);
}

/// @param {string} dark_type
/// @param dark_subtypes...
function mall_create_dark(_type) {
	var _dark		= mall_dark();
	var _darknames	= mall_dark_names();
	
	var _sub = mall_darksub_names();
	
	var _count = array_length(_dark);

    if (!variable_struct_exists(_names, _type) ) {
    	var _new = {name: _type, index: _count, order: [] }; 

		for (var i = 1, _order = _new.order; i < argument_count - 1; i++) {
			var _subname = argument[i];
			
			// Agregar sub-type
			variable_struct_set(_sub, _subname, _new);
			array_push(_order, _subname);
		}
		
        // Agregar al orden
        array_push(_dark, _new);
        variable_struct_set(_darknames, _type, _new);
        
        return _new;
    }
}

/// @param access
function mall_get_dark(_access) {
	if (is_numeric(_access) ) _access = global._MALL_GLOBAL.dark[_access];
	
	return (global._MALL_GLOBAL.darknames[$ _access] );
}

/// @param dark_subtype
/// @desc Devuelve el tipo al que pertenece este subtipo.
function mall_get_darksub(_subtype) {
	return (global._MALL_GLOBAL.darksubnames[$ _subtype] );	
}

/// @param {string} dark_type
/// @returns {bool}
function mall_dark_exists(_type) {
    return (variable_struct_exists(global._MALL_GLOBAL.darknames, _type) );
}

/// @param {string} dark_subtype
/// @returns {bool}
function mall_darksub_exists(_subtype) {
	return (variable_struct_exists(global._MALL_GLOBAL.darksubnames, _subtype) );	
}

#endregion

#region Pockets

/// @returns {array}
function mall_pocket() {
	return (global._MALL_GLOBAL.pocket);
}

/// @returns {struct}
function mall_pocket_names() {
	return (global._MALL_GLOBAL.pocketnames);
}

/// @param {string} pocket_name
/// @param {number}  limit
/// @param itemtypes...
function mall_create_pocket(_name, _limit = noone) {   
    var _pocket = mall_pocket();
    var _names  = mall_pocket_names();

    var _count = array_length(_pocket);
    
    if (!variable_struct_exists(_names, _name) ) {
    	var _new = {name: _name, index: _count, order: [], limit: _limit};

		for (var i = 2, _order = _new.order; i < argument_count - 2; i++) {
			var _itemtype = argument[i];
			
			// Agregar sub-type
			variable_struct_set(global._MALL_GLOBAL.pocketitemtype, _itemtype, _new);
			array_push(_order, _itemtype);
		}

        variable_struct_set(_names, _name, _new);
        array_push(_pocket, _name); // Agregar a la lista de bolsillos

        return _new;
    }    
}

/// @param pocket_name
/// @returns {bool}
function mall_pocket_exists(_name) {
	return (variable_struct_exists(global._MALL_GLOBAL.pocketnames, _name) );
}

/// @param access
function mall_get_pocket(_access) {
	if (is_numeric(_access) ) _access = global._MALL_GLOBAL.pocket[_access];
	
	return (global._MALL_GLOBAL.pocketnames[$ _access] );
}

/// @desc Devuelve el bolsillo al que pertenece este tipo de objeto
function mall_pocket_permitted(_itemtype) {
	return (global._MALL_GLOBAL.pocketitemtype[$ _itemtype] );	
}


#endregion

