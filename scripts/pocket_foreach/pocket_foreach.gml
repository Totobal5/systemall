/// @param {String}   bagKey
/// @param {Function} function
function pocket_foreach(_bagKey, _fun, _vars)
{
	var bag = pocket_get(_bagKey);
	return (bag.eventForeach(_fun, _vars) );
}