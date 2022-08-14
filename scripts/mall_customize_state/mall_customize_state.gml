/// @param	{String}	state_key		llave del estado
/// @param	{Real}		start_boolean	boleano inicial
/// @param	{Real}		probability		probabilidad default
/// @param	{Real}		[control_max]	limites de estados en los controles
/// @param	{Bool}		[accept_same]	si permite el mismo estado en los controles
/// @param	{String}	[display_key]	llave para las traducciones
/// @param	{Function}	[display_method]	function(flag) {return string; }
/// @returns {Struct.MallState}
function mall_customize_state(_KEY, _BOOL, _PROBABILITY, _CONTROL, _SAME, _DISPLAY_KEY, _DISPLAY_METHOD) 
{	
	if (!mall_exists_state(_KEY) ) throw "No existe el state";
	
    var _state = mall_get_state(_KEY);
    _state.setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);
	_state.setControl(_BOOL, _PROBABILITY, _CONTROL, _SAME);
    return (_state);
}