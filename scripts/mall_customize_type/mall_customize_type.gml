/// @desc Devuelve un tipo para ser modificar
/// @param	{String}	type_key
/// @param	{String}	[display_key]		Llave para traducciones en lexicon
/// @param	{Function}	[display_method]	function([FLAG]) {return string; }
/// @return {Struct.MallType}
function mall_customize_type(_KEY, _DISPLAY_KEY, _DISPLAY_METHOD)
{
	var _type = mall_get_type(_KEY);
	_type.setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);
	
	return (_type );
}