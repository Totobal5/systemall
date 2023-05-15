// Feather ignore all
function pocket_load(_bagKey, _lstruct)
{
	var _bag = pocket_get_bag(_bagKey);
	return (_bag.load(_lstruct) );
}