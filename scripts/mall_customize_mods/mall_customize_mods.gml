/// @param	{String}					element_key		Llave del elemento
/// @param	{Bool}						[display]			
/// @param	{String}					[display_key]		
/// @param	{Function}					[display_method]	function() {return string; }
/// @returns {Struct.MallMod}
function mall_customize_mod(_KEY, _DISPLAY, _DISPLAY_KEY, _DISPLAY_METHOD) 
{
    var _element = mall_get_mod(_KEY);
	_element.setDisplay(_DISPLAY, _DISPLAY_KEY, _DISPLAY_METHOD);

	return (_element);
}