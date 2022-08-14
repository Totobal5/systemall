/// @param {String}	equipment_key
function mall_exists_equipment(_EQUIPMENT_KEY)
{
	return (variable_struct_exists(global.__mallEquipmentMaster, _EQUIPMENT_KEY) );
}