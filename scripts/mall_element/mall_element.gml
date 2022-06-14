/// @desc Donde se guarda la configuracion para los elementos del proyecto
///		Se configuran: 
///		   1) Que estado causa este elemento y la probabilidad de hacerlo
///		   2) Que estadistica defiende a este elemento
///		   3) Que estadistica ataca con este elemento
///		   4) Que estadistica puede absorver este elemento	(en base a un umbral)
///		   5) Que estadistica es reducida por este elemento	(en base a un umbral)
/// @param {String} element_key
/// @return {Struct.MallElement}
function MallElement(_key) : MallComponent(_key) constructor {
    #region PRIVATE
	__produce = []; // Que estados produce [estado, probabilidad]
    
    __attack = []; //  Que estadistica ataca con este elemento
    __defend = []; //  Que estadistica defiende este elemento
    
    __absorbed = {};    //  Que estadistica absorve este elemento
    __reduced  = {};    //  Que estadistica es reducido por este elemento
    
	#endregion
	
    #region METHODS
    /// @param state_key
    /// @param probability
    static addProduce = function() {
        var i = 0; repeat(argument_count div 2) {
            array_push(__produce, [argument[i++], argument[i++] ] ); 
        }
        
        return self;
    }
    
    /// @param stat_key
    /// @param threshold
    static addAbsorbed = function(_stat, _threshold) {
        if (argument_count <= 2) {
            __absorbed[$ _stat] = _threshold;    
        } else {    // Soporte para varios
            var i = -1; repeat(argument_count div 2) {AddAbsorbed(argument[i], argument[i++] ); }
        }
        
        return self;
    }
    
    /// @param stat_key
    /// @param threshold
    static addReduced  = function(_stat, _threshold) {
        if (argument_count <= 2) {
            __reduced[$ _stat] = _threshold;
        } else {
            var i = -1; repeat(argument_count div 2) {AddReduced(argument[i++], argument[i++] ); }    
        }
        
        return self;
    }
    
    /// @param stat_key    
    static addAttack = function() {
       var i = -1; repeat(argument_count) {array_push(__attack, argument[i++] ); } 
    }
    
    /// @param stat_key
    static addDefend = function() {
        var i = -1; repeat(argument_count) {array_push(__defend, argument[i++] ); }
        return self;
    }

    #endregion
}
