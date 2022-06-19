/// @param	{Real} number_type
/// @param	{Real} start_value
/// @param	{Bool} start_boolean
/// @param	{Bool} [unique]
/// @return {Struct.__PartyControlAtom}
function __PartyControlAtom(_type, _value, _bol, _unique=false) constructor 
{
	__type = _type;						// Que tipo de numero usa la estadistica/estado
	__init = [_value, _value, _bol];	// Valor al que reinicia la estadistica/estado
	
	affected = false;	// Si es objetivo de un/os efecto
	same = false;		// Si acepta el mismo control varias veces
	
	// Valores que varian en el tiempo [real, percentual, booleano], son actualizados por los effectos.
	values  = [0, 0, _bol];		
	content = (_unique) ? undefined : []; 	// Donde se guardan los contenidos	
}