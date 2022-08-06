/// @desc	Permite configurar una estadistica
///			Para el dispay method tener en cuenta que lo esta ejecutando un "__PartyStatsAtom"
///			variables comunes: "valueControl", "valueEquipment", "valueMax", "valueMaxLast", "valueActual", "valueLast", ""valueMin"
/// @param	{String}		stat_key			llave de la estadistica
/// @param	{Real,String}	initial_value		Para heredar rapidamente utilizar un Struct.MallStat
/// @param	{Real}			[number_type]		Tipo de numero 0: Real 1: Percent. Cuando hereda indica si hereda el display {Bool}
/// @param	{Real}			[min_value]			Cuando hereda indica si hereda el limite {Bool}
/// @param	{Real}			[max_value]			Cuando hereda indica si hereda el level  {Bool}
/// @param	{Bool}			[display]			
/// @param	{String}		[display_key]		
/// @param	{Function}		[display_method]	function() {return string; } (se ejecuta en base a PartyStatsAtom)
/// @returns {Struct.MallStat}
function mall_customize_stat(_KEY, _INITIAL=0, _TYPE=0, _MIN=MALL_STAT_DEFAULT_MIN, _MAX=MALL_STAT_DEFAULT_MAX, _DISPLAY=true, _DISPLAY_KEY, _DISPLAY_METHOD) 
{
	if (!mall_exists_stat(_KEY) )
	{
		show_error("mall_customize_stat no existe llave de estadistica", true);	
	}
	
	var _stat = mall_get_stat(_KEY);
	
	#region Establecer
	if (!is_string(_INITIAL) )
	{
		_stat.set(_INITIAL, _TYPE, _MIN, _MAX);
		return (_stat.setDisplay(_DISPLAY, _DISPLAY_KEY, _DISPLAY_METHOD) );
	}
	
	#endregion
	
	#region Heredar
	else
	{
		if (_MIN  == MALL_STAT_DEFAULT_MIN)	_MIN  = undefined;	// Heredar limite
		if (_MAX  == MALL_STAT_DEFAULT_MAX)	_MAX  = undefined;	// Heredar level	
		if (_TYPE == 0)						_TYPE = undefined;	// Hereda display
		return (_stat.inherit(_INITIAL, _MIN, _MAX, _TYPE) );
	}
	
	#endregion
}