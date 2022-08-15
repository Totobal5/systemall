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
        global.__mallPocketData [$ _KEY] = _ITEM.setKey(_KEY);
		
		if (!variable_struct_exists(global.__mallPocketTypes, _ITEM.type) )
		{
			var _st = {};
			global.__mallPocketTypes[$ _ITEM.type] = _st;
			_st[$ _KEY] = _KEY;
		}
		else
		{
			global.__mallPocketTypes[$ _ITEM.type][$ _KEY] = _KEY;
		}
		
		_ITEM.setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);
    }
	
    return (_ITEM );
}