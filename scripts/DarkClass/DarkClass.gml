
/// @param {string} dark_type
/// @param consume
/// @param include?
/// @param {string} dark_subtype
/// @param targets
/// @param {string} dark_key
function __dark_class_spell(_type, _consume = 0, _target = 1, _include = true, _subtype = "", _key = "") : __mall_class_parent("DARK_SPELL") constructor {
    // Variables
    key = _key;

    type = _type;
    subtype = _subtype;

    consume = _consume; // Algo que consume para realizar el hechizo
    targets = _target ; // Objetivos del hechizo    
    include = _include; // Si el caster se incluye en el hechizo

    spell = undefined;
    
    // Informacion
    name = "";
    des = "";
    ret = "";
    
    conditions = [true, false]; // Que condiciones necesita para ejecutar el hechizo
    
    #region Metodos
    
    /// @param {function} function
    static SetFunction = function(_fun) {
        spell = _fun;
        
        return self;
    }
    
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
    
    /// @param consume
    /// @param targets
    /// @param include?
    static SetSpell = function(_consume, _targets, _include) {
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
    type  = _type;
    
    turns = _turns;
    turns_max = 10; 
    turns_min =  0;
    
    name = _name;
    
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
    
    #endregion
}




/*

/// @param {number} type
/// @param {number} valor
/// @param {number} turns
/// @param {string} name
function __dark_class_effect(_type, _val = 0, _turn = 3, _name = string( random(100) ) )	constructor {
	#region Interno
	
	/// @desc Devuelve una copia de si mismo con otra id
    static copy = function() {
        var _new = {};
        
        var _names = variable_struct_get_names(self);
        var _size  = array_length(_names);
        
        var i= 0; repeat(_size) {
            var _name = _names[i];
            var _val  = self[$ _name];

            variable_struct_set(_new, _name, _val);
           
            i++;
        }
    
        return _new;
	}
	
	#endregion
	
	type = _type; 	// A que estadistica afecta
	turn = _turn;   // Turnos en que está activo
	name = _name;	// Nombre del efecto
	
	// -- Valores que posee el efecto
	effect = _val;
	
	effect_reset = _val;
	effect_oper  = undefined;
	

	msj		= ["", "", "", ""];	
	
	/// @desc Actualiza el valor utilizando val_oper
	static Update = function() {
		if (!is_undefined(effect_oper) ) effect += effect_oper;
		
		return self;
	}
	
	/// @desc Reinicia el valor actual al valor del reset
	static Reset  = function() {
		effect = effect_reset;
		
		return self;
	}
	
	/// @param value
	/// @desc Este valor se aplica cuando se utiliza el metodo Reset
	static SetReset = function(_val) {
		effect_reset = _val;
		
		return self;
	}
	
	/// @param value+-
	static Raise = function(_val = 1) {
		turn += _val;
		
		return self;
	}
	
	/// @param value+
	static Lower = function(_val = 1) {
		turn -= _val;
		
		return (turn <= 0);
	}
	
	/// @param {bool}
	static GetTurn = function() {return turn; }
	
	static AddMessage = function(_txt_start, _txt_update, _txt_end, _txt_misq = []) {
		msj = [
			_txt_start,
			_txt_update,	
			_txt_end,
			_txt_misq
		];
		
		return self;
	}
	
	/// @param index
	static GetMessage = function(_ind) {return msj[_ind]; }
	
	static IsPorcentual = function() {return (effect > 0 && effect < 2); }
	
	static GetEffect = function() {return effect; }
}

















