// Feather ignore all
/// @param {string} typeKey
function pocket_data_exists_type(_typeKey)
{
	static data = MallDatabase.pocket.type;
	return (variable_struct_exists(data, _typeKey) );
}