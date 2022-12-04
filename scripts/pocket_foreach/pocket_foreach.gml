/// @param {String}   bagKey
/// @param {Function} function
function pocket_foreach(_bagKey, _fun, _vars)
{
	static database = MallDatabase().pocket.bags;
	var _bag = database[$ _bagKey];
	return (_bag.foreach(_fun, _vars) );
}