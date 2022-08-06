/// @desc	Crear un (o varios) partes globalmente
/// @param	{String} equipment_key	Llaves
function mall_add_equipment() 
{
    var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(global.__mallEquipmentMaster, _key) )
		{
			global.__mallEquipmentMaster[$ _key] = (new MallEquipment(_key) );
			array_push(global.__mallEquipmentKeys, _key);
		}

		i += 1;
	}		
}