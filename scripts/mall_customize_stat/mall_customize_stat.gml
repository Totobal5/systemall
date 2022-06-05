/// @param	{String}			_key
/// @param	{Real}				[_initial]
/// @param	{Real}				[_min]
/// @param	{Real}				[_max]
/// @param	{Real}				[_type]
/// @param	{String, Undefined}	_display_key
/// @param	{Bool}				_display
/// @returns {Struct.MallStat}  Permite configurar una estadistica a gusto en un grupo
function mall_customize_stat(_key, _initial=0, _min=0, _max=9999, _type=0, _display_key, _display=true) {
    /// @type {Struct.MallStat}
	var _stat = mall_get_stat(_key); 
	
	if (!is_string(_initial) ) {
		_stat.set(_initial, _type, _min, _max);
	} else {
		// heredar rapidamente
		_stat.inherit(_initial,,, true);
	}
	
    return (_stat).setDisplay(_display, _display_key);
}