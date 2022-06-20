/// @param	{String}	stat_key			
/// @param	{Real}		[initial_value]		Para heredar rapidamente utilizar un Struct.MallStat
/// @param	{Real}		[min_value]			Cuando hereda indica si hereda el limite {Bool}
/// @param	{Real}		[max_value]			Cuando hereda indica si hereda el level  {Bool}
/// @param	{Real}		[number_type]		Cuando hereda indica si hereda el display {Bool}
/// @param	{Bool}		[display]			
/// @param	{String}	[display_key]		
/// @param	{Function}	[display_method]	function() {return string; }
/// @desc	Permite configurar una estadistica a gusto en un grupo.
///			Para el dispay method tener en cuenta que lo esta ejecutando un "__PartyStatsAtom"
///			variables comunes: "valueControl", "valueEquipment", "valueMax", "valueMaxLast", "valueActual", "valueLast", ""valueMin"
/// @returns {Struct.MallStat}
function mall_customize_stat(_key, _initial=0, _min=MALL_STAT_DEFAULT_MIN, _max=MALL_STAT_DEFAULT_MAX, _type=NUMTYPES.REAL, _display=true, _display_key, _display_method) 
{
	// Obtener estadistica
	var _stat = mall_get_stat(_key); 
	
	if (!is_string(_initial) ) 
	{
		#region Establecer normalmente
		// Establecer el valor normalmente
		_stat.set(_initial, _type, _min, _max);
		
		// Establecer display
		return (_stat.setDisplay(_display, _display_key, _display_method) );
		#endregion
	} 
	else 
	{
		#region Heredar
		if (_min  == MALL_STAT_DEFAULT_MIN)	_min  = undefined;	// Heredar limite
		if (_max  == MALL_STAT_DEFAULT_MAX)	_max  = undefined;	// Heredar level	
		if (_type == NUMTYPES.REAL)			_type = undefined;	// Hereda display

		return (_stat.inherit(_initial, _min, _max, _type) );		
		#endregion
	}
}