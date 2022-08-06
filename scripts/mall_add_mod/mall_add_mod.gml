/// @desc Crea un modificador
/// @param {String} mod_key...
function mall_add_mod() 
{
    var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(global.__mallModsMaster, _key) )
		{
			global.__mallModsMaster[$ _key] = (new MallMods(_key) );
			array_push(global.__mallModsKeys, _key);
		}

		i += 1;
	}	
}