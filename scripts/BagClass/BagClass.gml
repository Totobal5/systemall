function __bag_class_item(_subtype, _buy, _sell) : __mall_class_parent("BAG_ITEM") constructor {
    type    = (mall_get_itemtype_by_subtype(_subtype) ).GetName();
    subtype = _subtype;
	
	pocket = (mall_pocket_get_itemtype(type) );
	
    // Si posee algo en especial (envenena, +daño a un enemigo etc)
    special = {};
    
    // Datos
    sts = (new __group_class_stats() ); 		 // Crear estadisticas
    res = (new __group_class_resistances() );    // Crea las resistencias
    eln = (new __group_class_elements() );  	 // Crear elementos
    
    // Trade
    can_sell = true;
    can_buy  = true;
    
    sell = _sell;
    buy  = _buy;
    
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
		
		var _scr = MALL_LOCAL.GetTranslate();  // Obtener localizacion
		
		if (_ext == undefined) _ext = [_name];
		
		if (!is_undefined(_scr) ) {
			name = _scr(_name + MALL_LOCAL.name);
 			des  = _scr(_des  + MALL_LOCAL.des );
 			
 			// Textos extras
 			var _extlocal = MALL_LOCAL.GetExtraAll();
 			
 			repeat (each(_ext) ) {
 				var in = this, _txt = in.value + _extlocal[in.index];

 				array_push(ext, _scr(_txt) );
 			}

		} else {
			name = _name;
 			des  = _des;
 			
 			repeat (each(_ext) ) array_push(ext, this.value);
		}
		
		return self;
    }
    
    /// @param dark_key Puede ser una id de un hechizo dark o una funcion nueva
    /// @param {array} arguments
    static SetSpecial = function(_key, _arguments) {
        special = (new __bag_class_special(_key, _arguments) );
        
        return self;
    }
    
    /// @param buy_value
    /// @param sell_value
    /// @param can_buy?
    /// @param can_sell?
    static SetTrade = function(_buy, _sell, _canbuy, _cansell) {
    	if (_cansell == undefined) _cansell = can_sell;
    	if  (_canbuy  ==  undefined)  _canbuy  = can_buy;
    	
    	sell = _sell;
    	buy  = _buy ;
    	
    	can_sell = _cansell;
    	can_buy  = _canbuy ;
    	
    	return self;
    }
    
	/// @param stat
	/// @param value...
	static SetStat = function() {
		var i = 0; repeat(argument_count - 1) {
			sts.Set(argument[i], argument[i + 1] );
			
			++i;
		}	
		
		return self;
	} 

	/// @param stat
	/// @param value...    
    static SetElement = function() {
		var i = 0; repeat(argument_count - 1) {
			eln.Set(argument[i], argument[i + 1] );
			
			++i;
		}	
		
		return self;	
    }

	/// @param stat
	/// @param value...      
    static SetResistance = function() {
		var i = 0; repeat(argument_count - 1) {
			res.Set(argument[i], argument[i + 1] );
			
			++i;
		}	
		
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
function __bag_class_special(_spell, _arguments) : __mall_class_parent("BAG_PROP") constructor {
    if (dark_exists(_spell) ) _spell = dark_get(_spell);
    
    spell = _spell;
    arg   = _arguments;
    
    #region Metodos
    /// @returns {script}
    static GetSpell     = function() {return spell; }
    
    /// @returns {array}
    static GetArguments = function() {return arg;   }
    
    #endregion
}


/// @returns {__bag_class_item}
function bag_create_item(_subtype) {
	return (new __bag_class_item(_subtype) );
}

