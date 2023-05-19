// Feather ignore all

/// @desc Donde se guardan las propiedades de una estadistica
/// @param {String}	statKey
function MallStat(_statKey) : MallMod(_statKey) constructor 
{
	init = false;             // Valor inicial del estado
	type = MALL_NUMTYPE.REAL; // Tipo de numero que utiliza
	
	same     = false;   // Si acepta el mismo efecto varias veces
	controls = -1;      // Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0)	
	
	// True: enviar actual al maximo al equipar false: dejar como esta
	saveValue = false;
	
	/// @desc Este evento se utiliza cuando se equipa un objeto
	static equip = function(entity, stat) {actual = control; }
	
	
	start      = 0; // Valor inicial
	startLevel = 1; // Nivel inicial
	limitMin = 0;   // Limite del valor minimo
	limitMax = 0;   // Limite del valor maximo
	
	// Nivel minimo y maximo
	levelLimitMin = MALL_STAT_DEFAULT_LEVEL_MIN;
	levelLimitMax = MALL_STAT_DEFAULT_LEVEL_MAX;
	levelSingle = false; // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
	
	// Iterador
	iterator = new MallIterator();
	
	/// @desc   Forma de subir de nivel
	/// @param  {Struct.PartyStats} statEntity
	/// @param  {Struct.PartyStats$$createAtom} statAtom
	/// @param  {Any*} [vars]
	/// @return {Real}
	static levelUp = function(stats, atom) {return 0;}
	
	/// @desc   Indicar si puede o no subir de nivel si sube individual
	/// @param  {Struct.PartyStats} [statEntity]
	/// @param  {Any*} [vars]
	/// @return {Bool}
	static checkLevel  = function(stats) {return false; }
	
	/// @param {Struct.PartyStats} entity
	static entityUpdate = function(entity) {}
	
	
	/// @param {Bool} iteratorType
	static iterActivate = function(_type)
	{
		iterator.active =  true;
		iterator.type   = _type;
		return (self);
	}	
	
	/// @desc Establece los valores del iterador
	/// @param {real} countMax          Cuanta veces iterar
	/// @param {bool} [repeat]=true     Si repite luego de completarse
	/// @param {real} [repeatMax]=-1    Cuentas veces se repetira
	static iterSet = function(_countMax=1, _repeat=true, _repeatsMax=-1)
	{
		iterator.active = true;
		iterator.count  = 0;
		iterator.countLimits = _countMax;
		
		iterator.reset = _repeat;
		iterator.resetCount  = 0;
		iterator.resetLimits = _repeatsMax;
		return (self);
	}

	/// @desc Establece los valores del iterador. Al completar llevara algun valor a su minimo
	/// @param {real} countMax          Cuanta veces iterar
	/// @param {bool} [repeat]=true     Si repite luego de completarse
	/// @param {real} [repeatMax]=-1    Cuentas veces se repetira
	static iterSetMin = function(_countMax=1, _repeat=true, _repeatsMax=-1)
	{
		iterSet(_countMax, _repeat, _repeatsMax);
		iterator.type = false;
		return (self);
	}

	/// @desc Establece los valores del iterador. Al completar llevara algun valor a su maximo
	/// @param {real} countMax          Cuanta veces iterar
	/// @param {bool} [repeat]=true     Si repite luego de completarse
	/// @param {real} [repeatMax]=-1    Cuentas veces se repetira
	static iterSetMax = function(_countMax=1, _repeat=true, _repeatsMax=-1)
	{
		iterSet(_countMax, _repeat, _repeatsMax);
		iterator.type = true;
		return (self);
	}
}

/// @param {String}          statKey
/// @param {Struct.MallStat} Stat
function mall_create_stat(_statKey, _component) 
{
	static stats = MallDatabase.stats;
	static keys  = MallDatabase.statsKeys;
	
	if (!variable_struct_exists(stats, _statKey) ) {
		stats[$ _statKey] = _component;
		array_push(keys, _statKey);
	}
}

/// @param {String} statKey
/// @desc Devuelve la estructura de la estadistica
/// @return {Struct.MallStat}
function mall_get_stat(_statKey) 
{
	static stats = MallDatabase.stats;
	return (stats[$ _statKey] );
}

/// @param {String}	statKey
function mall_exists_stat(_statKey)
{
	static stats = MallDatabase.stats;
	return (variable_struct_exists(stats, _statKey) );
}

/// @desc Devuelve un array con las llaves de todos las estadisticas creadas
/// @return {Array<String>}
function mall_get_stat_keys(_copy=false) 
{
	static keys = MallDatabase.statsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}