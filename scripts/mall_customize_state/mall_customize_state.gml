/// @param	{String}	state_key
/// @param	{Real}		boolean
/// @param	{Real}		[limit]				def: -1
/// @param	{Bool}		[display]
/// @param  {String}	[display_key]
/// @param	{Function}	[display_method]	function(event) {return string; }
/// @returns {Struct.MallState}
function mall_customize_state(_KEY, _BOOL, _LIMIT=-1, _DISPLAY=true, _DISPLAY_KEY, _DISPLAY_METHOD) 
{
    var _state = mall_get_state(_KEY);
    _state.basic(_BOOL, _LIMIT);
	_state.setDisplay(_DISPLAY, _DISPLAY_KEY, _DISPLAY_METHOD);
	
    return (_state);
}