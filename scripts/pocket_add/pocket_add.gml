/// @param	{String}			pocket_key
/// @param	{Struct.PocketItem}	pocket_item
/// @param	{String}			[display_key]
/// @param	{Function}			[display_method]
/// @desc	Crea un objeto y lo agrega a la base de datos
/// @return {Struct.PocketItem}
function pocket_add(_KEY, _ITEM, _DISPLAY_KEY, _DISPLAY_METHOD) 
{
    if (!pocket_exists(_KEY) ) 
	{
        global.__mallPocketData[$ _KEY] = _ITEM.setKey(_KEY);
		_ITEM.setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);
    }
	
    return (_ITEM );
}