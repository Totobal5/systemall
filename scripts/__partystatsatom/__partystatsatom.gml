/// @param {String} stat_key
/// @param {Struct.MallStat} stat_entity
/// @return {Struct.__PartyStatsAtom}
function __PartyStatsAtom(_KEY, _STAT) constructor 
{
	#region PRIVATE
	__is  = instanceof(self);
	
	#endregion
	
	key = _KEY;
	displayMethod = method(,_STAT.displayMethod);
	displayKey = _STAT.displayKey;
	
	// -- Configuracion
	flag   = "";  // Algo que pasar en la formula para subir de nivel
	single = _STAT.levelSingle; // Si sube de nivel individualmente
	
	/// @param {Struct.PartyStats}		 stat_entity
	/// @param {Struct.__PartyStatsAtom} stat_atom
	/// @param {Any} [flag]
	/// @return {Real}
	/// @ignore
	event = function(_STAT_ENTITY, _STAT_ATOM, _FLAG) {};
	event = method(undefined, _STAT.eventLevel); // Forma en que sube de nivel
	
	/// @param {Struct.PartyStats}	[stat_entity]
	/// @return {Bool}
	/// @ignore
	check = function(_STAT_ENTITY) {};
	check = method(undefined, _STAT.checkLevel); // Condicion que debe cumplir para subir de nivel
	
	iterator = _STAT.iterator.copy();
	
	// Se pone el valor inicial
	base = _STAT.start;
	type = _STAT.type;
	
	level = 1; // Nivel de la estadistica si se usa individualmente
	// Valores que posee
	limitMin = _STAT.limitMin;	// Valor maximo en que la estadistica puede estar
	limitMax = _STAT.limitMax;	// Valor minimo en que la estadistica puede estar
	
	control   = base;	 // El valor final tomando en cuenta el control
	equipment = control; // El valor final tomando en cuenta el equipamiento
	
	peak   = control; // Valor de la estadistica actual maximo respecto al nivel
	actual = control; // El valor actual de la estadistica
	
	lastPeak   = control;// El ultimo valor maximo
	lastActual = control;// El anterior valor actual
	
	#endregion
	
	#region METHODS
	/// @desc Devuelve un struct con los valores actuales
	static send = function()
	{
		var _me = self;
		return 
		{
			key: _me.key,
			control:	_me.control,
			equipment:	_me.equipment,
			peak:		_me.peak,
			actual:		_me.actual,
			lastPeak:	_me.lastPeak,
			lastActual:	_me.lastActual
		}
	}
	
	#endregion
}