/// @param	{Real}	number_type
/// @param	{Bool}	start_boolean
/// @param	{Bool}	[unique]
/// @param  {Real}	[limits]
/// @return {Struct.__PartyControlAtom}
function __PartyControlAtom(_type, _boolean, _unique=false, _limits) constructor 
{
	#region Private
	__type = _type;		// Que tipo de numero usa la estadistica/estado
	__init = _boolean;	// Valor al que reinicia la estadistica/estado
	
	#endregion
	
	// Valores que varian en el tiempo [real, percentual] son actualizados por los effectos.
	values  = array_create(2, 0);		
	content = (_unique) ? undefined : []; 	// Donde se guardan los contenidos
	
	affected = false;	// Si es objetivo de un/os efecto
	same  = false;		// Si acepta el mismo control varias veces
	limit = _limits;	// Solo si unique es false. -1 indica que se pueden agregar elementos infinitos.
	
	// Evitar errores
	if (limit == 0) limit = -1;
	
	static __isAffected = function()
	{
		return (affected != __init);	
	}
}