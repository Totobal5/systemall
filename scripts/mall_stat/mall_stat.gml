/// @param {String}	stat_key
/// @desc Donde se guardan las propiedades de una estadistica
function MallStat(_KEY) : MallComponent(_KEY) constructor 
{
    #region PRIVATE
    __effect = {};	// Que efecto tiene un estado sobre esta estadistica

	__valueInit = array_create(2, 0);	// Valor inicial default
    __valueLims = array_create(2, 0);	// Limites del valor global
    
	__modifyCount	= -1;	// Cuantas modificaciones puede tener
	__modifyPercent =  0;	// Probabilidad default
	__modifyAcceptSame = false;	// Si permite el mismo efecto varias veces
	
	#region Level
	__levelLims = [MALL_STAT_DEFAULT_LEVEL_MIN, MALL_STAT_DEFAULT_LEVEL_MAX]; // Nivel minimo y maximo 
	__levelSingle = false; // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
	
	/// @param {Struct.PartyStats}		 stat_entity
	/// @param {Struct.__PartyStatsAtom} stat_atom
	/// @param {Any} [Any]
	/// @return {Real}
	__levelEvent = function(STAT_ENTITY, STAT_ATOM, _FLAG) {return 0; }; // Forma de subir de nivel
	
	/// @param {Struct.PartyStats}	[stat_entity]
	/// @return {Bool}
    __levelCheck = function(STAT_ENTITY=undefined)  {return true; }; // Indicar si puede o no subir de nivel si sube individual
	
	#endregion
	
	__toValue = new makeTo();
	
	#endregion
	
    #region METHODS
	/// @param {Struct.MallStat or String}	stat				MallStat o llave
	/// @param {Bool}						[inherit_limit]		Heredar valor
	/// @param {Bool}						[inherit_lvl]		Heredar nivel
	/// @param {Bool}						[inherit_display]	Heredar display
	/// @desc Copia el limite, valor inicial y formula de otro MallStat
	/// @return {Struct.MallStat}
    static inherit = function(_STAT, _LIMIT=true, _LVL=true, _DISPLAY=false) 
	{
		// Se paso un string y se debe buscar la estadistica
		if (is_string(_STAT) ) _STAT = mall_get_stat(_STAT);
		
		// Copiar valor inicial
		__valueInit[0] = _STAT.__valueInit[0];
		__valueInit[1] = _STAT.__valueInit[1];

		// Heredar limite de valor
        if (_LIMIT) setLimits(_STAT.__valueLims);
	
		// Hereda nivel
		if (_LVL) setLevel(method(undefined, _STAT.__levelMethod), _STAT.__levelLims[0], _STAT.__levelLims[1] );
		
		// Heredar display
        if (_DISPLAY) setDisplay(_STAT.__displayKey, method(undefined, _STAT.__displayMethod) );
		
		#endregion
        
        return self;
    }
    
	static makeTo = function() constructor 
	{
		__active = false;	
		__tomin = true;	// true: to min, false: to max
		
		__count = 0;	// Valor de la cuenta
		__countLim = 1;	// Limite de la cuenta	
		
		__reset = false;
		__resetCount = 0; // Veces que se ha reseteado	
		__resetLim	 = 1; // Limite de resets
		
		static copy = function()
		{
			var _to = new makeTo();
			_to.__active = __active;
			_to.__tomin  =  __tomin;
			_to.__count    = __count;	 // Valor de la cuenta
			_to.__countLim = __countLim; // Limite de la cuenta	
			
			_to.__reset = __reset;
			_to.__resetCount = __resetCount; // Veces que se ha reseteado	
			_to.__resetLim	 = __resetLim;   // Limite de resets
			return _to;
		}
	
		/// @desc  Devuelve true al completar la iteracion, false si aun no se cumple
		/// @returns {bool} Description		
		static iterate = function()
		{
			if (__count > __countLim)
			{
				__count += 1;
				return false;
			}
			else
			{
				return (reset() );
			}
		}	
		
		/// @desc Function Description
		/// @returns {bool} Description		
		static reset = function()
		{
			if (__reset)
			{
				if (__resetLim > 0)
				{
					if (__resetCount < __resetLim) 
					{
						__resetCount += 1;	
						
						return false;
					}
					else
					{
						__active = false;
						__count    = 0;
						__countLim = 0;
						
						return true;
					}
				}
				else
				{
					__count = 0;
					return true;
				}
			}
			else
			{
				__active = false;	
				__count  = 0;
				
				return true;
			}
		}
		
		/// @desc Devuelve si es toMin (true) o toMax (false)
		/// @returns {bool} Description			
		static type = function()
		{
			return (__tomin);
		}
		
		/// @desc Devuelve si esta activo
		/// @returns {bool} Description		
		static active = function()
		{
			return (__active);	
		}
	}
	
	/// @param {Real} initial_value
	/// @param {Real} number_type
	/// @param {Real} min
	/// @param {Real} max
	/// @desc	Establece el valor inicial, tipo de numero, el valor minimo y maximo
	/// @return {Struct.MallStat}
	static set = function(_INITIAL, _TYPE, _MIN, _MAX) 
	{ 
		__valueInit = [_INITIAL, _TYPE];
		return (setLimits(_MIN, _MAX) );
	}
	
    /// @param {Real} min
    /// @param {Real} [max]
	/// @return {Struct.MallStat}	
    static setLimits = function(_MIN, _MAX) 
	{
		if (!is_array(_MIN) ) 
		{
	    	__valueLims[0] = _MIN;
	    	__valueLims[1] = _MAX;
		} 
		else 
		{
			__valueLims[0] = _MIN[0];
			__valueLims[1] = _MIN[1];
		}
		
        return self;
    }
    
	/// @param {Function}	level_method	Forma de subir de nivel  function(LEVEL, STAT_ATOM, STAT_ENTITY) {return Real}
    /// @param {Real}		min_level		Nivel minimo
    /// @param {Real}		max_level		Nivel maximo
    /// @param {Bool}		[solo_level]	Aumenta de nivel ignorando el sistema para subir establecido.
	/// @param {Function}	[check_level]	Comprobacion para subir de nivel inidividualmente function(LEVEL, STAT_ATOM, STAT_ENTITY) {return Bool}
	/// @return {Struct.MallStat}	
    static setLevel = function(_METHOD, _MIN, _MAX, _SINGLE=false, _CHECK) 
	{
		// Niveles de nivel minimo y maximo
		_MIN ??= MALL_STAT_DEFAULT_LEVEL_MIN;
		_MAX ??= MALL_STAT_DEFAULT_LEVEL_MAX;
		
		__levelLims = [_MIN, _MAX];
		__levelEvent = _METHOD; // No usar method (se utiliza luego en los componentes individuales)
		__levelCheck = _CHECK ?? __levelCheck;
		
		__levelSingle = _SINGLE;
		
        return self;
    }
    
    /// @param {Real} level_min	Nivel minimo
    /// @param {Real} level_max	Nivel maximo
    static setLevelLimits = function(_MIN, _MAX) 
	{
    	if (!is_array(_MIN) ) 
		{
			__levelLims[0] = _MIN;
			__levelLims[1] = _MAX;
		} 
		else 
		{
			__levelLims[0] = _MIN[0];
			__levelLims[1] = _MIN[1];
		}

    	return self;
    }
    
	/// @param {Real} iterate			cada cuantas ciclos deja la estadistica en su mayor nivel
    /// @param {Bool} [repeat]			si se repite luego al completar el trabajo
	/// @param {Real} [repeat_iterate]	en que iteracion se desactiva la repeticion
    /// @desc Al subir de nivel deja esta estadistica en su menor valor
	/// @return {Struct.MallStat}
    static toMin = function(_ITERATE=1, _REPEAT=true, _REPEAT_ITER=-1)
	{
		__toValue.__active = true;
		__toValue.__tomin  = true;	

		__toValue.__count = 0;
		__toValue.__countLim = _ITERATE;
		
		__toValue.__reset = _REPEAT;
		__toValue.__resetCount = 0;
		__toValue.__resetLim   = _REPEAT_ITER;
		
        return self;
    }
    
	/// @param {Real} iterate	cada cuantas ciclos deja la estadistica en su mayor nivel
    /// @param {Bool} [repeat]	si se repite luego al completar el trabajo
	/// @param {Real} [repeat_iterate]	en que iteracion se desactiva la repeticion
    /// @desc Al subir de nivel deja esta estadistica en su mayor valor. 
	/// @return {Struct.MallStat}
    static toMax = function(_ITERATE=1, _REPEAT=true, _REPEAT_ITER=-1) 
	{
		__toValue.__active =  true;
		__toValue.__tomin  = false;	

		__toValue.__count = 0;
		__toValue.__countLim = _ITERATE;
		
		__toValue.__reset = _REPEAT;
		__toValue.__resetCount = 0;
		__toValue.__resetLim   = _REPEAT_ITER;
		
        return self;
    }
    
	/// @param {Struct.PartyStats}		 stat_entity
	/// @param {Struct.__PartyStatsAtom} stat_atom
	static executeLevel = function(_STAT_ENTITY, _STAT_ATOM) 
	{
		return (__levelEvent(_STAT_ENTITY, _STAT_ATOM) );	
	}

	/// @return {String}
	static toString = function() 
	{
		return (
			"value: " + string(__valueInit[MALL_NUMVAL.VALUE] )  + "\ntype: " + string(__valueInit[MALL_NUMVAL.TYPE] ) +
			"\nmin: " + string(__valueLims[0] )  + "\nmax: "  + string(__valueLims[1] )  +
			"\ntoValue: " + string(__toValue)
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