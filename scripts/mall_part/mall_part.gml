/// @param {String} part_key
/// @return {Struct.MallPart}
function MallPart(_key) : MallComponent(_key) constructor {
	#region PRIVATE
	
	__number  = 1;	// Cantidad de la misma parte (EJ: 5 dedos, 2 brazos)
	__itemMax = 1;	// Cuantos objetos se pueden equipar en esta parte (EJ: mano: guantes, armas, escudos)
    __active = array_create(1, true);  // Como inician estas partes, la primera siempre activa
  
    // Sistema de daño. Si una parte esta muy dañada entonces se desactiva globalmente
    __damageUse = false;
	__damageMax = noone;
	__damageMin = noone;
	
    __items = {};   // Que tipos de objetos puede llevar y si posee un bonus o no.
    __linked = {};  // Que partes estan unidas a esta.
    __joint  = {};  // A que parte esta unida.
    
	// Si un estado o elemento lo afecta
    __affected = {};
    
	#endregion
	
    #region METHODS
    
    /// @param itemtype_key
    /// @param bonus_value
    /// @param number_type
    /// @param ...
    /// @desc Indica que objetos puede equipar esta parte y el bonus agregado
    static setItemtype = function(_itemtype_key, _value=0, _type=0) {
        if (argument_count > 3) {
            var i=0; repeat(argument_count div 3) {
            	var _key = argument[i++];
            	var _bns = argument[i++];
            	var _tp = argument[i++];
            	
                setItemtype(_key, _bns, _tp);    
            }
        } else {
            // Agrega el objeto al diccionario
            __items[$ _itemtype_key] = numtype(_value, _type);
        }
        
        return self;    
    }
    
    /// @param {String} item_key
	/// @return {Array<Real>}
    static getItemtype = function(_item_key) {
        return (__items[$ _item_key] );
    }
    
    /// @param {String} part_key
	/// @desc Unir una parte a la actual
	/// @return {Struct.MallPart}
    static link = function(_part_key) {
		__linked[$ _part_key] = true;
		var _part = mall_actual_group().getPart(_part_key).joint(__key);
        return self;
    }
    
    /// @param {String} part_key
	/// @return {Struct.MallPart}
    static joint = function(_part_key) {
        __joint[$ _part_key] = true;
        return self;
    }
    
    #endregion
    
}