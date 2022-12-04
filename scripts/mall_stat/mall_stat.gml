/// @desc Donde se guardan las propiedades de una estadistica
/// @param {String}	statKey
/// @param {Bool} [useIterator]
function MallStat(_statKey) : MallState(_statKey) constructor 
{
	// True: enviar actual al maximo al equipar false: dejar como esta
	
	/// @desc Este evento se utiliza cuando se equipa un objeto
	setEquipSE(,function(_entity, _stat) {_stat.actual = _stat.control; });
	
	start = 0;     // Valor inicial
	limitMin = 0;  // Limites del valor 0 minimo 1 maximo
	limitMax = 0;  //
	// Nivel minimo y maximo
	levelLimitMin = MALL_STAT_DEFAULT_LEVEL_MIN;
	levelLimitMax = MALL_STAT_DEFAULT_LEVEL_MAX;
	levelSingle = false; // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
	
	/// @desc   Forma de subir de nivel
	/// @param  {Struct.PartyStats} statEntity
	/// @param  {Struct.PartyStats$$createAtom} statAtom
	/// @param  {Any*} [vars]
	/// @return {Real}
	funLevel = function(_stat, _atom, _vars) {return 0; };
	
	/// @desc   Indicar si puede o no subir de nivel si sube individual
	/// @param  {Struct.PartyStats} [statEntity]
	/// @param  {Any*} [vars]
	/// @return {Bool}
    checkLevel = function(_stat, _flag)  {return true; };

	iterator = new iteratorCreate();
	
    #region METHODS
	/// @desc Copia el limite, valor inicial y formula de otro MallStat
	/// @param {string} stat_key				MallStat o llave
	/// @param {bool} [inherit_limit=true]		Heredar limites
	/// @param {bool} [inherit_lvl=true]		Heredar nivel
	static inherit = function(_KEY, _LIMIT=true, _LVL=true)
	{
		// Se paso un string y se debe buscar la estadistica
		var _stat = mall_get_stat(_KEY);
		
		// Copiar valor inicial y el tipo
		start = _stat.start;
		type  = _stat.type;
		
		// Heredar limite de valor
		if (_LIMIT)	{setLimits(_stat.limitMin, _stat.limitMax); }
		
		// Hereda nivel
		if (_LVL) {setEventLevel(_stat.levelLimitMin, _stat.levelLimitMax, _stat.eventLevel, _stat.levelSingle, _stat.checkLevel); }

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
	static setLimits = function(_limitMin, _limitMax) 
	{
		if (!is_array(_limitMin) ) { 
			limitMin = _limitMin;
			limitMax = _limitMax;
		} else {
			limitMin = _limitMin[0];
			limitMax = _limitMin[1];
		}
		return self;
	}


	/// @param {Real}		minLevel        Nivel minimo
	/// @param {Real}		maxLevel        Nivel maximo
	/// @param {Function}	levelFun        Forma de subir de nivel
	/// @param {Bool}		[soloLevel]     Aumenta de nivel ignorando el sistema para subir establecido.
	/// @param {Function}	[checkLevel]    Comprobacion para subir de nivel inidividualmente
	/// @return {Struct.MallStat}	
	static setLevel = function(_min, _max, _fun, _single=false, _check=undefined) 
	{
		// No usar method (se utiliza luego en los componentes individuales)
		eventLevel = _fun;
		checkLevel = _check ?? checkLevel;

		// Niveles de nivel minimo y maximo
		levelLimitMin = _min ?? MALL_STAT_DEFAULT_LEVEL_MIN;
		levelLimitMax = _max ?? MALL_STAT_DEFAULT_LEVEL_MAX;
		levelSingle = _single;
		
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


	/// @desc Regresa la funcion de como debe subir de nivel
	static getFunLevel = function() 
	{
		return (funLevel);
	}


	/// @desc Regresa la funcion de como comprobar si debe o no subir de nivel
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

/// @desc Crear un (o varios) stats
/// @param {String} statKey
/// @param ...
function mall_add_stat() 
{
	static stats = MallDatabase().stats;
	static keys  = MallDatabase().statsKeys;
	
    var i=0; repeat(argument_count) {
		var _key = argument[i];
		if (!variable_struct_exists(stats, _key) ) {
			stats[$ _key] = new MallStat(_key);
			array_push(keys, _key);
			if (MALL_TRACE) {show_debug_message("MallRPG (addStat): {0} added", _key); }	
		}
		
		i = i+1;
	}
}

/// @param	{String} statKey
/// @desc	Devuelve la estructura de la estadistica
/// @return {Struct.MallStat}
function mall_get_stat(_statKey) 
{
	static stats = MallDatabase().stats;
	return (stats[$ _statKey] );
}

/// @param {String}	statKey
function mall_exists_stat(_statKey)
{
	static stats = MallDatabase().stats;
	return (variable_struct_exists(stats, _statKey) );
}

/// @desc	Permite configurar una estadistica
///			Para el dispay method tener en cuenta que lo esta ejecutando un "__PartyStatsAtom"
///			variables comunes: "control", "equipment", "peak", "peakLast", "actual", "actualLast", "valueMin"
/// @param	{String}        statKey         Llave de la estadistica
/// @param	{Real}          initialValue    Valor inicial de la estadistica
/// @param	{Real}          [numtype]       Tipo de numero 0: Real 1: Percent
/// @param  {Array<Real>}   [limitValue]    LimiteMinimo, LimiteMaximo
/// @param	{String}        [displayKey]    Llave para traducciones en lexicon
/// @returns {Struct.MallStat}
function mall_customize_stat(_statKey, _initial=0, _numType=0, _limit, _displayKey=_statKey) 
{
	var _stat = mall_get_stat(_statKey);
	if (MALL_ERROR) {
		if (_stat==undefined) show_error("MallRPG (customStat): no existe la llave de estadistica", false); 
	}
	
	_limit ??= [MALL_STAT_DEFAULT_MIN, MALL_STAT_DEFAULT_MAX];
	_stat.setValue(_initial, _numType, _limit);
	return (_stat.setDisplayKey(_displayKey) );
}

/// @param	{String}		statKey            Llave de la estadistica
/// @param	{String}		statParentKey      Llave de la estadistica a heredar
/// @param  {Array<Real>}   [inheritLimits]    Heredar limites de valores
/// @param  {Array<Real>}   [inheritLevel]     Heredar configuracion de nivel
/// @param	{String}		[displayKey]      Llave para traducciones en lexicon
function mall_inherit_stat(_childKey, _parentKey, _inhLimits, _inhLevel, _displayKey=_childKey)
{
	var _stat = mall_get_stat(_childKey);
	if (MALL_ERROR) {
		if (_stat==undefined) show_error("MallRPG (inheritStat): no existe la llave de estadistica", false); 
	}
	var _stat = mall_get_stat(_childKey);
	_stat.inherit(_parentKey, _inhLimits, _inhLevel);
	return (_stat.setDisplayKey(_displayKey) );
}

/// @desc Devuelve un array con las llaves de todos las estadisticas creadas
/// @return {Array<String>}
function mall_get_stat_keys(_copy=false) 
{
	static keys = MallDatabase().statsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}