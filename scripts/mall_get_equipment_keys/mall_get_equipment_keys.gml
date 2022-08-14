// Feather ignore all

/// @desc Devuelve todos las llaves de partes
/// @returns {Array<String>}
function mall_get_equipment_keys() 
{
	return (global.__mallEquipmentKeys);
}

/// @desc Devuelve una copia de todas las llaves de las partes creadas
/// @return {Array<String>}
function mall_get_equipments_keys_copy() 
{
	var _stats = mall_get_equipment_keys();
	var _array = [];
	
	array_copy(_array, 0, _stats, 0, array_length(_stats) );
	return _array;
}