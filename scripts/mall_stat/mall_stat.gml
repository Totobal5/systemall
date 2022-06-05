/// @desc Donde se guardan las propiedades de una estadistica
function MallStat(_key) : MallComponent(_key) constructor {
    #region PRIVATE
	// -- Lider y súbdito
    __leader = "";
    
    __minion   = [];
    __affected = {};

		#region Configuracion
	__initial = numtype(0, NUMTYPE.REAL);
    __limits  = [0, 0];
    
    // No hay cambios
    __lvlMethod = MALL_DUMMY_METHOD;
    
    __lvlLimits = [0, 0];   // Nivel minimo y maximo
    __lvlSingle =  false;   // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
    
	/// @type {Struct.Counter}
    __toMin = (new Counter(0, 1, 1, false) );
	/// @type {Struct.Counter}
    __toMax = (new Counter(0, 1, 1, false) );
   
    __toMaxLevel = false;	// Luego de subir de nivel la primera vez dejar con el valor maximo
    	
	#endregion
	
	#endregion
	
    #region METHODS
	/// @param {Struct.MallStat, String} _stat	MallStat o llave
	/// @param {Bool} [_inh_limit]		Heredar limites
	/// @param {Bool} [_inh_lvl]		Heredar formula de nivel
	/// @param {Bool} [_inh_display]	Heredar metodo de display
	/// @desc Copia el limite, valor inicial y formula de otro MallStat
	/// @return {Struct.MallStat}
    static inherit = function(_stat, _inh_limit=true, _inh_lvl=true, _inh_display=false) {
		if (is_string(_stat) ) {
			/// @type {Struct.MallStruct}
			_stat = mall_get_stat(_stat);
		}
		
		// Copiar valor inicial
		numtype_copy(__initial, _stat.__initial);
		
        // Si se hereda el limite de valor
        if (_inh_limit) setLimit(_stat.__limits);
		
		// Si se hereda lo relacionado al nivel (method y limite)
		if (_inh_lvl) {
	        __lvlMethod = method(undefined, _stat.__lvlMethod);	// Copiar formula para subir de nivel
			array_copy(__lvlLimit, 0, _stat.__lvlLimit, 0, 2);	// Copiar limite de nivel
		}
        
        if (_inh_display) __display = _stat.__display;
        
        return self;
    }
    
    /// @param {Struct.MallStat} _stat
    static setLeader = function(_stat) {
		if (is_string(_stat) ) {
			/// @type {Struct.MallStruct}
			_stat = mall_get_stat(_stat);
		}
		
        // Agregar a los hijos del otro MallStat
		_stat.AddMinion(__key);
        __leader = _stat.__key; // Llave del lider
			
		setLimit(_stat.__limits);
		
		#region LVL
        __lvlMethod = undefined;	// eliminar funcion ya que ahora sube de nivel de acuerdo al lider.
        __lvlSingle =	  false;	// tiene el mismo nivel que su maestro.	
        setLevelLimit(_stat.__lvlLimits);
		
		#endregion
		
        return self;
    }
    
	/// @param {Function} _method
	/// @return {Struct.MallStat}	
    static setVisualize = function(_method) {
    	__visualize = method(undefined, _method);
    	return self;
    }
    
	/// @param {Real} _initial
	/// @param {Real} _type
	/// @param {Real} _min
	/// @param {Real} _max
	/// @return {Struct.MallStat}
	static set = function(_initial, _type, _min, _max) { 
		__initial = numtype(_initial, _type);	
		return setLimit(_min, _max);
	}
	
    /// @param {Real} _min
    /// @param {Real} [_max]
	/// @return {Struct.MallStat}	
    static setLimit = function(_min, _max) {
		if (!is_array(_min) ) {
	    	__limits[0] = _min;
	    	__limits[1] = _max;
		} else {
			__limits[0] = _min[0];
			__limits[1] = _min[0];
		}
		
        return self;
    }
    
    /// @param {Function} _method
    /// @param {Real} _min
    /// @param {Real} _max
    /// @param {Bool} _single
	/// @return {Struct.MallStat}	
    static setLevel = function(_method, _min = 0, _max = 100, _single = false) {
    	// Si ya existe un lider no usar
    	if (__leader == "") {
		    __lvlMethod = method(undefined, _method);	// Scope local
		    __lvlLimits = [_min, _max];
		    __lvlSingle = _single;
		}
        return self;
    }
    
    /// @param {Real} _min
    /// @param {Real} _max
    static setLimitLevel = function(_min, _max) {
    	if (!is_array(_min) ) {
			__lvlLimits[0] = _min;
			__lvlLimits[1] = _max;
		} else {
			__lvlLimits[0] = _min[0];
			__lvlLimits[1] = _max[1];
		}

    	return self;
    }
    
	/// @param {Real} _iterate
    /// @param {Bool} _repeat
    /// @desc Al subir de nivel deja esta estadistica en su menor valor
	/// @return {Struct.MallStat}
    static toMin = function(_iterate=1, _repeat=true) {
		// Desactiva toMax
		__toMax.active(false);
		__toMin.modify(_iterate, 1, _repeat).active(true); 

        return self;
    }
    
	/// @param {Real} _iterate
    /// @param {Bool} _repeat
    /// @desc Al subir de nivel deja esta estadistica en su nivel mayor
	/// @return {Struct.MallStat}
    static toMax = function(_iterate=1, _repeat=true) {
        // Desactiva toMin
        __toMin.active(false);
        __toMax.modify(_iterate, 1, _repeat).active(true);

        return self;
    }
    
    /// @param {String} _stateKey
    /// @param _value
	/// @param _type
	/// @return {Struct.MallStat}
    static setAffected = function(_stateKey, _value, _type=NUMTYPE.REAL) {
		if (!is_array(_value) ) {
			__affected[$ _stateKey] = numtype(_value, _type); 	
		}
		else {
			__affected[$ _stateKey] = _value; 	
		}
		
        return self;
    }
    
    /// @param {String} _stateKey
    static getAffected = function(_stateKey) {
        return (__affected[$ _stateKey] );    
    }
	
	/// @param {Real} _lvl
	/// @param {Struct.__PartyStatsComponent} _stat
	/// @param {Struct.PartyStats} _self
	static execute = function(_lvl, _stat, _self) {
		return (__lvlMethod(_lvl, _stat, _self) );	
	}
	
	/// @return {String}
	static toString = function() {
		return (
			"value: " + string(__initial[0] ) + "\ntype: " + string(__initial[1] ) +
			"\nmin: " + string(__limits[0] )  + "\nmax: "  + string(__limits[1] )  +
			"\ntoMin: " + string(__toMin) + "\ntoMax: " + string(__toMax)
		);
	}
	
    #endregion
}
	
/// @param {Real} _x
function __mall_stat_rounding(_x) {
	switch (MALL_STAT_ROUND) {	
		case 0: return _x;			break;
		case 1: return round(_x);	break;
		case 2: return floor(_x);	break;
		
		default: return _x; break;
	}	
}