/// @desc Crea un modificador
/// @param {String} modify_key...
function mall_add_modify() 
{
    var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(global.__mallModifyMaster, _key) )
		{
			global.__mallModifyMaster[$ _key] = (new MallModify(_key) );
			array_push(global.__mallModifyKeys, _key);
		}

		i = i + 1;
	}	
}