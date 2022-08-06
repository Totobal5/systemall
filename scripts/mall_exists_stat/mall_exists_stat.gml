/// @param {String}	stat_key
function mall_exists_stat(_KEY)
{
	return (variable_struct_exists(global.__mallStatsMaster, _KEY) );
}