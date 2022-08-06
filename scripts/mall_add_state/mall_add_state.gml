/// @param	{String} state_key
/// @desc	Crea un estado
function mall_add_state() 
{
    var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(global.__mallStatesMaster, _key) )
		{
			global.__mallStatesMaster[$ _key] = (new MallState(_key) );
			array_push(global.__mallStatesKeys, _key);
		}

		i += 1;
	}	
}