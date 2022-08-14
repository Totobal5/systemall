/// @param	{Struct.DarkEffect}	dark_effect
/// @return {Bool}
function is_dark_effect(_effect)
{
	return (is_struct(_effect) && _effect.__is == "DarkEffect");
}