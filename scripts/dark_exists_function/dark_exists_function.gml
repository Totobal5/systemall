/// @param  {String} darkKey
/// @return {Bool}
function dark_exists_function(_darkKey) 
{
	static database = MallDatabase.dark.functions;
    return (variable_struct_exists(database, _darkKey) );
}