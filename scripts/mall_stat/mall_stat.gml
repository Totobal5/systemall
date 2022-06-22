/// @param {String}	stat_key
/// @desc Donde se guardan las propiedades de una estadistica
function MallStat(_key) : MallComponent(_key) constructor {
    #region PRIVATE
	// -- Lider y súbdito
    __leader = "";
    
    __minion = [];
    __effect = {};	// Que efecto tiene un estado sobre esta estadistica

		#region Configuracion
	__initial = numtype(0, NUMTYPES.REAL);
    __limits  = [0, 0];
    
    // No hay cambios
    __levelMethod = MALL_DUMMY_METHOD;
    
    __levelLimits = [0, 0];   // Nivel minimo y maximo
    __levelSingle =  false;   // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
    
	/// @type {Struct.Counter}
    __toMin = (new Counter(0, 1, 1, true) );
	/// @type {Struct.Counter}
    __toMax = (new Counter(0, 1, 1, true) );
   
    __toMaxLevel = false;	// Luego de subir de nivel la primera vez dejar con el valor maximo
    	
	#endregion
	
	#endregion
	
    #region METHODS
	/// @param {Struct.MallStat, String}	stat				MallStat o llave
	/// @param {Bool}						[inherit_limit]		Heredar limites
	/// @param {Bool}						[inherit_lvl]		Heredar formula de nivel
	/// @param {Bool}						[inherit_display]	Heredar metodo de display
	/// @desc Copia el limite, valor inicial y formula de otro MallStat
	/// @return {Struct.MallStat}
    static inherit = function(_stat, _inh_limit=true, _inh_lvl=true, _inh_display=false) 
	{
		if (is_string(_stat) ) {
			/// @type {Struct.MallStruct}
			_stat = mall_get_stat(_stat);
		}

		// Copiar valor inicial
		numtype_copy(__initial, _stat.__initial);
		
        // Si se hereda el limite de valor
        if (_inh_limit) setLimits(_stat.__limits);
		
		#region Hereda nivel
		if (_inh_lvl) 
		{
	        __levelMethod = method(undefined, _stat.__levelMethod);	// Copiar formula para subir de nivel
			array_copy(__levelLimits, 0, _stat.__levelLimits, 0, 2);	// Copiar limite de nivel
		}
        
		#endregion
		
		#region Heredar display
        if (_inh_display) 
		{
			__display	 = _stat.__display;
			__displayKey = _stat.__displayKey;
			__displayMethod = method(undefined, _stat.__displayMethod);	
		}
		
		#endregion
        
        return self;
    }
    
    /// @param {Struct.MallStat} _stat
    static setLeader = function(_stat) 
	{
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
    
	/// @param {Real} initial_value
	/// @param {Real} number_type
	/// @param {Real} min
	/// @param {Real} max
	/// @desc	Establece el valor inicial, tipo de numero, el valor minimo y maximo
	/// @return {Struct.MallStat}
	static set = function(_initial, _type, _min, _max) 
	{ 
		__initial = numtype(_initial, _type);	
		return (setLimits(_min, _max) );
	}
	
    /// @param {Real} min
    /// @param {Real} [max]
	/// @return {Struct.MallStat}	
    static setLimits = function(_min, _max) 
	{
		if (!is_array(_min) ) 
		{
	    	__limits[0] = _min;
	    	__limits[1] = _max;
		} 
		else 
		{
			__limits[0] = _min[0];
			__limits[1] = _min[1];
		}
		
        return self;
    }
    
    /// @param {Real}		min_level		Nivel minimo def: 0
    /// @param {Real}		max_level		Nivel maximo def: 100
	/// @param {Function}	level_method	Forma de subir de nivel  function(level) (contexto __PartyStatAtom)
    /// @param {Bool}		[solo_level]	Aumenta de nivel ignorando el sistema para subir establecido.
	/// @return {Struct.MallStat}	
    static setLevel = function(_min=0, _max=100, _method, _single=false) 
	{
    	// Si ya existe un lider no usar
    	if (__leader == "") {
		    __levelMethod = _method;	// No usar scope local
		    __levelLimits = [_min, _max];
		    __levelSingle = _single;
		}
        return self;
    }
    
    /// @param {Real} min_level	Nivel minimo
    /// @param {Real} max_level	Nivel maximo
    static setLevelLimits = function(_min, _max) 
	{
    	if (!is_array(_min) ) {
			__lvlLimits[0] = _min;
			__lvlLimits[1] = _max;
		} else {
			__lvlLimits[0] = _min[0];
			__lvlLimits[1] = _max[1];
		}

    	return self;
    }
    
	/// @param {Real} iterate	cada cuantas ciclos deja la estadistica en su mayor nivel
    /// @param {Bool} [repeat]	si se repite luego al completar el trabajo
    /// @desc Al subir de nivel deja esta estadistica en su menor valor
	/// @return {Struct.MallStat}
    static toMin = function(_iterate=1, _repeat=true) {
		// Desactiva toMax
		__toMax.activate(false);
		__toMin.modify(_iterate, 1, _repeat).activate(true); 
		
        return self;
    }
    
	/// @param {Real} iterate	cada cuantas ciclos deja la estadistica en su mayor nivel
    /// @param {Bool} [repeat]	si se repite luego al completar el trabajo
    /// @desc Al subir de nivel deja esta estadistica en su nivel mayor. 
	/// @return {Struct.MallStat}
    static toMax = function(_iterate=1, _repeat=false) {
        // Desactiva toMin
        __toMin.activate(false);
        __toMax.modify(_iterate, 1, _repeat).activate(true);

        return self;
    }
    
    /// @param	{String}	state_key		LLave de estado
	/// @param	{Function}	effect_method	Que provoca el estado en esta estadistica
	/// @return {Struct.MallStat}
    static setEffect = function(_key, _method) 
	{
		__effect[$ _key] = _method;
        return self;
    }
    
    /// @param {String} state_key
	/// @desc Devuelve que estado lo afecta
    static getEffect = function(_key) 
	{
        return (__effect[$ _key] );    
    }
	
	/// @param {Real}							level
	/// @param {Struct.__PartyStatsComponent}	stat
	/// @param {Struct.PartyStats}				self
	static execute = function(_lvl, _stat, _self) 
	{
		return (__levelMethod(_lvl, _stat, _self) );	
	}
	
	/// @return {String}
	static toString = function() 
	{
		return (
			"value: " + string(__initial[0] ) + "\ntype: " + string(__initial[1] ) +
			"\nmin: " + string(__limits[0] )  + "\nmax: "  + string(__limits[1] )  +
			"\ntoMin: " + string(__toMin) + "\ntoMax: " + string(__toMax)
		);
	}
	
    #endregion
}
	
/// @param {Real} value
function __mall_stat_rounding(_x) 
{
	switch (MALL_STAT_ROUND) 
	{	
		case 0: return _x;		break;
		case 1: return round(_x);	break;
		case 2: return floor(_x);	break;
		
		default: return _x; break;
	}	
}