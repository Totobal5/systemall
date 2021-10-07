/// @param name
function __mall_class_part(_name) : __mall_class_parent("MALL_PART_INTERN") constructor {
    SetBasic(_name, -1);
    
    noitem = "noitem";	// Si no hay objeto equipado
    
    // Deterioro
    use_damage = false;	// Si utiliza la caracteriztica del damage
    
    damage_start = 0;	
    damage_min = noone;	// Si es noone entonces no posee un valor minimo del daño
    damage_max = 0;		// Si es noone entonces no posee un valor maximo del daño
    
    damage_txt = "dañado!";
    
    bonus    = {};  // Que subtipo de arma le otorga un bonus
    possible = {};  // Que tipo de objetos puede llevar esta parte.

    linked = [];    // Partes que estan unidas a esta
    joined = [];    // Si esta parte depende de otra (EJ: pie y pierna)
    
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
	
	    #region Damage
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
    
    #endregion

        #region Items
    
    /// @param item_type
    /// @param enabled?
    /// @desc Se debe de asegurar que los objetos hayan sido creado antes!!
    static Posible = function(_itemtype, _enabled = true) {
        variable_struct_set(possible, _itemtype, _enabled);
        
        return self;
    }
    
    /// @param name
    static GetPosible = function(_name) {
        return (variable_struct_get(possible, _name) );
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
    
    /// @param itemsub_name
    /// @param value
    static Bonus = function(_name, _value) {
        variable_struct_set(bonus, _name, _value); 
        return self;
    }
    
    static GetBonus = function(_name) {
        return (variable_struct_get(bonus, _name) );   
    }
    
    #endregion

    /// @param {__mall_class_part} part_class
    /// @param link?
    /// @desc Hereda las propiedades de otra parte
    static Inherit = function(_part, _linked = false) {
        #region Bonus
        var _names = variable_struct_get_names(_part.bonus);
        
        var i = 0; repeat(array_length(_names) ) {
            var _name = _names[i], _val = _part.GetBonus(_name);
            
            Bonus(_name, _val);
            
            i++;
        }
        
        #endregion
        
        #region Tipos
        var _names = variable_struct_get_names(_part.possible);
        
        var i = 0; repeat(array_length(_names) ) {
            var _name = _names[i], _val = _part.GetPosible(_name);
            
            Posible(_name, _val);
            
            i++;
        }
        
        #endregion
        
        // Si es verdadero linkear esta parte
        if (_linked) SetLinked(_part);
        
        return self;
    }
    
    static SetJoined = function(_part) {
        array_push(joined, _part);
        return self;
    }
    
    static SetLinked = function(_part) {
        array_push(linked, _part);
        return self;
    }
    
    #endregion
}

/// @param [names]
function mall_create_parts() {
    var _order = mall_parts();
    var _parts = mall_parts_name();
    
    var _count = array_length(_order);
    
    repeat(argument_count) {
    	var in = argument[_count];
    	
    	if (!variable_struct_exists(_parts, in) ) {		
    		array_push(_order, in);
    		variable_struct_set(_parts, in, _count);
    	}
    	
        _count++;
    }    
}

/// @returns {array}
function mall_parts() {
    return (global._MALL_GLOBAL.parts);
}

/// @returns {struct}
function mall_parts_name() {
    return (global._MALL_GLOBAL.partsnames);
}

/// @param part_name
function mall_get_part(_name) {
    return (mall_group_init() ).GetPart(_name);    
}

/// @returns {struct}
function mall_parts_copy() {
    var _names = mall_parts(), _reference = {}, i = 0;

    repeat(array_length(_names) ) {
        variable_struct_set(_reference, _names[i], undefined);
        
        ++i;
    }
    
    return (_reference );    
}

/// @param part_name
/// @param capable_itemtype
/// @param capable_usable?
/// @param ...
function mall_part_customize(_name) {
    var _part = (mall_group_init() ).CustomizePart(_name);
    
    for (var i = 1; i < argument_count; i += 2) {
        _part.Posible(argument[i], argument[i + 1] );
    }
    
    return (_part);
}



