/// @param {String} _subtype
/// @param {Real} _consume
/// @param {Bool} _include
/// @param {Real} _targets
/// @param {Array} _conditions
/// @return {Struct.DarkSpell}
function DarkSpell(_subtype, _consume=0, _include=true, _targets=1, _conditions) : MallComponent() constructor {
    #region PRIVATE
	__subtype = _subtype;   // El sub-tipo al que pertenece    
    __type = "";			// Se agrega al final    
        
    __consume = _consume;  // Cuanto consume de algo (definido por usuario) al usar este hechizo
    __include = _include;
    __targets = _targets;
    
    __spell = undefined;	// Funcion a usar
    __conditions = _conditions ?? [true, false];    // Condiciones a usar depende del programador como usarlo
    
	#endregion
	
    #region METHODS    
    /// @param {String} _type
	/// @return {Struct.DarkSpell}
    static setType = function(_type) {
		__type = _type; 
		return self; 
	}
    
    /// @param {Function} _function
	/// @return {Struct.DarkSpell}
    static setSpell = function(_function) {
        __spell = method(undefined, _method);	// contexto propio
        return self;
    }
    
    /// @param _include
    /// @param _targets
	/// @return {Struct.DarkSpell}	
    static customize = function(_include, _targets) {
        __include = _include;
        __targets = _targets;
        
        return self;
    }
    
    #endregion    
}