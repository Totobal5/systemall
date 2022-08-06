/// @desc Ejecuta un codigo por cada equipamiento
/// @param {Function}	foreach_method	function(EQUIPMENT, KEY, I, [ARGUMENTS])
/// @param {Any}		[arguments]
function mall_equipment_foreach(_FUN, _PASS=[])
{
	var _equipment = mall_get_equipments();
	var i=0; repeat(array_length(_equipment) )
	{
		var _key  = _equipment[i];
		var _mall = global.__mallEquipmentMaster[$ _key];
		
		_FUN(_mall, _key, i, _PASS);
		i += 1;
	}
}