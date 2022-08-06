/// @desc Ejecuta un codigo por cada tipo
/// @param {Function}	foreach_method	function(TYPE, KEY, I, [ARGUMENTS])
/// @param {Any}		[arguments]
function mall_type_foreach(_FUN, _PASS=[]) 
{
	var _type = mall_get_type_keys();	
	var i=0; repeat(array_length(_type) )
	{
		var _key = _type[i];
		var _mall = global.__mallTypesMaster[$ _key];
		_FUN(_key, _mall, i, _PASS);
		i += 1;
	}
}