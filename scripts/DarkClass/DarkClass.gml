
/// @param {string} dark_subtype
/// @param consume
/// @param include?
/// @param targets
/// @param {string} dark_key
function __dark_class_spell(_subtype = "", _consume = 0, _include = true, _target = 1, _key = "") : __mall_class_parent("DARK_SPELL") constructor {
    // Variables
    key = _key;
	
	subtype = _subtype;
    type = (mall_dark_get_by_subtype(_subtype) ).GetName();
    
    consume = _consume; // Algo que consume para realizar el hechizo
    include = _include; // Si el caster se incluye en el hechizo
    targets = _target ; // Objetivos del hechizo    
	
    spell = undefined;
    
    // Informacion
    name = "";
    des = "";
    ret = "";
    
    conditions = [true, false]; // Que condiciones necesita para ejecutar el hechizo
    
    #region Metodos
   
    /// @param {string} key
    static SetKey = function(_key) {
        key = _key;
        
        return self;
    }
    
    /// @param {string} name
    /// @param {string} description
    /// @param {string} returns
    /// @desc Depende de la localizacion
    static SetInformation = function(_name, _des = _name, _ret = _name) {
		if (key == "") SetKey(_name);
		
		var _scr = MALL_LOCAL.scr;  // Obtener localizacion
		
		if (!is_undefined(_scr) ) {
			_name += MALL_LOCAL.name;
			_des  += MALL_LOCAL.des;
			_ret  += MALL_LOCAL.ret;
			
			name = _scr(_name);
 			des  = _scr(_des) ;
 			ret  = _scr(_ret) ;
		} else {
			name = _name;
 			des  = _des;
 			ret  = _ret;
		}
		
		return self;        
    }

    /// @param {function} function
    static SetSpell = function(_fun) {
        spell = _fun;
        
        return self;
    }
    
    /// @param consume
    /// @param targets
    /// @param include?
    static SetSpellProp = function(_consume, _targets, _include) {
        consume = _consume;
        targets = _target ;
        include = _include;
        
        return self;
    }
    
    static GetType = function() {
        return type;
    }
    
    static GetSubType = function() {
        return subtype;
    }
    
    /// @desc Devuelve el consumo que necesita
    static GetConsume = function() {
        return consume;
    }
    
    #endregion
}

/// @param {string} state_type
/// @param value
/// @param turns
/// @param {string} name
function __dark_class_effect(_type, _val = 0, _turns = 3, _name = "") : __mall_class_parent("DARK_EFFECT") constructor {
    name = _name;
    
    // Obtener el state
    state = mall_get_state(_type);
	
    turns = _turns;
    turns_max = 10; 
    turns_min =  0;

    // Valores
    effect = _val;
    
    effect_reset = _val;
    effect_oper  = undefined;

	// Funciones
	fun_start  = undefined;
	fun_update = undefined;
	fun_end    = undefined;

	/*
		Mensaje que utiliza al:
		*	Puede o no ser un array. Este array funciona por si tiene más de un mensaje que puede aparecer
		[0]: Al recibir el efecto		
		[1]: Al actualizar su efecto
		[2]: Al terminar su efecto
		[3]: Mensaje especial ¡ES UN ARRAY OBLIGATORIAMENTE!
	*/
    msg = ["", "", "", ""];
    
    #region Metodos
    static SetTurnsLimits = function(_min = 0, _max = 10) {
    	turns_max = _max;
    	turns_min = _min;
    	
    	return self;
    }
    
    /// @desc Actualiza el valor del effecto
    static Update = function() {
        if (!is_undefined(effect_oper) ) effect += effect_oper;
    
        return self;
    }
    
    /// @desc Devuelve el effecto a su valor original
    static Reset  = function() {
        effect = effect_reset;
        return self;
    }
    
    /// @param raise_value
    static Raise = function(_val = 1) {
    	turns += _val;
    	
    	return (turns >= turns_max);        
    }
    
    /// @param lower_value
    static Lower = function(_val = 1) {
		turns -= _val;
		
		return (turns <= turns_min); 
    }
    
        #region Messages
    static AddMessage = function(_start, _update, _end, _misq = []) {
 		msg = [_start, _update, _end, _misq];
		
		return self;       
    }
    
    static GetMessage = function(_ind = 0) {
    	return msg[_ind];
    }
    
    #endregion
    /// @returns {__mall_class_state}
    static GetState = function() {
    	return (state);
    }
    
    #endregion
}

