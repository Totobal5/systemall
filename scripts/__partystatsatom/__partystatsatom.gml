/// @param {String} stat_key
/// @param {Struct.MallStat} stat_entity
/// @return {Struct.__PartyStatsAtom}
function __PartyStatsAtom(_KEY, _STAT) : MallComponent(_KEY) constructor 
{
	#region PRIVATE
	// Establecer localmente el display
	setDisplay(_STAT.__displayKey, method(undefined, _STAT.__displayMethod));

	// -- Configuracion
	/// @ignore
	__flag = "";  // Algo que pasar en la formula para subir de nivel
	/// @ignore
	__single = _STAT.__levelSingle; // Si sube de nivel individualmente
	
	/// @param {Struct.PartyStats}		 stat_entity
	/// @param {Struct.__PartyStatsAtom} stat_atom
	/// @param {Any} [flag]
	/// @return {Real}
	/// @ignore
	__event = function(_STAT_ENTITY, _STAT_ATOM, _FLAG) {};
	__event = method(undefined, _STAT.__levelEvent); // Forma en que sube de nivel
	
	/// @param {Struct.PartyStats}	[stat_entity]
	/// @return {Bool}
	/// @ignore
	__check = function(_STAT_ENTITY) {};
	__check = method(undefined, _STAT.__levelCheck); // Condicion que debe cumplir para subir de nivel
	
	// Iteradores
	/// @ignore
	__toValue = _STAT.__toValue.copy();
	
	#endregion
	
	#region PUBLIC
	
	// Se pone el valor inicial
	base  = _STAT.__valueInit;	// Se utiliza el array
	level = 1; // Nivel de la estadistica si se usa individualmente
	
	// Valores que posee
	limMin = _STAT.__valueLims[0];	// Valor maximo en que la estadistica puede estar
	limMax = _STAT.__valueLims[1];	// Valor minimo en que la estadistica puede estar
	control = 0;
	control = base[MALL_NUMVAL.VALUE]; // El valor final tomando en cuenta el control
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
		return 
		{
			key: other.__key,
			control:	other.control,
			equipment:	other.equipment,
			peak:		other.peak,
			actual:		other.actual,
			lastPeak:	other.lastPeak,
			lastActual:	other.lastActual
		}
	}
	
	#endregion
}