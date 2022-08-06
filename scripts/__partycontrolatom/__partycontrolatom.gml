/// @param	{Bool}	bool_start
/// @param  {Real}	default_type
/// @param  {Real}	limit
/// @return {Struct.__PartyControlAtom}
function __PartyControlAtom(_BOOL, _TYPE, _LIMITS=-1) constructor 
{
	__init = _BOOL;			// Valor al que reinicia la estadistica/estado
	__defaultType = _TYPE	// Al sumar o obtener utilizar este al no especificar
	
	// Valores que varian en el tiempo [real, percentual] son actualizados por los effectos.
	__values  = array_create(2, 0);
	__content = [];	// Donde se guardan los contenidos
	
	__affected = false;	// Si es objetivo de un/os efecto
	__same  = false;	// Si acepta el mismo control varias veces
	__limit = _LIMITS;	// -1 se pueden agregar elementos infinitos
	
	/// @return {Array<Struct.DarkEffect>}
	static get = function() 
	{
		return __content;
	}
}