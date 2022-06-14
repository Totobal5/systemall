/// @param	{String}			stat_key
/// @param	{Real}				[initial_value]	Para heredar rapidamente utilizar un Struct.MallStat
/// @param	{Real}				[min_value]
/// @param	{Real}				[max_value]
/// @param	{Real}				[number_type]
/// @param	{String, Undefined}	[display_key] 
/// @param	{Bool}				[display]
/// @desc	Permite configurar una estadistica a gusto en un grupo
/// @returns {Struct.MallStat}  
function mall_customize_stat(_key, _initial=0, _min=0, _max=9999, _type=0, _display_key, _display=true) {
    /// @type {Struct.MallStat}
	var _stat = mall_get_stat(_key); 
	
	if (!is_string(_initial) ) 
	{
		// Establecer el valor normalmente
		_stat.set(_initial, _type, _min, _max);
	} 
	else 
	{
		// heredar rapidamente
		_stat.inherit(_initial,,, true);
	}
	
    return (_stat).setDisplay(_display, _display_key);
}