/// @param	{String}	group_key		Llave del grupo
/// @param	{Bool}		[make_actual]	Si lo establece como el grupo actual
/// @desc	Crea un grupo mall
/// @return {Struct.MallGroup}
function mall_add_group(_group_key, _actual=false) 
{
	var _group = new MallGroup(_group_key, true); 
	global.__mall_groups_master.set(_group_key, _group);
	if (_actual) global.__mall_group_actual = _group;
	return (_group);
}