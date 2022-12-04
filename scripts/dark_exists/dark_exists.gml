/// @param  {String} darkKey
/// @return {Bool}
function dark_exists(_darkKey) 
{
	static database = MallDatabase().dark.commands;
    return (variable_struct_exists(database, _darkKey) );
}