// Feather ignore all

/// @param	{String} component_key
/// @param	{Struct.MallStat} component
/// @return {Struct.__PartyControlAtom}
function __PartyControlAtom(_KEY, _MALL) constructor 
{
	// Configuracion
	key = _KEY
	init = _MALL.init;	// Valor al que reinicia la estadistica/estado
	type = _MALL.type;	// Tipo de numero que utiliza normalmente

	control = _MALL.controls;	// -1 se pueden agregar elementos infinitos
	same	= _MALL.same;		// Si acepta el mismo control varias veces

	// Valores que varian en el tiempo [real, percentual] son actualizados por los effectos.
	values = array_create(2, 0);
	
	// Contenidos
	content = [];
	contentKey = {};
	
	// Si algo evita que esta en el valor de bool
	isAffected = false;

	/// @return {Array<Struct.DarkEffect>}
	static getContent = function()
	{
		return content;
	}
	
	static set = function(_VALUE, _TYPE)
	{
		_TYPE ??= type;
		values[_TYPE] = _VALUE;
	}
	
	static add = function(_VALUE, _TYPE)
	{
		_TYPE ??= type;
		values[_TYPE] += _VALUE;
	}
}