/// @param	{String}	equipment_key
/// @param	{String}	[display_key]		Llave para traducciones en lexicon
/// @param	{Function}	[display_method]	function([FLAG]) {return string; } (Referencia PartyEquipmentAtom)
/// @returns {Struct.MallEquipment}
function mall_customize_equipment(_KEY, _DISPLAY_KEY, _DISPLAY_METHOD) 
{
    var _equipment = mall_get_equipment(_KEY);
	_equipment.setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);
	
    return (_equipment);
}