/// @desc Donde se guardan las propiedades de una estadistica
/// @param {String}	stat_key
function MallStat(_KEY) : MallState(_KEY) constructor 
{
	#region PRIVATE
	__is = instanceof(self);
	
	#endregion
	start  = 0; // Valor inicial
	limitMin = 0; // Limites del valor 0 minimo 1 maximo
	limitMax = 0; //
	// Nivel minimo y maximo
	levelLimitMin = MALL_STAT_DEFAULT_LEVEL_MIN;
	levelLimitMax = MALL_STAT_DEFAULT_LEVEL_MAX;
	levelSingle = false; // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
	
	/// @param	{Struct.PartyStats} stat_entity
	/// @param	{Struct.__PartyStatsAtom} stat_atom
	/// @param	{Any*} [flag]
	/// @return	{Real}
	eventLevel = function(STAT_ENTITY, STAT_ATOM, _FLAG) {return 0; }; // Forma de subir de nivel
	
	/// @param	{Struct.PartyStats} [stat_entity]
	/// @param	{Any*} [flag]
	/// @return	{Bool}
    checkLevel = function(STAT_ENTITY, _FLAG)  {return true; }; // Indicar si puede o no subir de nivel si sube individual

	#endregion
	
    #region METHODS
	/**
	Copia el limite, valor inicial y formula de otro MallStat
	@param {string} stat_key				MallStat o llave
	@param {bool} [inherit_limit=true]		Heredar valor
	@param {bool} [inherit_lvl=true]		Heredar nivel
	@param {bool} [inherit_display=false]	Heredar display
	*/
	static inherit = function(_KEY, _LIMIT=true, _LVL=true, _DISPLAY=false)
	{
		// Se paso un string y se debe buscar la estadistica
		var _stat = mall_get_stat(_KEY);
		
		// Copiar valor inicial y el tipo
		start = _stat.start;
		type  = _stat.type;
		
		// Heredar limite de valor
		if (_LIMIT)	
		{
			setLimits(_stat.limitMin, _stat.limitMax);
		}
		
		// Hereda nivel
		if (_LVL)
		{
			setEventLevel(_stat.eventLevel, _stat.levelLimitMin, _stat.levelLimitMax, _stat.levelSingle, _stat.checkLevel);
		}
		
		// Heredar display
        if (_DISPLAY)	
		{
			setDisplay(_stat.displayKey, _stat.displayMethod);
		}
		
		#endregion
        
        return self;
    }

	/// @desc	Establece el valor inicial, tipo de numero, el valor minimo y maximo
	/// @param {Real} initial_value
	/// @param {Real} number_type
	/// @param {Real} min
	/// @param {Real} max
	/// @return {Struct.MallStat}
	static setValue = function(_VALUE, _TYPE, _MIN, _MAX) 
	{ 
		start = _VALUE;
		type  =  _TYPE;
		return (setLimits(_MIN, _MAX) );
	}
	
	/// @desc Establecer limites de los valores
	/// @param {Real} min
	/// @param {Real} max
	/// @return {Struct.MallStat}
	static setLimits = function(_MIN, _MAX) 
	{
		limitMin = _MIN;
		limitMax = _MAX;
		return self;
	}

	/// @param {Function}	level_method	Forma de subir de nivel
    /// @param {Real}		min_level		Nivel minimo
    /// @param {Real}		max_level		Nivel maximo
	/// @param {Bool}		[solo_level]	Aumenta de nivel ignorando el sistema para subir establecido.
	/// @param {Function}	[check_level]	Comprobacion para subir de nivel inidividualmente
	/// @return {Struct.MallStat}	
    static setEventLevel = function(_METHOD, _MIN, _MAX, _SINGLE=false, _CHECK=undefined) 
	{
		eventLevel = _METHOD; // No usar method (se utiliza luego en los componentes individuales)
		checkLevel = _CHECK ?? checkLevel;

		// Niveles de nivel minimo y maximo
		levelLimitMin = _MIN ?? MALL_STAT_DEFAULT_LEVEL_MIN;
		levelLimitMax = _MAX ?? MALL_STAT_DEFAULT_LEVEL_MAX;
		levelSingle = _SINGLE;
		
		return self;
    }
	
    /// @param {Real} level_min	Nivel minimo
    /// @param {Real} level_max	Nivel maximo
    static setLevelLimits = function(_MIN, _MAX) 
	{
		levelLimitMin = _MIN;
		levelLimitMax = _MAX;
    	return self;
    }

	/// @return {Function}
	static getEventLevel = function() 
	{
		return (eventLevel);
	}

	static getCheckLevel = function()
	{
		return (checkLevel);
	}

	/// @return {String}
	static toString = function() 
	{
		return ("");
	}
	
    #endregion
}