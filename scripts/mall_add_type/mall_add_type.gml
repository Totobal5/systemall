/// @param	{String}	type_key	Llave del tipo
/// @desc	Crea uno o varios type mall
function mall_add_type(_KEY) 
{
    var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(global.__mallTypesMaster, _key) )
		{
			global.__mallTypesMaster[$ _key] = new MallType(_key);
			array_push(global.__mallTypesKeys, _key);
		}

		i += 1;
	}
}