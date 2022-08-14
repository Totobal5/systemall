/// @desc	Devuelve el equipamiento
/// @param	{String} equipment_key
/// @returns {Struct.MallEquipment}
function mall_get_equipment(_KEY) 
{
	return (global.__mallEquipmentMaster[$ _KEY] );
}