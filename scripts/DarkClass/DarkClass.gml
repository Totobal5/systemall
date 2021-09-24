
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

function __dark_class_effect(_name, _type, _effect_start = 0, _effect_end = 0, _effect_aument = 0, _turn_active = 8, _turn_iter = 0, _turn_aument = 1) : __mall_class_parent("DARK_EFFECT") constructor {
    SetBasic(_name, -1);
    
    type = _type;
    
    // Turnos
    turns = 1;
    
    turn_aument  = _turn_aument;
    turns_active = _turn_active;
	
	turns_count = 1;
 	turns_iter  = _turn_iter;
	
    // Valores
    effect = _effect_start;
    
    effect_aument = _effect_aument;	
    effect_start  = _effect_start;
    effect_end    = _effect_end;    
 
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
    static SetProcess = function(_start, _update, _end) {
    	fun_start  = _start;
    	fun_update = _update;
    	fun_end    = _end;
    	
    	return self;
    }
    
    /// @desc Actualiza el valor del effecto
    static Update = function() {
		if (turns_count >= turns_iter) {
			if (effect < effect_end) EffectUpdate();
		}
		
        return (effect);
    }
    
    /// @desc Devuelve el effecto a su valor original
    static Reset  = function() {
		
        return self;
    }
    
    /// @param raise_value
    static Turns = function() {
		if (turns < turns_active) {
			turns += turn_aument;
			
			if (turns_count < turns_iter) {turns_count++; } else {turns_count = 1; }
		}
		
		return (turns >= turns_active);
    }
    
    static EffectUpdate = function() {
		if (!is_undefined(effect_oper) ) {
			effect  = effect_oper(effect, turns);
		} else {
			effect += effect_aument;
		}
    }
    
    #endregion
}

