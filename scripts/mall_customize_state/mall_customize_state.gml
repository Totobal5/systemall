/// @param	{String}	state_key
/// @param	{Real}		boolean
/// @param	{Real}		[limit]				def: -1
/// @param	{Boolean}	[display]
/// @param  {String}	[display_key]
/// @param	{Function}	[display_method]	function(event) {return string; }
/// @returns {Struct.MallState}
function mall_customize_state(_key, _boolean, _limit=-1, _display=true, _display_key, _display_method) 
{
    var _state = mall_get_state(_key);
    _state.basic(_boolean, _limit)
	
	// Display
	_state.setDisplay(_display, _display_key, _display_method);
	
    return (_state);
}