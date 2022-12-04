/// @param	{Struct.DarkEffect}	darkEffect
/// @return {Bool}
function is_dark_effect(_effect)
{
	return (is_struct(_effect) && _effect.is == "DarkEffect");
}