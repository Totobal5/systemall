function __bag_class_item() : __mall_class_parent("BAG_ITEM") constructor {
    type    = "";
    subtype = "";
    
    key = "";
    
    name = "";  // Nombre del objeto
    des  = "";  // Descripcion del objeto
    ext  = [];  // Texto extra que es un array    
    
    // Si posee algo en especial (envenena, +daño a un enemigo etc)
    prop = {};
    
    // Datos
    sts = (new __group_class_stats() ); 		 // Crear estadisticas
    res = (new __group_class_resistances() );    // Crea las resistencias
    eln = (new __group_class_elements() );  	 // Crear elementos
    
    // Trade
    can_sell = true;
    can_buy  = true;
    
    sell = 1;
    buy  = 1;
    
    #region Metodos
    
    /// @param data_key
    static SetKey = function(_key) {
        key = _key;
        
        return self;
    }
    
    /// @param item_name
    /// @param item_description
    /// @param {array} item_extra
    static SetInformation = function(_name, _des = _name, _ext) {
		if (key == "") SetKey(_name);
		
		var _scr = MALL_LOCAL.scr;  // Obtener localizacion
		
		if (is_undefined(_ext) ) _ext = [_name];
		
		if (!is_undefined(_scr) ) {
		    _name += MALL_LOCAL.name;
			_des  += MALL_LOCAL.des;

			name = _scr(_name);
 			des  = _scr(_des) ;
 			
 			// Textos extras
			var i = 0; repeat(array_length(_ext) ) {
			    var in = _ext[i] + MALL_LOCAL.ext[i];
			    
			    array_push(ext, _scr(in) ); 
			    ++i;
			}
			
		} else {
			name = _name;
 			des  = _des;
 			
			var i = 0; repeat(array_length(_ext) ) {
			    var in = _ext[i] + MALL_LOCAL.ext[i];
			    
			    array_push(ext, in); 
			    ++i;
			}
		}
		
		return self;
    }
    
    /// @param item_type
    /// @param item_subtype
    static SetType = function(_type, _subtype) {
    	if (mall_pocket_get_by_type(_type) != noone ) {
    		type = _type;
    		subtype = _subtype;
    	}

        return self;
    }
    
    /// @param dark_key Puede ser una id de un hechizo dark o una funcion nueva
    /// @param {array} arguments
    static SetProp = function(_key, _arguments) {
        prop = (new __bag_class_properties(_key, _arguments) );
        
        return self;
    }
    
    /// @param buy_value
    /// @param sell_value
    /// @param can_buy?
    /// @param can_sell?
    static SetTrade = function(_buy, _sell, _canbuy = true, _cansell = true) {
    	sell = _sell;
    	buy  = _buy ;
    	
    	can_sell = _cansell;
    	can_buy  = _canbuy ;
    	
    	return self;
    }
    
    /// @returns {__group_class_stats}
    static GetStats = function() {
    	return sts;
    }
    
    /// @returns {__group_class_elements}
    static GetElements = function() {
    	return eln;
    }
    
    /// @returns {__group_class_resistances}
    static GetResistances = function() {
    	return res;
    }
    
    #endregion
}

/// @param dark_key Puede ser una id de un hechizo de dark o una funcion nueva
/// @param {array} arguments
function __bag_class_properties(_spell, _arguments) : __mall_class_parent("BAG_PROP") constructor {
    if (dark_exists(_spell) ) _spell = dark_get(_spell);
    
    prop_scr = _spell; 
    prop_arg = _arguments;
    
    #region Metodos
    /// @returns {script}
    static GetSpell     = function() {return prop_scr; }
    
    /// @returns {array}
    static GetArguments = function() {return prop_arg; }
    
    #endregion
}


/// @returns {__bag_class_item}
function bag_create_item() {
	return (new __bag_class_item() );
}