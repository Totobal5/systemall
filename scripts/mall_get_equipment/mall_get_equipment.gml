/// @param	{String} equipment_key
/// @desc	Devuelve la estructura de la parte
/// @returns {Struct.MallEquipment}
function mall_get_equipment(_KEY) 
{
	return (global.__mallEquipmentMaster[$ _KEY] );
}