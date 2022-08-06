/// @param	{String}		equipment_key
/// @param	{Real}			equip_max	
/// @returns {Struct.MallEquipment}
function mall_customize_equipment(_KEY, _EQUIP=1) 
{
    var _part = mall_get_equipment(_KEY);
	_part.__numbers = _EQUIP;
   
    return (_part);
}