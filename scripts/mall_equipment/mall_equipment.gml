/// @param {String} part_key
/// @return {Struct.MallEquipment}
function MallEquipment(_KEY) : MallComponent(_KEY) constructor {
	#region PRIVATE
	
	__active  = true;
	__numbers = 1;	// Cuantos objetos se pueden equipar en esta parte (EJ: mano: guantes, armas, escudos)
 
    // Sistema de daño. Si una parte esta muy dañada entonces se desactiva globalmente
    __damageUse = false;
	__damageMax = noone;
	__damageMin = noone;
	
    __items = {};   // Que tipos de objetos puede llevar y si posee un bonus o no.
   
	#endregion
	
    #region METHODS
    
	/// @desc Indica que objetos puede equipar esta parte y el bonus agregado
    /// @param itemtype_key
    /// @param bonus_value
    /// @param number_type
    /// @param ...
    static setItemtype = function(_KEY, _VALUE, _TYPE=0) 
	{
        if (argument_count > 3) 
		{
            var i=0; repeat(argument_count div 3) 
			{
            	var _key   = argument[i++];
            	var _value = argument[i++];
            	var _type  = argument[i++];
            	
                setItemtype(_key, _value, _type);    
            }
        } 
		else 
		{
            // Agrega el objeto al diccionario
            __items[$ _KEY] = [_VALUE, _TYPE];
        }
        
        return self;    
    }
    
    /// @param {String} item_key
	/// @return {Array<Real>}
    static getBonus = function(_KEY) 
	{
        return (__items[$ _KEY] );
    }
	
    #endregion
    
}