/// @param	{String}	modify_key			Llave del modificador		
/// @param	{String}	[display_key]		
/// @param	{Function}	[display_method]	function(flag) {return string; }
/// @returns {Struct.MallModify}
function mall_customize_modify(_KEY, _DISPLAY_KEY, _DISPLAY_METHOD) 
{
    var _modify = mall_get_modify(_KEY);
	_modify.setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);

	return (_modify);
}